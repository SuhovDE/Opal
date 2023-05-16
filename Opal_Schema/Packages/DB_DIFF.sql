--
-- DB_DIFF  (Package) 
--
--  Dependencies: 
--   REF_PROCESS (Synonym)
--   STANDARD (Package)
--
CREATE OR REPLACE PACKAGE OPAL_FRA.DB_DIFF AS
  curr_db varchar2(30);
  oracle_db constant varchar2(30) := 'ORACLE';
  mysql_db constant varchar2(30) := 'MYSQL';
  sqlserver_db constant varchar2(30) := 'SQLSERVER';
  date_lit_msk constant varchar2(30) := 'YYYY-MM-DD';
  function get_curr_db return curr_db%type;
  function get_substr return varchar2;
  function get_lateral return varchar2;
  function get_dual return varchar2;
  function get_nvl return varchar2;
  function get_on return varchar2;
  function get_date(dt date) return varchar2; --date literal
  function get_date(dt varchar2, msk varchar2 := ref_process.day_mask) return varchar2; --date literal
  function get_top(n integer) return varchar2;
  function get_limit(n integer) return varchar2;
  procedure set_limit(qry in out nocopy varchar2, n integer);
END;
/