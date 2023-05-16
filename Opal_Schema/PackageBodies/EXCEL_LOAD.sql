--
-- EXCEL_LOAD  (Package Body) 
--
--  Dependencies: 
--   EXCEL_LOAD (Package)
--   ERROR_CODES (Package)
--   DBMS_STANDARD (Package)
--   STANDARD (Package)
--
CREATE OR REPLACE PACKAGE BODY OPAL_FRA.Excel_Load AS

FUNCTION check_Code_Length ( p_String IN varchar2, p_Name IN varchar2) return varchar2
   IS
   v_String  varchar2(32767);
	msg       varchar2(2048);
BEGIN
   v_String := TRIM(p_String);

   if (v_String is null) or (LENGTH(v_String) NOT BETWEEN 1 and 15) then
      msg := p_Name || '-Kode "' || v_String ||
             '" hat eine unrichtige Lõnge. Die zulõssige Lõnge ist 1...15 Symbole.';
      raise_application_error (Error_Codes.FIELD_FORMAT_IS_WRONG_N, msg, TRUE);
   end if;
   RETURN v_String;
END check_Code_Length;

----------------------------------------------------------------------

FUNCTION get_ID ( p_Code        IN varchar2,
                  p_Table_Name  IN varchar2) return number
   IS
   v_ID           number;
   v_Code         varchar2(2048);
   str_SQL        varchar2(512);
   v_Entity_Name  varchar2(512);
	msg            varchar2(2048);
   err_num        NUMBER;
BEGIN
   v_ID := null;
--   v_Entity_Name := get_Entity_Name(p_Table_Name, 'German');
   v_Entity_Name := p_Table_Name;

   v_Code := check_Code_Length(p_Code, v_Entity_Name);

   str_SQL := 'select ' || p_Table_Name || '_ID from '
              || p_Table_Name
              || ' where Code = :1';

   BEGIN
      execute immediate str_SQL into v_ID using v_Code;
   EXCEPTION
      when NO_DATA_FOUND then
         msg := v_Entity_Name || ' "' || v_Code
             || '" gibt es nicht.';
      raise_application_error (Error_codes.KEY_NOT_FOUND_N, msg, TRUE);
      WHEN OTHERS THEN
           err_num := SQLCODE;
         msg := 'HARD ERROR in get_ID. Table "' || p_Table_Name
                || '" gibt es nicht. SQLCODE=' || err_num;
      raise_application_error (Error_codes.TABLE_NOT_FOUND_N, msg, TRUE);

   END;

   RETURN v_ID;
END get_ID;

END Excel_Load;
/