--
-- QRYS_IU  (Procedure) 
--
--  Dependencies: 
--   SYS_UTILS (Package)
--   ANALYZER (Package)
--   TOOLS4USER (Synonym)
--   STANDARD (Package)
--   SYS_STUB_FOR_PURITY_ANALYSIS (Package)
--
CREATE OR REPLACE procedure OPAL_FRA.qrys_iu(op_user out nocopy varchar2, op_host out nocopy varchar2,
 op_term out nocopy varchar2, op_time out nocopy date) is
begin
 op_user := TOOLS4USER.osuser;
 op_host := sys_context('USERENV','HOST');
 op_term := analyzer.cos;
 op_time := sysdate;
end;
/