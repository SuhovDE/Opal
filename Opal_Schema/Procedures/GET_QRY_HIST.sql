--
-- GET_QRY_HIST  (Procedure) 
--
--  Dependencies: 
--   HIST_ALL (Synonym)
--   QRYS (Table)
--   STANDARD (Package)
--   SYS_STUB_FOR_PURITY_ANALYSIS (Package)
--
CREATE OR REPLACE procedure OPAL_FRA.get_qry_hist(qry_name qrys.abbr%type, cur out sys_refcursor) is
 i pls_integer := instr(qry_name, chr(1));
 abbr_ qrys.abbr%type := case i when 0 then qry_name else substr(qry_name, 1, i-1) end ;
begin
 open cur for
  select op_term, op_time, abbr_ abbr,
    max(case when col_name='DURATION' then to_number(new_v) end) duration,
    max(case when col_name='RECCOUNT' then to_number(new_v) end) RECCOUNT
   from hist_all where table_name='QRYS' and (pkc=abbr_ or pkc like abbr_||chr(1)||'%')
   group by id, op_term, op_time
   order by op_time;
end;
/