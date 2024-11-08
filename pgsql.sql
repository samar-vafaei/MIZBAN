CREATE FUNCTION UpdateCreditOfSubscriber()
  RETURNS trigger  
AS $BODY$ 
BEGIN
	WITH temp AS (
		SELECT new_table_acc.from_uri AS username, (subscriber.credit-new_table_acc.duration*billing.call_rates) AS credit
		FROM new_table_acc 
		JOIN billing 
		ON country_code=LEFT(to_uri,7)
		JOIN subscriber 
		ON from_uri=username)	
	UPDATE subscriber SET subscriber.credit=temp.credit FROM temp WHERE subscriber.username = temp.username;
	
  RETURN NEW;
END;
$BODY$ LANGUAGE plpgsql;


CREATE TRIGGER OnDataChange_INS_acc
  AFTER INSERT ON acc
  REFERENCING NEW TABLE AS new_table_acc
  FOR EACH STATEMENT EXECUTE FUNCTION UpdateCreditOfSubscriber();  
  
  
  
 
	
	
	
		


