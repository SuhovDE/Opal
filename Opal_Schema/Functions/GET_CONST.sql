--
-- GET_CONST  (Function) 
--
--  Dependencies: 
--   PARAMS (Table)
--   STANDARD (Package)
--   SYS_STUB_FOR_PURITY_ANALYSIS (Package)
--
CREATE OR REPLACE FUNCTION OPAL_FRA.get_const(id_ varchar) RETURN varchar IS
  tmpVar VARCHAR(30);
BEGIN
  select parvalue into tmpvar from params where taskid='CONST' and parid=upper(id_);
  return tmpvar;
END;
/