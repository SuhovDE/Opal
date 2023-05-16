--
-- SET_SESSION_PARAMETERS  (Procedure) 
--
--  Dependencies: 
--   STANDARD (Package)
--   SYS_STUB_FOR_PURITY_ANALYSIS (Package)
--
CREATE OR REPLACE PROCEDURE OPAL_FRA.set_Session_Parameters
   AS
BEGIN
   execute immediate 'alter session set NLS_LANGUAGE           = ''GERMAN''';
   execute immediate 'alter session set NLS_TERRITORY          = ''GERMANY''';
   execute immediate 'alter session set NLS_SORT               = ''GERMAN''';

   execute immediate 'alter session set db_file_multiblock_read_count = 8';
   execute immediate 'alter session set optimizer_index_caching = 90';
   execute immediate 'alter session set optimizer_index_cost_adj = 50';
END set_Session_Parameters;
 
 
/