CREATE FUNCTION NotifyOnDataChange()
  RETURNS trigger  
AS $BODY$ 
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
$BODY$ LANGUAGE plpgsql;

CREATE TRIGGER OnDataChange_INS_subscriber
  AFTER INSERT ON subscriber
  REFERENCING NEW TABLE AS new_table_subscriber
  FOR EACH STATEMENT EXECUTE FUNCTION NotifyOnDataChange();

CREATE TRIGGER OnDataChange_UPD_subscriber
  AFTER UPDATE ON subscriber
  REFERENCING OLD TABLE AS old_table_subscriber NEW TABLE AS new_table_subsciber
  FOR EACH STATEMENT EXECUTE FUNCTION NotifyOnDataChange();

CREATE TRIGGER OnDataChange_DEL_subscriber
  AFTER DELETE ON subscriber
  REFERENCING OLD TABLE AS old_table_subscriber
  FOR EACH STATEMENT EXECUTE FUNCTION NotifyOnDataChange();

CREATE TRIGGER OnDataChange_INS_billing
  AFTER INSERT ON billing
  REFERENCING NEW TABLE AS new_table_billing
  FOR EACH STATEMENT EXECUTE FUNCTION NotifyOnDataChange();

CREATE TRIGGER OnDataChange_UPD_billing
  AFTER UPDATE ON billing
  REFERENCING OLD TABLE AS old_table_billing NEW TABLE AS new_table_billing
  FOR EACH STATEMENT EXECUTE FUNCTION NotifyOnDataChange();

CREATE TRIGGER OnDataChange_DEL_billing
  AFTER DELETE ON billing
  REFERENCING OLD TABLE AS old_table_billing
  FOR EACH STATEMENT EXECUTE FUNCTION NotifyOnDataChange();

CREATE TRIGGER OnDataChange_INS_cdr
  AFTER INSERT ON cdr
  REFERENCING NEW TABLE AS new_table_cdr
  FOR EACH STATEMENT EXECUTE FUNCTION NotifyOnDataChange();

CREATE TRIGGER OnDataChange_UPD_cdr
  AFTER UPDATE ON cdr
  REFERENCING OLD TABLE AS old_table_cdr NEW TABLE AS new_table_cdr
  FOR EACH STATEMENT EXECUTE FUNCTION NotifyOnDataChange();

CREATE TRIGGER OnDataChange_DEL_cdr
  AFTER DELETE ON cdr
  REFERENCING OLD TABLE AS old_table_cdr
  FOR EACH STATEMENT EXECUTE FUNCTION NotifyOnDataChange();
