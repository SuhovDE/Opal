--
-- DB_DIFF  (Package Body) 
--
--  Dependencies: 
--   DB_DIFF (Package)
--   PARAMS (Table)
--   REF_PROCESS (Synonym)
--   DBMS_STANDARD (Package)
--   STANDARD (Package)
--
CREATE OR REPLACE PACKAGE BODY OPAL_FRA.DB_DIFF AS
 lat constant varchar2(30) := 'left outer join lateral';
 app constant varchar2(30) := 'outer apply';
 function get_curr_db return curr_db%type is
 begin
  return curr_db;
 end;
 function get_substr return varchar2 is
 begin
  return case curr_db when oracle_db then 'substr' else 'substring' end;
 end;
 function get_lateral return varchar2 is
 begin
  return case curr_db
   when oracle_db then lat
   when mysql_db  then lat
                  else app
   end;
 end;
 function get_dual return varchar2 is
 begin
  return case curr_db when oracle_db then 'from dual' end;
 end;
 function get_nvl return varchar2 is
 begin
  return case curr_db when sqlserver_db then 'isnull' else 'coalesce' end;
 end;
function get_on return varchar2 is
 begin
  return case when get_lateral=lat then 'on 1=1' end;
 end;
 function get_date(dt date) return varchar2 is
  ret constant varchar2(30) := ''''||to_char(dt, date_lit_msk)||'''';
 begin
  return case curr_db
   when oracle_db then 'date'||ret
                  else ret
   end;
 end;
 function get_date(dt varchar2, msk varchar2) return varchar2 is
  dt_ constant date := to_date(dt, msk);
  tst date := get_date(dt_);
 begin
--app_log.log_messageex('DT', dt||':'||msk||'=>'||to_char(tst, 'yyy-mm-dd'), dbms_utility.format_call_stack);
  return get_date(dt_);
 end;
 function get_top(n integer) return varchar2 is
 begin
  return case curr_db when sqlserver_db then 'top '||n end;
 end;
 function get_limit(n integer) return varchar2 is
 begin
  return case curr_db when mysql_db then 'limit '||n  when oracle_db then 'fetch first '||n||' rows only' end;
 end;
 procedure set_limit(qry in out nocopy varchar2, n integer) is
  sel constant varchar2(30) := 'select ';
  i pls_integer := instr(lower(qry), sel);
  s varchar2(1);
 begin
  if i>0 then
   i := i+length(sel);
   qry := substr(qry, 1, i-1)||get_top(n)||' '||substr(qry, i);
  end if;
  if substr(qry, -1)=')' then s := ')'; qry := substr(qry, 1, length(qry)-1); end if;
  qry := qry||' '||get_limit(n)||s;
 end;
BEGIN
 select nvl(max(upper(parvalue)), oracle_db) into curr_db
  from params where taskid='GEN' and parid='DB';
 if curr_db not in (oracle_db, mysql_db, sqlserver_db) then
  raise_application_error(-20104, 'Invalid DB '||curr_db||'. Allowed are ORACLE, MYSQL or SQLSERVER');
 end if;
END;
/