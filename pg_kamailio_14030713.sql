--
-- PostgreSQL database cluster dump
--

SET default_transaction_read_only = off;

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE kamailio;
ALTER ROLE kamailio WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:201S70XVT1rLtNILv0hHGw==$6tgoPbdOM06ZxePEKq0VKnczW8id9WbPxiyVrLLDVs8=:/P+crHlbNhOCUvvYkJ92slmb4mMnqRaHqkg3NMjlvmU=';
CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION BYPASSRLS PASSWORD 'SCRAM-SHA-256$4096:JBSM7Zcr4nuywwFRmWH8vw==$y0KIHR1+509HPDKYktIEwEjqF2xWS3Nz9eEIrr+aPrs=:1PA3+R8b9R0tzPNP6Hrh0adlvqmt7s9hSztWBAlGX84=';

--
-- User Configurations
--








--
-- Databases
--

--
-- Database "template1" dump
--

\connect template1

--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3 (Debian 16.3-1.pgdg120+1)
-- Dumped by pg_dump version 16.3 (Debian 16.3-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- PostgreSQL database dump complete
--

--
-- Database "kamailio" dump
--

--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3 (Debian 16.3-1.pgdg120+1)
-- Dumped by pg_dump version 16.3 (Debian 16.3-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: kamailio; Type: DATABASE; Schema: -; Owner: kamailio
--

CREATE DATABASE kamailio WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


ALTER DATABASE kamailio OWNER TO kamailio;

\connect kamailio

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: notifyondatachange(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.notifyondatachange() RETURNS trigger
    LANGUAGE plpgsql
    AS $$ 
DECLARE 
  data JSON;
  notification JSON;
BEGIN

  IF (TG_OP = 'DELETE') THEN
    data = row_to_json(OLD);
  ELSE
    data = row_to_json(NEW);
  END IF;
 
  notification = json_build_object(
            'table',TG_TABLE_NAME,
            'action', TG_OP, 
            'data', data);  
            
    -- note that channel name MUST be lowercase, otherwise pg_notify() won't work
    PERFORM pg_notify('tbl2', notification::TEXT);
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.notifyondatachange() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: acc; Type: TABLE; Schema: public; Owner: kamailio
--

CREATE TABLE public.acc (
    id integer NOT NULL,
    method character varying(16) DEFAULT ''::character varying NOT NULL,
    from_tag character varying(128) DEFAULT ''::character varying NOT NULL,
    to_tag character varying(128) DEFAULT ''::character varying NOT NULL,
    callid character varying(255) DEFAULT ''::character varying NOT NULL,
    sip_code character varying(3) DEFAULT ''::character varying NOT NULL,
    sip_reason character varying(128) DEFAULT ''::character varying NOT NULL,
    "time" timestamp without time zone NOT NULL
);


ALTER TABLE public.acc OWNER TO kamailio;

--
-- Name: acc_cdrs; Type: TABLE; Schema: public; Owner: kamailio
--

CREATE TABLE public.acc_cdrs (
    id integer NOT NULL,
    start_time timestamp without time zone DEFAULT '2000-01-01 00:00:00'::timestamp without time zone NOT NULL,
    end_time timestamp without time zone DEFAULT '2000-01-01 00:00:00'::timestamp without time zone NOT NULL,
    duration real DEFAULT 0 NOT NULL
);


ALTER TABLE public.acc_cdrs OWNER TO kamailio;

--
-- Name: acc_cdrs_id_seq; Type: SEQUENCE; Schema: public; Owner: kamailio
--

CREATE SEQUENCE public.acc_cdrs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.acc_cdrs_id_seq OWNER TO kamailio;

--
-- Name: acc_cdrs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kamailio
--

ALTER SEQUENCE public.acc_cdrs_id_seq OWNED BY public.acc_cdrs.id;


--
-- Name: acc_id_seq; Type: SEQUENCE; Schema: public; Owner: kamailio
--

CREATE SEQUENCE public.acc_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.acc_id_seq OWNER TO kamailio;

--
-- Name: acc_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kamailio
--

ALTER SEQUENCE public.acc_id_seq OWNED BY public.acc.id;


--
-- Name: active_watchers; Type: TABLE; Schema: public; Owner: kamailio
--

CREATE TABLE public.active_watchers (
    id integer NOT NULL,
    presentity_uri character varying(255) NOT NULL,
    watcher_username character varying(64) NOT NULL,
    watcher_domain character varying(64) NOT NULL,
    to_user character varying(64) NOT NULL,
    to_domain character varying(64) NOT NULL,
    event character varying(64) DEFAULT 'presence'::character varying NOT NULL,
    event_id character varying(64),
    to_tag character varying(128) NOT NULL,
    from_tag character varying(128) NOT NULL,
    callid character varying(255) NOT NULL,
    local_cseq integer NOT NULL,
    remote_cseq integer NOT NULL,
    contact character varying(255) NOT NULL,
    record_route text,
    expires integer NOT NULL,
    status integer DEFAULT 2 NOT NULL,
    reason character varying(64),
    version integer DEFAULT 0 NOT NULL,
    socket_info character varying(64) NOT NULL,
    local_contact character varying(255) NOT NULL,
    from_user character varying(64) NOT NULL,
    from_domain character varying(64) NOT NULL,
    updated integer NOT NULL,
    updated_winfo integer NOT NULL,
    flags integer DEFAULT 0 NOT NULL,
    user_agent character varying(255) DEFAULT ''::character varying
);


ALTER TABLE public.active_watchers OWNER TO kamailio;

--
-- Name: active_watchers_id_seq; Type: SEQUENCE; Schema: public; Owner: kamailio
--

CREATE SEQUENCE public.active_watchers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.active_watchers_id_seq OWNER TO kamailio;

--
-- Name: active_watchers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kamailio
--

ALTER SEQUENCE public.active_watchers_id_seq OWNED BY public.active_watchers.id;


--
-- Name: billing; Type: TABLE; Schema: public; Owner: kamailio
--

CREATE TABLE public.billing (
    id integer NOT NULL,
    country_code character varying(255) DEFAULT 93 NOT NULL,
    call_rates real DEFAULT '0'::real NOT NULL
);


ALTER TABLE public.billing OWNER TO kamailio;

--
-- Name: billing_id_seq; Type: SEQUENCE; Schema: public; Owner: kamailio
--

CREATE SEQUENCE public.billing_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.billing_id_seq OWNER TO kamailio;

--
-- Name: billing_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kamailio
--

ALTER SEQUENCE public.billing_id_seq OWNED BY public.billing.id;


--
-- Name: cdr; Type: TABLE; Schema: public; Owner: kamailio
--

CREATE TABLE public.cdr (
    id integer NOT NULL,
    sip_callid character varying(255),
    from_uri character varying(255),
    to_uri character varying(255),
    from_tag character varying(128),
    to_tag character varying(128),
    sip_status integer,
    src_ip integer,
    src_port smallint,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone NOT NULL,
    duration integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.cdr OWNER TO kamailio;

--
-- Name: subscriber; Type: TABLE; Schema: public; Owner: kamailio
--

CREATE TABLE public.subscriber (
    id integer NOT NULL,
    username character varying(64) DEFAULT ''::character varying NOT NULL,
    domain character varying(64) DEFAULT ''::character varying NOT NULL,
    password character varying(64) DEFAULT ''::character varying NOT NULL,
    ha1 character varying(128) DEFAULT ''::character varying NOT NULL,
    ha1b character varying(128) DEFAULT ''::character varying NOT NULL,
    credit real
);


ALTER TABLE public.subscriber OWNER TO kamailio;

--
-- Name: billing_service; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.billing_service AS
 WITH temp AS (
         SELECT subscriber.username AS customer,
            (subscriber.credit - ((cdr.duration)::double precision * billing.call_rates)) AS credit,
            billing.call_rates
           FROM ((public.subscriber
             JOIN public.cdr ON (((subscriber.username)::text = (cdr.from_uri)::text)))
             JOIN public.billing ON (((billing.country_code)::text = (cdr.to_uri)::text)))
        )
 SELECT customer,
        CASE
            WHEN (credit < (0)::double precision) THEN (0)::double precision
            ELSE credit
        END AS credit,
        CASE
            WHEN (credit < (0)::double precision) THEN (0)::double precision
            ELSE (credit / call_rates)
        END AS max_time
   FROM temp;


ALTER VIEW public.billing_service OWNER TO postgres;

--
-- Name: cdr_id_seq; Type: SEQUENCE; Schema: public; Owner: kamailio
--

CREATE SEQUENCE public.cdr_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.cdr_id_seq OWNER TO kamailio;

--
-- Name: cdr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kamailio
--

ALTER SEQUENCE public.cdr_id_seq OWNED BY public.cdr.id;


--
-- Name: location; Type: TABLE; Schema: public; Owner: kamailio
--

CREATE TABLE public.location (
    id integer NOT NULL,
    ruid character varying(64) DEFAULT ''::character varying NOT NULL,
    username character varying(64) DEFAULT ''::character varying NOT NULL,
    domain character varying(64) DEFAULT NULL::character varying,
    contact character varying(512) DEFAULT ''::character varying NOT NULL,
    received character varying(128) DEFAULT NULL::character varying,
    path character varying(512) DEFAULT NULL::character varying,
    expires timestamp without time zone DEFAULT '2030-05-28 21:32:15'::timestamp without time zone NOT NULL,
    q real DEFAULT 1.0 NOT NULL,
    callid character varying(255) DEFAULT 'Default-Call-ID'::character varying NOT NULL,
    cseq integer DEFAULT 1 NOT NULL,
    last_modified timestamp without time zone DEFAULT '2000-01-01 00:00:01'::timestamp without time zone NOT NULL,
    flags integer DEFAULT 0 NOT NULL,
    cflags integer DEFAULT 0 NOT NULL,
    user_agent character varying(255) DEFAULT ''::character varying NOT NULL,
    socket character varying(64) DEFAULT NULL::character varying,
    methods integer,
    instance character varying(255) DEFAULT NULL::character varying,
    reg_id integer DEFAULT 0 NOT NULL,
    server_id integer DEFAULT 0 NOT NULL,
    connection_id integer DEFAULT 0 NOT NULL,
    keepalive integer DEFAULT 0 NOT NULL,
    partition integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.location OWNER TO kamailio;

--
-- Name: location_attrs; Type: TABLE; Schema: public; Owner: kamailio
--

CREATE TABLE public.location_attrs (
    id integer NOT NULL,
    ruid character varying(64) DEFAULT ''::character varying NOT NULL,
    username character varying(64) DEFAULT ''::character varying NOT NULL,
    domain character varying(64) DEFAULT NULL::character varying,
    aname character varying(64) DEFAULT ''::character varying NOT NULL,
    atype integer DEFAULT 0 NOT NULL,
    avalue character varying(512) DEFAULT ''::character varying NOT NULL,
    last_modified timestamp without time zone DEFAULT '2000-01-01 00:00:01'::timestamp without time zone NOT NULL
);


ALTER TABLE public.location_attrs OWNER TO kamailio;

--
-- Name: location_attrs_id_seq; Type: SEQUENCE; Schema: public; Owner: kamailio
--

CREATE SEQUENCE public.location_attrs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.location_attrs_id_seq OWNER TO kamailio;

--
-- Name: location_attrs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kamailio
--

ALTER SEQUENCE public.location_attrs_id_seq OWNED BY public.location_attrs.id;


--
-- Name: location_id_seq; Type: SEQUENCE; Schema: public; Owner: kamailio
--

CREATE SEQUENCE public.location_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.location_id_seq OWNER TO kamailio;

--
-- Name: location_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kamailio
--

ALTER SEQUENCE public.location_id_seq OWNED BY public.location.id;


--
-- Name: missed_calls; Type: TABLE; Schema: public; Owner: kamailio
--

CREATE TABLE public.missed_calls (
    id integer NOT NULL,
    sip_callid character varying(255),
    from_uri character varying(255),
    to_uri character varying(255),
    from_tag character varying(128),
    to_tag character varying(128),
    sip_status integer,
    src_ip integer,
    src_port smallint,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone NOT NULL,
    duration integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.missed_calls OWNER TO kamailio;

--
-- Name: missed_calls_id_seq; Type: SEQUENCE; Schema: public; Owner: kamailio
--

CREATE SEQUENCE public.missed_calls_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.missed_calls_id_seq OWNER TO kamailio;

--
-- Name: missed_calls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kamailio
--

ALTER SEQUENCE public.missed_calls_id_seq OWNED BY public.missed_calls.id;


--
-- Name: presentity; Type: TABLE; Schema: public; Owner: kamailio
--

CREATE TABLE public.presentity (
    id integer NOT NULL,
    username character varying(64) NOT NULL,
    domain character varying(64) NOT NULL,
    event character varying(64) NOT NULL,
    etag character varying(128) NOT NULL,
    expires integer NOT NULL,
    received_time integer NOT NULL,
    body bytea NOT NULL,
    sender character varying(255) NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    ruid character varying(64)
);


ALTER TABLE public.presentity OWNER TO kamailio;

--
-- Name: presentity_id_seq; Type: SEQUENCE; Schema: public; Owner: kamailio
--

CREATE SEQUENCE public.presentity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.presentity_id_seq OWNER TO kamailio;

--
-- Name: presentity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kamailio
--

ALTER SEQUENCE public.presentity_id_seq OWNED BY public.presentity.id;


--
-- Name: pua; Type: TABLE; Schema: public; Owner: kamailio
--

CREATE TABLE public.pua (
    id integer NOT NULL,
    pres_uri character varying(255) NOT NULL,
    pres_id character varying(255) NOT NULL,
    event integer NOT NULL,
    expires integer NOT NULL,
    desired_expires integer NOT NULL,
    flag integer NOT NULL,
    etag character varying(128) NOT NULL,
    tuple_id character varying(64),
    watcher_uri character varying(255) NOT NULL,
    call_id character varying(255) NOT NULL,
    to_tag character varying(128) NOT NULL,
    from_tag character varying(128) NOT NULL,
    cseq integer NOT NULL,
    record_route text,
    contact character varying(255) NOT NULL,
    remote_contact character varying(255) NOT NULL,
    version integer NOT NULL,
    extra_headers text NOT NULL
);


ALTER TABLE public.pua OWNER TO kamailio;

--
-- Name: pua_id_seq; Type: SEQUENCE; Schema: public; Owner: kamailio
--

CREATE SEQUENCE public.pua_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pua_id_seq OWNER TO kamailio;

--
-- Name: pua_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kamailio
--

ALTER SEQUENCE public.pua_id_seq OWNED BY public.pua.id;


--
-- Name: subscriber_id_seq; Type: SEQUENCE; Schema: public; Owner: kamailio
--

CREATE SEQUENCE public.subscriber_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.subscriber_id_seq OWNER TO kamailio;

--
-- Name: subscriber_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kamailio
--

ALTER SEQUENCE public.subscriber_id_seq OWNED BY public.subscriber.id;


--
-- Name: version; Type: TABLE; Schema: public; Owner: kamailio
--

CREATE TABLE public.version (
    id integer NOT NULL,
    table_name character varying(32) NOT NULL,
    table_version integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.version OWNER TO kamailio;

--
-- Name: version_id_seq; Type: SEQUENCE; Schema: public; Owner: kamailio
--

CREATE SEQUENCE public.version_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.version_id_seq OWNER TO kamailio;

--
-- Name: version_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kamailio
--

ALTER SEQUENCE public.version_id_seq OWNED BY public.version.id;


--
-- Name: watchers; Type: TABLE; Schema: public; Owner: kamailio
--

CREATE TABLE public.watchers (
    id integer NOT NULL,
    presentity_uri character varying(255) NOT NULL,
    watcher_username character varying(64) NOT NULL,
    watcher_domain character varying(64) NOT NULL,
    event character varying(64) DEFAULT 'presence'::character varying NOT NULL,
    status integer NOT NULL,
    reason character varying(64),
    inserted_time integer NOT NULL
);


ALTER TABLE public.watchers OWNER TO kamailio;

--
-- Name: watchers_id_seq; Type: SEQUENCE; Schema: public; Owner: kamailio
--

CREATE SEQUENCE public.watchers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.watchers_id_seq OWNER TO kamailio;

--
-- Name: watchers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kamailio
--

ALTER SEQUENCE public.watchers_id_seq OWNED BY public.watchers.id;


--
-- Name: xcap; Type: TABLE; Schema: public; Owner: kamailio
--

CREATE TABLE public.xcap (
    id integer NOT NULL,
    username character varying(64) NOT NULL,
    domain character varying(64) NOT NULL,
    doc bytea NOT NULL,
    doc_type integer NOT NULL,
    etag character varying(128) NOT NULL,
    source integer NOT NULL,
    doc_uri character varying(255) NOT NULL,
    port integer NOT NULL
);


ALTER TABLE public.xcap OWNER TO kamailio;

--
-- Name: xcap_id_seq; Type: SEQUENCE; Schema: public; Owner: kamailio
--

CREATE SEQUENCE public.xcap_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.xcap_id_seq OWNER TO kamailio;

--
-- Name: xcap_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: kamailio
--

ALTER SEQUENCE public.xcap_id_seq OWNED BY public.xcap.id;


--
-- Name: acc id; Type: DEFAULT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.acc ALTER COLUMN id SET DEFAULT nextval('public.acc_id_seq'::regclass);


--
-- Name: acc_cdrs id; Type: DEFAULT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.acc_cdrs ALTER COLUMN id SET DEFAULT nextval('public.acc_cdrs_id_seq'::regclass);


--
-- Name: active_watchers id; Type: DEFAULT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.active_watchers ALTER COLUMN id SET DEFAULT nextval('public.active_watchers_id_seq'::regclass);


--
-- Name: billing id; Type: DEFAULT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.billing ALTER COLUMN id SET DEFAULT nextval('public.billing_id_seq'::regclass);


--
-- Name: cdr id; Type: DEFAULT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.cdr ALTER COLUMN id SET DEFAULT nextval('public.cdr_id_seq'::regclass);


--
-- Name: location id; Type: DEFAULT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.location ALTER COLUMN id SET DEFAULT nextval('public.location_id_seq'::regclass);


--
-- Name: location_attrs id; Type: DEFAULT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.location_attrs ALTER COLUMN id SET DEFAULT nextval('public.location_attrs_id_seq'::regclass);


--
-- Name: missed_calls id; Type: DEFAULT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.missed_calls ALTER COLUMN id SET DEFAULT nextval('public.missed_calls_id_seq'::regclass);


--
-- Name: presentity id; Type: DEFAULT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.presentity ALTER COLUMN id SET DEFAULT nextval('public.presentity_id_seq'::regclass);


--
-- Name: pua id; Type: DEFAULT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.pua ALTER COLUMN id SET DEFAULT nextval('public.pua_id_seq'::regclass);


--
-- Name: subscriber id; Type: DEFAULT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.subscriber ALTER COLUMN id SET DEFAULT nextval('public.subscriber_id_seq'::regclass);


--
-- Name: version id; Type: DEFAULT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.version ALTER COLUMN id SET DEFAULT nextval('public.version_id_seq'::regclass);


--
-- Name: watchers id; Type: DEFAULT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.watchers ALTER COLUMN id SET DEFAULT nextval('public.watchers_id_seq'::regclass);


--
-- Name: xcap id; Type: DEFAULT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.xcap ALTER COLUMN id SET DEFAULT nextval('public.xcap_id_seq'::regclass);


--
-- Data for Name: acc; Type: TABLE DATA; Schema: public; Owner: kamailio
--

COPY public.acc (id, method, from_tag, to_tag, callid, sip_code, sip_reason, "time") FROM stdin;
1	INVITE	DGVrCDtdm		2uUiXkM16E	203	2uUiXkM16E	2024-10-04 12:48:40
2	INVITE	HJAuY8VkO		8w6VaVfLV6	636	8w6VaVfLV6	2024-10-04 12:49:25
\.


--
-- Data for Name: acc_cdrs; Type: TABLE DATA; Schema: public; Owner: kamailio
--

COPY public.acc_cdrs (id, start_time, end_time, duration) FROM stdin;
\.


--
-- Data for Name: active_watchers; Type: TABLE DATA; Schema: public; Owner: kamailio
--

COPY public.active_watchers (id, presentity_uri, watcher_username, watcher_domain, to_user, to_domain, event, event_id, to_tag, from_tag, callid, local_cseq, remote_cseq, contact, record_route, expires, status, reason, version, socket_info, local_contact, from_user, from_domain, updated, updated_winfo, flags, user_agent) FROM stdin;
\.


--
-- Data for Name: billing; Type: TABLE DATA; Schema: public; Owner: kamailio
--

COPY public.billing (id, country_code, call_rates) FROM stdin;
1	0093	5
\.


--
-- Data for Name: cdr; Type: TABLE DATA; Schema: public; Owner: kamailio
--

COPY public.cdr (id, sip_callid, from_uri, to_uri, from_tag, to_tag, sip_status, src_ip, src_port, start_time, end_time, duration) FROM stdin;
1	callid_209	209	0093	\N	\N	\N	\N	\N	2024-07-19 13:15:06	2024-07-19 14:05:06	10
2	callid_555	555	0093	\N	\N	\N	\N	\N	2024-07-19 15:15:06	2024-07-19 15:35:06	5
3	callid_321	321	0093	\N	\N	\N	\N	\N	2024-07-19 15:15:06	2024-07-19 16:35:06	15
1	2uUiXkM16E	sip:9809610663@185.83.210.134	sip:9809645639@185.83.210.134	DGVrCDtdm		5	\N	\N	2024-10-04 12:48:40	2024-10-04 12:48:40	0
2	8w6VaVfLV6	sip:9809610663@185.83.210.134	sip:9809645639@185.83.210.134	HJAuY8VkO		5	\N	\N	2024-10-04 12:49:25	2024-10-04 12:49:25	0
\.


--
-- Data for Name: location; Type: TABLE DATA; Schema: public; Owner: kamailio
--

COPY public.location (id, ruid, username, domain, contact, received, path, expires, q, callid, cseq, last_modified, flags, cflags, user_agent, socket, methods, instance, reg_id, server_id, connection_id, keepalive, partition) FROM stdin;
5342	uloc-66a23470-b-c3b	321	172.18.0.2	sip:321@93.118.154.9:5060;transport=UDP;rinstance=1ee0e15052dcc3f3	\N	\N	2024-08-01 09:17:52	-1	ei1oB_BKAxMSdL_K7uRU1w..	25	2024-08-01 09:16:52	0	0	Zoiper v2.10.20.4_1	udp:172.18.0.2:5060	5087	\N	0	0	-1	0	0
5344	uloc-66ec63d9-b-ccc	9809610663	185.83.210.134	sip:9809610663@93.118.154.9:55558;transport=udp	\N	\N	2024-10-04 13:44:51	-1	imwohO4Zs5	1525	2024-10-04 12:44:51	0	0	LinphoneAndroid/5.2.5 (realme Note 50) LinphoneSDK/5.3.47 (tags/5.3.47^0)	udp:172.18.0.2:5060	\N	<urn:uuid:b63ccd1f-25ad-0079-aaf1-4c67ffe8276f>	0	0	-1	0	0
5345	uloc-66ec63d9-b-dcc	9809645639	185.83.210.134	sip:9809645639@93.118.154.9:54827;transport=udp	\N	\N	2024-10-04 13:47:27	-1	knku4bZXSa	1604	2024-10-04 12:47:27	0	0	LinphoneAndroid/5.2.5 (realme Note 50) LinphoneSDK/5.3.47 (tags/5.3.47^0)	udp:172.18.0.2:5060	\N	<urn:uuid:9d47e952-db86-00d7-9aaa-84ceab23fead>	0	0	-1	0	0
\.


--
-- Data for Name: location_attrs; Type: TABLE DATA; Schema: public; Owner: kamailio
--

COPY public.location_attrs (id, ruid, username, domain, aname, atype, avalue, last_modified) FROM stdin;
\.


--
-- Data for Name: missed_calls; Type: TABLE DATA; Schema: public; Owner: kamailio
--

COPY public.missed_calls (id, sip_callid, from_uri, to_uri, from_tag, to_tag, sip_status, src_ip, src_port, start_time, end_time, duration) FROM stdin;
\.


--
-- Data for Name: presentity; Type: TABLE DATA; Schema: public; Owner: kamailio
--

COPY public.presentity (id, username, domain, event, etag, expires, received_time, body, sender, priority, ruid) FROM stdin;
\.


--
-- Data for Name: pua; Type: TABLE DATA; Schema: public; Owner: kamailio
--

COPY public.pua (id, pres_uri, pres_id, event, expires, desired_expires, flag, etag, tuple_id, watcher_uri, call_id, to_tag, from_tag, cseq, record_route, contact, remote_contact, version, extra_headers) FROM stdin;
\.


--
-- Data for Name: subscriber; Type: TABLE DATA; Schema: public; Owner: kamailio
--

COPY public.subscriber (id, username, domain, password, ha1, ha1b, credit) FROM stdin;
2	555	185.83.210.134	555			50
3	321	185.83.210.134	321			65
1	209	185.83.210.134	209			100
4	9809645639	185.83.210.134	9809645639			450
5	9809610663	185.83.210.134	9809610663			780
\.


--
-- Data for Name: version; Type: TABLE DATA; Schema: public; Owner: kamailio
--

COPY public.version (id, table_name, table_version) FROM stdin;
1	version	1
2	subscriber	7
3	location	9
4	location_attrs	1
5	billing	1
6	cdr	1
7	missed_calls	1
8	acc	5
9	acc_cdrs	2
11	presentity	5
12	active_watchers	12
13	watchers	3
14	xcap	4
15	pua	7
\.


--
-- Data for Name: watchers; Type: TABLE DATA; Schema: public; Owner: kamailio
--

COPY public.watchers (id, presentity_uri, watcher_username, watcher_domain, event, status, reason, inserted_time) FROM stdin;
\.


--
-- Data for Name: xcap; Type: TABLE DATA; Schema: public; Owner: kamailio
--

COPY public.xcap (id, username, domain, doc, doc_type, etag, source, doc_uri, port) FROM stdin;
\.


--
-- Name: acc_cdrs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kamailio
--

SELECT pg_catalog.setval('public.acc_cdrs_id_seq', 1, false);


--
-- Name: acc_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kamailio
--

SELECT pg_catalog.setval('public.acc_id_seq', 2, true);


--
-- Name: active_watchers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kamailio
--

SELECT pg_catalog.setval('public.active_watchers_id_seq', 1, false);


--
-- Name: billing_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kamailio
--

SELECT pg_catalog.setval('public.billing_id_seq', 1, false);


--
-- Name: cdr_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kamailio
--

SELECT pg_catalog.setval('public.cdr_id_seq', 2, true);


--
-- Name: location_attrs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kamailio
--

SELECT pg_catalog.setval('public.location_attrs_id_seq', 1, false);


--
-- Name: location_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kamailio
--

SELECT pg_catalog.setval('public.location_id_seq', 5345, true);


--
-- Name: missed_calls_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kamailio
--

SELECT pg_catalog.setval('public.missed_calls_id_seq', 1, false);


--
-- Name: presentity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kamailio
--

SELECT pg_catalog.setval('public.presentity_id_seq', 1, false);


--
-- Name: pua_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kamailio
--

SELECT pg_catalog.setval('public.pua_id_seq', 1, false);


--
-- Name: subscriber_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kamailio
--

SELECT pg_catalog.setval('public.subscriber_id_seq', 5, true);


--
-- Name: version_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kamailio
--

SELECT pg_catalog.setval('public.version_id_seq', 15, true);


--
-- Name: watchers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kamailio
--

SELECT pg_catalog.setval('public.watchers_id_seq', 1, false);


--
-- Name: xcap_id_seq; Type: SEQUENCE SET; Schema: public; Owner: kamailio
--

SELECT pg_catalog.setval('public.xcap_id_seq', 1, false);


--
-- Name: acc_cdrs acc_cdrs_pkey; Type: CONSTRAINT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.acc_cdrs
    ADD CONSTRAINT acc_cdrs_pkey PRIMARY KEY (id);


--
-- Name: acc acc_pkey; Type: CONSTRAINT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.acc
    ADD CONSTRAINT acc_pkey PRIMARY KEY (id);


--
-- Name: active_watchers active_watchers_active_watchers_idx; Type: CONSTRAINT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.active_watchers
    ADD CONSTRAINT active_watchers_active_watchers_idx UNIQUE (callid, to_tag, from_tag);


--
-- Name: active_watchers active_watchers_pkey; Type: CONSTRAINT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.active_watchers
    ADD CONSTRAINT active_watchers_pkey PRIMARY KEY (id);


--
-- Name: billing billing_id_key; Type: CONSTRAINT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.billing
    ADD CONSTRAINT billing_id_key UNIQUE (country_code, id);


--
-- Name: cdr cdr_id_key; Type: CONSTRAINT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.cdr
    ADD CONSTRAINT cdr_id_key UNIQUE (sip_callid, id);


--
-- Name: location_attrs location_attrs_pkey; Type: CONSTRAINT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.location_attrs
    ADD CONSTRAINT location_attrs_pkey PRIMARY KEY (id);


--
-- Name: location location_pkey; Type: CONSTRAINT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.location
    ADD CONSTRAINT location_pkey PRIMARY KEY (id);


--
-- Name: location location_ruid_idx; Type: CONSTRAINT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.location
    ADD CONSTRAINT location_ruid_idx UNIQUE (ruid);


--
-- Name: missed_calls missed_calls_id_key; Type: CONSTRAINT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.missed_calls
    ADD CONSTRAINT missed_calls_id_key UNIQUE (sip_callid, id);


--
-- Name: presentity presentity_pkey; Type: CONSTRAINT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.presentity
    ADD CONSTRAINT presentity_pkey PRIMARY KEY (id);


--
-- Name: presentity presentity_presentity_idx; Type: CONSTRAINT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.presentity
    ADD CONSTRAINT presentity_presentity_idx UNIQUE (username, domain, event, etag);


--
-- Name: presentity presentity_ruid_idx; Type: CONSTRAINT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.presentity
    ADD CONSTRAINT presentity_ruid_idx UNIQUE (ruid);


--
-- Name: pua pua_pkey; Type: CONSTRAINT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.pua
    ADD CONSTRAINT pua_pkey PRIMARY KEY (id);


--
-- Name: pua pua_pua_idx; Type: CONSTRAINT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.pua
    ADD CONSTRAINT pua_pua_idx UNIQUE (etag, tuple_id, call_id, from_tag);


--
-- Name: subscriber subscriber_account_idx; Type: CONSTRAINT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.subscriber
    ADD CONSTRAINT subscriber_account_idx UNIQUE (username, domain);


--
-- Name: subscriber subscriber_pkey; Type: CONSTRAINT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.subscriber
    ADD CONSTRAINT subscriber_pkey PRIMARY KEY (id);


--
-- Name: version version_pkey; Type: CONSTRAINT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.version
    ADD CONSTRAINT version_pkey PRIMARY KEY (id);


--
-- Name: version version_table_name_idx; Type: CONSTRAINT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.version
    ADD CONSTRAINT version_table_name_idx UNIQUE (table_name);


--
-- Name: watchers watchers_pkey; Type: CONSTRAINT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.watchers
    ADD CONSTRAINT watchers_pkey PRIMARY KEY (id);


--
-- Name: watchers watchers_watcher_idx; Type: CONSTRAINT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.watchers
    ADD CONSTRAINT watchers_watcher_idx UNIQUE (presentity_uri, watcher_username, watcher_domain, event);


--
-- Name: xcap xcap_doc_uri_idx; Type: CONSTRAINT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.xcap
    ADD CONSTRAINT xcap_doc_uri_idx UNIQUE (doc_uri);


--
-- Name: xcap xcap_pkey; Type: CONSTRAINT; Schema: public; Owner: kamailio
--

ALTER TABLE ONLY public.xcap
    ADD CONSTRAINT xcap_pkey PRIMARY KEY (id);


--
-- Name: acc_callid_idx; Type: INDEX; Schema: public; Owner: kamailio
--

CREATE INDEX acc_callid_idx ON public.acc USING btree (callid);


--
-- Name: acc_cdrs_start_time_idx; Type: INDEX; Schema: public; Owner: kamailio
--

CREATE INDEX acc_cdrs_start_time_idx ON public.acc_cdrs USING btree (start_time);


--
-- Name: active_watchers_active_watchers_expires; Type: INDEX; Schema: public; Owner: kamailio
--

CREATE INDEX active_watchers_active_watchers_expires ON public.active_watchers USING btree (expires);


--
-- Name: active_watchers_active_watchers_pres; Type: INDEX; Schema: public; Owner: kamailio
--

CREATE INDEX active_watchers_active_watchers_pres ON public.active_watchers USING btree (presentity_uri, event);


--
-- Name: active_watchers_updated_idx; Type: INDEX; Schema: public; Owner: kamailio
--

CREATE INDEX active_watchers_updated_idx ON public.active_watchers USING btree (updated);


--
-- Name: active_watchers_updated_winfo_idx; Type: INDEX; Schema: public; Owner: kamailio
--

CREATE INDEX active_watchers_updated_winfo_idx ON public.active_watchers USING btree (updated_winfo, presentity_uri);


--
-- Name: location_account_contact_idx; Type: INDEX; Schema: public; Owner: kamailio
--

CREATE INDEX location_account_contact_idx ON public.location USING btree (username, domain, contact);


--
-- Name: location_attrs_account_record_idx; Type: INDEX; Schema: public; Owner: kamailio
--

CREATE INDEX location_attrs_account_record_idx ON public.location_attrs USING btree (username, domain, ruid);


--
-- Name: location_attrs_last_modified_idx; Type: INDEX; Schema: public; Owner: kamailio
--

CREATE INDEX location_attrs_last_modified_idx ON public.location_attrs USING btree (last_modified);


--
-- Name: location_connection_idx; Type: INDEX; Schema: public; Owner: kamailio
--

CREATE INDEX location_connection_idx ON public.location USING btree (server_id, connection_id);


--
-- Name: location_expires_idx; Type: INDEX; Schema: public; Owner: kamailio
--

CREATE INDEX location_expires_idx ON public.location USING btree (expires);


--
-- Name: location_tcpcon_idx; Type: INDEX; Schema: public; Owner: kamailio
--

CREATE INDEX location_tcpcon_idx ON public.location USING btree (connection_id);


--
-- Name: presentity_account_idx; Type: INDEX; Schema: public; Owner: kamailio
--

CREATE INDEX presentity_account_idx ON public.presentity USING btree (username, domain, event);


--
-- Name: presentity_presentity_expires; Type: INDEX; Schema: public; Owner: kamailio
--

CREATE INDEX presentity_presentity_expires ON public.presentity USING btree (expires);


--
-- Name: pua_dialog1_idx; Type: INDEX; Schema: public; Owner: kamailio
--

CREATE INDEX pua_dialog1_idx ON public.pua USING btree (pres_id, pres_uri);


--
-- Name: pua_dialog2_idx; Type: INDEX; Schema: public; Owner: kamailio
--

CREATE INDEX pua_dialog2_idx ON public.pua USING btree (call_id, from_tag);


--
-- Name: pua_expires_idx; Type: INDEX; Schema: public; Owner: kamailio
--

CREATE INDEX pua_expires_idx ON public.pua USING btree (expires);


--
-- Name: pua_record_idx; Type: INDEX; Schema: public; Owner: kamailio
--

CREATE INDEX pua_record_idx ON public.pua USING btree (pres_id);


--
-- Name: subscriber_username_idx; Type: INDEX; Schema: public; Owner: kamailio
--

CREATE INDEX subscriber_username_idx ON public.subscriber USING btree (username);


--
-- Name: watchers_time_status_idx; Type: INDEX; Schema: public; Owner: kamailio
--

CREATE INDEX watchers_time_status_idx ON public.watchers USING btree (inserted_time, status);


--
-- Name: xcap_account_doc_type_idx; Type: INDEX; Schema: public; Owner: kamailio
--

CREATE INDEX xcap_account_doc_type_idx ON public.xcap USING btree (username, domain, doc_type);


--
-- Name: xcap_account_doc_type_uri_idx; Type: INDEX; Schema: public; Owner: kamailio
--

CREATE INDEX xcap_account_doc_type_uri_idx ON public.xcap USING btree (username, domain, doc_type, doc_uri);


--
-- Name: xcap_account_doc_uri_idx; Type: INDEX; Schema: public; Owner: kamailio
--

CREATE INDEX xcap_account_doc_uri_idx ON public.xcap USING btree (username, domain, doc_uri);


--
-- Name: billing ondatachange_del_billing; Type: TRIGGER; Schema: public; Owner: kamailio
--

CREATE TRIGGER ondatachange_del_billing AFTER DELETE ON public.billing REFERENCING OLD TABLE AS old_table_billing FOR EACH STATEMENT EXECUTE FUNCTION public.notifyondatachange();


--
-- Name: cdr ondatachange_del_cdr; Type: TRIGGER; Schema: public; Owner: kamailio
--

CREATE TRIGGER ondatachange_del_cdr AFTER DELETE ON public.cdr REFERENCING OLD TABLE AS old_table_cdr FOR EACH STATEMENT EXECUTE FUNCTION public.notifyondatachange();


--
-- Name: subscriber ondatachange_del_subscriber; Type: TRIGGER; Schema: public; Owner: kamailio
--

CREATE TRIGGER ondatachange_del_subscriber AFTER DELETE ON public.subscriber REFERENCING OLD TABLE AS old_table_subscriber FOR EACH STATEMENT EXECUTE FUNCTION public.notifyondatachange();


--
-- Name: billing ondatachange_ins_billing; Type: TRIGGER; Schema: public; Owner: kamailio
--

CREATE TRIGGER ondatachange_ins_billing AFTER INSERT ON public.billing REFERENCING NEW TABLE AS new_table_billing FOR EACH STATEMENT EXECUTE FUNCTION public.notifyondatachange();


--
-- Name: cdr ondatachange_ins_cdr; Type: TRIGGER; Schema: public; Owner: kamailio
--

CREATE TRIGGER ondatachange_ins_cdr AFTER INSERT ON public.cdr REFERENCING NEW TABLE AS new_table_cdr FOR EACH STATEMENT EXECUTE FUNCTION public.notifyondatachange();


--
-- Name: subscriber ondatachange_ins_subscriber; Type: TRIGGER; Schema: public; Owner: kamailio
--

CREATE TRIGGER ondatachange_ins_subscriber AFTER INSERT ON public.subscriber REFERENCING NEW TABLE AS new_table_subscriber FOR EACH STATEMENT EXECUTE FUNCTION public.notifyondatachange();


--
-- Name: billing ondatachange_upd_billing; Type: TRIGGER; Schema: public; Owner: kamailio
--

CREATE TRIGGER ondatachange_upd_billing AFTER UPDATE ON public.billing REFERENCING OLD TABLE AS old_table_billing NEW TABLE AS new_table_billing FOR EACH STATEMENT EXECUTE FUNCTION public.notifyondatachange();


--
-- Name: cdr ondatachange_upd_cdr; Type: TRIGGER; Schema: public; Owner: kamailio
--

CREATE TRIGGER ondatachange_upd_cdr AFTER UPDATE ON public.cdr REFERENCING OLD TABLE AS old_table_cdr NEW TABLE AS new_table_cdr FOR EACH STATEMENT EXECUTE FUNCTION public.notifyondatachange();


--
-- Name: subscriber ondatachange_upd_subscriber; Type: TRIGGER; Schema: public; Owner: kamailio
--

CREATE TRIGGER ondatachange_upd_subscriber AFTER UPDATE ON public.subscriber REFERENCING OLD TABLE AS old_table_subscriber NEW TABLE AS new_table_subsciber FOR EACH STATEMENT EXECUTE FUNCTION public.notifyondatachange();


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT ALL ON SCHEMA public TO kamailio;


--
-- Name: TABLE billing_service; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.billing_service TO kamailio;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT ON TABLES TO kamailio;


--
-- PostgreSQL database dump complete
--

--
-- Database "postgres" dump
--

\connect postgres

--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3 (Debian 16.3-1.pgdg120+1)
-- Dumped by pg_dump version 16.3 (Debian 16.3-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

