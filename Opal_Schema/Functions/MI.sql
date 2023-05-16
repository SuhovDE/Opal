--
-- MI  (Function) 
--
--  Dependencies: 
--   STANDARD (Package)
--
CREATE OR REPLACE function OPAL_FRA.mi(r1 date) return varchar2 deterministic result_cache as
--for conversion of 5-min time interval, the call much shorter than body
begin
 return to_char(R1 , 'hh24')||':'||lpad (floor (to_char(R1, 'mi')/5) * 5, 2, '0') || '-'||
  to_char(R1 +5/(24*60), 'hh24')||':'||lpad((floor (to_char(R1 +5/(24*60), 'mi')/5)) *5, 2, '0');
end;
/