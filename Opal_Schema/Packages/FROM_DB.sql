--
-- FROM_DB  (Package) 
--
--  Dependencies: 
--   DATASETS (Table)
--   GROUPS (Table)
--   QRYS (Table)
--   QRYS_SEL (Table)
--   STANDARD (Package)
--
CREATE OR REPLACE PACKAGE OPAL_FRA.From_Db AS
 TYPE ret_cursor IS REF CURSOR;
 curr_rowcount integer;
 qry_not_exists exception;
 pragma exception_init(qry_not_exists, -20200);
 qry_not_exists_number pls_integer := -20200;
 function get_is_real_group_how(grp_id_ GROUPS.ID%TYPE, how_ qrys_sel.how%type) return pls_integer; --only for usage in queries
 procedure gen_exec_qry(qry_id_ qrys.id%type, res_cursor OUT ret_cursor);
--do_create=1 - add "create table" to the query, as before, 0 - not add
 procedure gen_qry(qry_id_ qrys.id%type, qry in out nocopy varchar2,
  do_create pls_integer := 1);
 procedure exec_qry(qry varchar2, qry_id_ qrys.id%type:=null);
--function, by default, gets query without "create table".
 function get_gen_qry(qry_id_ qrys.id%type, do_create pls_integer := 0)
  return varchar2;
--
 PROCEDURE get_dataset(qry_id_ datasets.qry_id%type, ds_lvl datasets.rng%type, is_cursor OUT pls_integer,
  res_cursor IN OUT ret_cursor, ds_name OUT datasets.lvl_name%type);
 PROCEDURE get_cursor(qry_id_ NUMBER, res_cursor IN OUT ret_cursor);
 PROCEDURE get_cursor_by_abbr(qry_abbr VARCHAR2, res_cursor IN OUT ret_cursor);
 PROCEDURE get_qry(qry_id_ NUMBER, qry IN OUT NOCOPY varchar2);
 function get_main_qry(qry_tab varchar2, rng pls_integer := 0) return varchar2;
END;
/