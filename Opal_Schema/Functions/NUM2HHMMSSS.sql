--
-- NUM2HHMMSSS  (Function) 
--
--  Dependencies: 
--   STANDARD (Package)
--
CREATE OR REPLACE FUNCTION OPAL_FRA.num2hhmmsss(hhmmss number, sep varchar2 := ':') RETURN varchar2 deterministic IS
 hh pls_integer := trunc((hhmmss/1440+1/86400/10)*24);
 mm number := (hhmmss/1440*24-hh)*60;
 ss pls_integer := (mm-floor(mm))*60;
BEGIN
 if hhmmss is null then return null; end if;
 return lpad(hh, greatest(length(hh), 2), '0')||sep||lpad(floor(mm), 2, '0')||sep||lpad(ss, 2, '0');
END;
/