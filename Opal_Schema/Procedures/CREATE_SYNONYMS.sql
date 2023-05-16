--
-- CREATE_SYNONYMS  (Procedure) 
--
--  Dependencies: 
--   PARAMS (Table)
--   ALL_OBJECTS (Synonym)
--   ALL_TABLES (Synonym)
--   PLITBLM (Synonym)
--   USER_SYNONYMS (Synonym)
--   DBMS_STANDARD (Package)
--   STANDARD (Package)
--   SYS_STUB_FOR_PURITY_ANALYSIS (Package)
--
CREATE OR REPLACE procedure OPAL_FRA.create_synonyms(data_scheme varchar2 := null, do_force boolean := false) as
 god_allow varchar2(30);
 data_schema varchar2(30);
 cursor oo is
  select owner, object_name from all_objects o where
   owner = data_schema and object_name not like 'BIN$%' and
   not exists(select 1 from user_synonyms where
    table_owner=o.owner and table_name=o.object_name)
    and  object_type in ('TABLE', 'VIEW', 'PACKAGE', 'FUNCTION', 'PROCEDURE', 'SEQUENCE', 'TYPE','SYNONYM')
    and not (object_type='TYPE' and object_name like 'S%=%');
 type numchartab is table of pls_integer index by varchar2(30);
 type chartab is table of varchar2(30);
 syn_list constant chartab := chartab('VER','PARAMS','MULTIPLIER','UNLOADED_IDS');
 decode_syn numchartab;
 suf constant varchar2(30) := '_DATA';
 tmp varchar2(30);
 i pls_integer := syn_list.first;
begin
 select nvl(max(parvalue), 'MOVEMENTS') into god_allow from params
  where parid='GOD_ALLOW' and taskid='GEN';
 while i is not null loop
  decode_syn(syn_list(i)) := 1;
  i := syn_list.next(i);
 end loop;
 select owner into data_schema from all_tables where
  table_name=god_allow and owner != user and
   (data_scheme is null or owner=upper(data_scheme));
 for o in oo loop
  begin
   tmp := o.object_name;
   if decode_syn.exists(o.object_name) then
    tmp :=tmp||suf;
   end if;
   execute immediate 'create or replace synonym '||tmp||' for '||
    o.owner||'.'||o.object_name;
  exception
  when others then
    if sqlcode in (-955) and do_force then
     null;
    else
     raise_application_error(-20199, o.object_name||':'||sqlerrm);
    end if;
  end;
 end loop;
exception
when no_data_found then
 raise_application_error(-20199,
  'No table with agreed name '||god_allow||
    ' is accessible in the other schemes '||data_scheme, true);
when too_many_rows then
 raise_application_error(-20199,
  'More than 1 table with agreed name '||god_allow||
   ' are accessible in the other schemes', true);
end;
/