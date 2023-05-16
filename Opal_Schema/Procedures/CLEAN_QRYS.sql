--
-- CLEAN_QRYS  (Procedure) 
--
--  Dependencies: 
--   ANALYZER (Package)
--   FROM_DB_UTILS (Package)
--   QRYS (Table)
--   USER_TABLES (Synonym)
--   STANDARD (Package)
--   SYS_STUB_FOR_PURITY_ANALYSIS (Package)
--
CREATE OR REPLACE procedure OPAL_FRA.clean_qrys as
 queryid qrys.id%type;
 n pls_integer;
begin
 analyzer.delquery_tmp;
 for c in (select table_name from user_tables where table_name like 'ZQRY\_%' escape '\') loop
   begin
   queryid := substr(c.table_name, 6);
   select max(1) into n from qrys where id= clean_qrys.queryid;
   if n is null then
    From_Db_Utils.drop_qry_tab(queryid);
   end if;
   exception
   when value_error then null;
   end;
 end loop;
end;
/