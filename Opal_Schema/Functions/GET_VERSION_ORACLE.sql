--
-- GET_VERSION_ORACLE  (Function) 
--
--  Dependencies: 
--   DBMS_UTILITY (Synonym)
--   V$VERSION (Synonym)
--   STANDARD (Package)
--   SYS_STUB_FOR_PURITY_ANALYSIS (Package)
--
CREATE OR REPLACE FUNCTION OPAL_FRA.GET_VERSION_ORACLE (prod_name varchar2 := 'Oracle')
 return varchar2 is
 cursor bb is
  select banner from v$VERSION where upper(banner) like upper(prod_name)||'%';
 ret v$VERSION.banner%type;
 cmp v$VERSION.banner%type;
begin
 if prod_name='Oracle' then
  dbms_utility.db_version(ret, cmp);
  ret := prod_name||' '||ret;
 else
  open bb;
  fetch bb into ret;
  close bb;
 end if;
 return ret;
end;
 
 
/