--
-- IS_QRYS_ADMIN  (Function) 
--
--  Dependencies: 
--   TOOLS4USER (Synonym)
--   STANDARD (Package)
--   SYS_STUB_FOR_PURITY_ANALYSIS (Package)
--
CREATE OR REPLACE FUNCTION OPAL_FRA.is_qrys_admin RETURN pls_integer IS
BEGIN
  return case when tools4user.am_i_adm_opal then 1 else 0 end;
END;
 
/