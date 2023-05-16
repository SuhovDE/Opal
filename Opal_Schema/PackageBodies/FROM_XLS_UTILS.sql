--
-- FROM_XLS_UTILS  (Package Body) 
--
--  Dependencies: 
--   FROM_XLS_UTILS (Package)
--   CUBES (Table)
--   ERROR_CODES (Package)
--   TREE_FNC (Package)
--   DBMS_STANDARD (Package)
--   STANDARD (Package)
--
CREATE OR REPLACE PACKAGE BODY OPAL_FRA.From_xls_utils AS

FUNCTION get_ID ( p_Code        IN varchar2,
                  p_Table_Name  IN varchar2,
                  p_col varchar2 default 'c.name.abbr') return binary_integer
   IS
   v_Code         varchar2(2048);
   str_SQL        varchar2(512);
   v_Entity_Name  varchar2(512);
   msg            varchar2(2048);
   err_num        binary_integer;
   v_ID binary_integer;
BEGIN
--   v_Entity_Name := get_Entity_Name(p_Table_Name, 'German');
   if p_code is null then return null; end if;
   v_Entity_Name := p_Table_Name;
   v_Code := check_Code_Length(p_Code, v_Entity_Name);

   str_SQL := 'select ID from '
              || p_Table_Name
              || ' c where '||p_col||' = :1';

   BEGIN
      execute immediate str_SQL into v_ID using v_Code;
   EXCEPTION
      when NO_DATA_FOUND then
         msg := v_Entity_Name || ' "' || v_Code || '" gibt es nicht.';
      raise_application_error (error_codes.KEY_NOT_FOUND_N, msg, TRUE);
      when too_many_rows then
         msg := v_Entity_Name || ' "' || v_Code || '" gibt es mehr als ein.';
      raise_application_error (error_codes.more_than_1_key_n, msg, TRUE);
      WHEN OTHERS THEN
         err_num := SQLCODE;
         msg := 'HARD ERROR in '||str_sql||'. Table "' || p_Table_Name
                || '" gibt es nicht. SQLCODE=' || err_num;
      raise_application_error (error_codes.TABLE_NOT_FOUND_N, msg, TRUE);
   END;
   RETURN v_ID;
END get_ID;
---------------------------------------------------------------------
FUNCTION check_String_Length ( p_String IN varchar2, p_Name IN varchar2,
            p_Length IN Number ) return varchar2 IS
   v_String  varchar2(32767);
	msg       varchar2(2048);
BEGIN
   v_String := TRIM(p_String);
   if (v_String is null) or (LENGTH(v_String) NOT BETWEEN 1 and p_Length) then
      msg := p_Name || '"' || v_String ||
             '" hat eine unrichtige Lõnge. Die zulõssige Lõnge ist 1...'
             || TO_CHAR(p_Length) || ' Symbole.';
      raise_application_error (error_codes.FIELD_FORMAT_IS_WRONG_N, msg, TRUE);
   end if;
   RETURN v_String;
END check_String_Length;

----------------------------------------------------------------------

FUNCTION check_Code_Length ( p_String IN varchar2, p_Name IN varchar2) return varchar2
   IS
   v_String  varchar2(32767);
	msg       varchar2(2048);
BEGIN
   v_String := TRIM(p_String);

   if (v_String is null) or (LENGTH(v_String) NOT BETWEEN 1 and tree_fnc.abbr_len) then
      msg := p_Name || '-Kode "' || v_String ||
             '" hat eine unrichtige Lõnge. Die zulõssige Lõnge ist 1..'||
			 tree_fnc.abbr_len||' Symbole.';
      raise_application_error (error_codes.FIELD_FORMAT_IS_WRONG_N, msg, TRUE);
   end if;
   RETURN v_String;
END check_Code_Length;

----------------------------------------------------------------------

FUNCTION check_Number_Length ( p_Number IN NUMBER, p_Name IN varchar2) return number
   IS
	v_Number  number;
	msg       varchar2(2048);
BEGIN
   v_Number := p_Number;
   if (v_Number is null) or (v_Number NOT BETWEEN 0 and 999999) then
      msg := p_Name || '-Number "' || v_Number ||
             '" ist nicht richtig. Der zulõssige Wert ist 0 ...999999.';
      raise_application_error (error_codes.FIELD_FORMAT_IS_WRONG_N, msg, TRUE);
   end if;
   RETURN v_Number;
END check_Number_Length;

----------------------------------------------------------------------

FUNCTION check_Month ( p_Month IN NUMBER) return number IS
	v_Month  number;
	msg      varchar2(2048);
BEGIN
   v_Month := p_Month;
   if (v_Month is null) or (v_Month NOT BETWEEN 0 and 12) then
      msg := 'Monat "' || v_Month ||
             '" ist nicht richtig. Der zulõssige Wert ist 0...12.';
      raise_application_error (error_codes.FIELD_FORMAT_IS_WRONG_N, msg, TRUE);
   end if;
   RETURN v_Month;
END check_Month;

----------------------------------------------------------------------

PROCEDURE delete_Global is
BEGIN
   delete from cubes;
   commit;
END delete_Global;

----------------------------------------------------------------------
procedure signal_dupval(msg varchar2) is
begin
 raise_application_error (Error_Codes.KEY_EXISTS_N, msg || '" gibt es schon.', TRUE);
end;
----------------------------------------------------------------------
END From_xls_utils;
/