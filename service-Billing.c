//Asynchronous Notification Interface
//Client-Side
//update the database - dbtext /etc/kamailio/dbtext
//update the corresponding htables

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/select.h>
#include <sys/time.h>
#include <sys/types.h>

#include <libpq-fe.h>

#include <arpa/inet.h> // inet_addr()
#include <netdb.h>
#include <strings.h> // bzero()
#include <sys/socket.h>
#include <unistd.h> // read(), write(), close()
#define MAX 80
#define PORT 8228

#include <hiredis.h>
#include <time.h>

static void close_connection(PGconn *dbconn)
{
    PQfinish(dbconn);
    exit(1);
}

redisContext* redisConnection(const char *hostname){

	redisReply *reply;
	redisContext *c;

	c = redisConnectUnixWithTimeout(hostname, timeout);

	if (c == NULL || c->err) {

	if (c) {
	    printf("Connection error: %s\n", c->errstr);
	    redisFree(c);
	} else {
	    printf("Connection error: can't allocate redis context\n");
	}

	exit(1);
	}

	/* PING server */
	reply = redisCommand(c, "PING");
	printf("PING: %s\n", reply->str);
	freeReplyObject(reply);

	return c;
}

int main(int argc, char const** argv)
{	
	PGconn *dbconn; 
	dbconn=PQconnectdb("postgresql://kamailio:kamailiorw@172.18.0.9:5432/kamailio");							       	
	if (PQstatus(dbconn) != CONNECTION_OK) {
		fprintf(stderr, "%s", PQerrorMessage(dbconn));	
		close_connection(dbconn);
	}

	PGresult *query;
	query = PQexec(dbconn, "SELECT pg_catalog.set_config('search_path', '', false)");
	if (PQresultStatus(query) != PGRES_TUPLES_OK) {
		fprintf(stderr, "SET failed: %s", PQerrorMessage(dbconn));
		PQclear(query);
		close_connection(dbconn);        
	}
	PQclear(query);

	query = PQexec(dbconn, "LISTEN tbl2");
	if (PQresultStatus(query) != PGRES_COMMAND_OK) {
		fprintf(stderr, "LISTEN command failed: %s\n", PQerrorMessage(dbconn));
		PQclear(query);
		close_connection(dbconn);  
	}
	PQclear(query);

	struct timeval timeout = {1, 500000}; // 1.5 seconds
	redisReply *reply;
	redisContext *c = redisConnection("172.18.0.6");
	int pos=0;
        char buffer[4096];
	
	int sock, rows, cols, i, j;
	fd_set reading;	
	PGnotify   *notify;

	while(1){

		sock=PQsocket(dbconn);
		if(sock<0) break;
		
		FD_ZERO(&reading);
		FD_SET(sock, &reading);

		if(select(sock+1, &reading, NULL, NULL, NULL) < 0){
			fprintf(stderr, "select() failed: %s\n", strerror(errno));
			close_connection(dbconn);
		}

		PQconsumeInput(dbconn);
		while((notify = PQnotifies(dbconn)) != NULL){
			//notify->extra notification payload string
			//notify->relname channel name
			fprintf(stderr, "ASYNC NOTIFY of '%s' received from backend PID %d with payload of %s\n", notify->relname, notify->be_pid, notify->extra);
			PQfreemem(notify);			
			PQconsumeInput(dbconn);
		}
                
		//SELECT * FROM billing_service (view)
		query = PQexec(dbconn, "SELECT customer, credit, max_time FROM public.billing_service");			

		if (PQresultStatus(query) != PGRES_TUPLES_OK)
		{
			fprintf(stderr, "Error while executing the query: %s\n", PQerrorMessage(dbconn));
			PQclear(query);
			close_connection(dbconn);  
		}

		rows = PQntuples(query);
		cols = PQnfields(query);

		reply = redisCommand(c,"SELECT 1");
		printf("SELECT db: %s\n", reply->str);

		for (i = 0; i < rows; i++) {

		 	pos=sprintf(buffer+pos,"HMSET cnxcc:%lu ",i);
			pos+=sprintf(buffer+pos,"customer %s ", PQgetvalue(query,i,0));
			pos+=sprintf(buffer+pos,"credit %lu ", PQgetvalue(query,i,1));
			pos+=sprintf(buffer+pos,"max_time %lu ", PQgetvalue(query,i,2));

			redisCommand(c,buffer);

			pos=0;
			buffer[0]='\0';
		}
		
		PQclear(query);
	}

	fprintf(stderr, "Done.\n");

	PQfinish(dbconn);

	freeReplyObject(reply);
	redisFree(c);
	
	return 0;
}




