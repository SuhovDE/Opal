--
-- GET_PARAM_VALUE  (Function) 
--
--  Dependencies: 
--   T_PARAMETERS (Type)
--   DBMS_STANDARD (Package)
--   STANDARD (Package)
--   SYS_STUB_FOR_PURITY_ANALYSIS (Package)
--
CREATE OR REPLACE FUNCTION OPAL_FRA."GET_PARAM_VALUE" ( p_Params     in  t_Parameters,
                          p_Param_Code in  varchar2 ) return varchar2
as
   v_Param_Value  varchar2(1024);
 msg            varchar2(2048);
begin
   select Value into v_Param_Value from table(p_Params)
      where upper(Name) = upper(p_Param_Code);
   return v_Param_Value;
exception
   when NO_DATA_FOUND then
      msg := 'Parameter "' || p_Param_Code || '" is not defined';
      raise_application_error (-20100, msg, TRUE);
END get_Param_Value;
 
 
/