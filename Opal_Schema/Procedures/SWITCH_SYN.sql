--
-- SWITCH_SYN  (Procedure) 
--
--  Dependencies: 
--   DBMS_OUTPUT (Synonym)
--   USER_SYNONYMS (Synonym)
--   STANDARD (Package)
--   SYS_STUB_FOR_PURITY_ANALYSIS (Package)
--
CREATE OR REPLACE procedure OPAL_FRA.switch_syn(owner_ varchar2) as
 s varchar2(4000);
begin
 for i in (select SYNONYM_NAME, TABLE_OWNER, TABLE_NAME from user_synonyms
      where table_owner<>upper(owner_) and table_owner <> 'PUBLIC'
	    and table_owner not like 'SYS%') loop
  begin
  s := 'create or replace synonym '||i.synonym_name||' for '||
   owner_||'.'||i.table_name;
  execute immediate s;
  exception
  when others then
   dbms_output.put_line(sqlerrm ||' in ');
   dbms_output.put_line(s);
  end;
 end loop;
end;
 
 
/