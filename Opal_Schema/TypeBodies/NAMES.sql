--
-- NAMES  (Type Body) 
--
--  Dependencies: 
--   STANDARD (Package)
--   NAMES (Type)
--
CREATE OR REPLACE TYPE BODY OPAL_FRA."NAMES" as
CONSTRUCTOR FUNCTION names(abbr VARCHAR2) RETURN SELF AS RESULT is
begin
 self.abbr:= abbr;
 self.MAXL_ABBR := 40;
 self.suf:= self.abbr;
 self.MAXL_suf := self.MAXL_suf;
return;
end;
CONSTRUCTOR FUNCTION names(abbr VARCHAR2, short varchar2 ) RETURN SELF AS RESULT is
begin
 self:= names(abbr);
 self.short:= short;
 self.MAXL_short := 256;
return;
end;
CONSTRUCTOR FUNCTION names(abbr VARCHAR2, short varchar2, suf varchar2 )
 RETURN SELF AS RESULT is
begin
 self:= names(abbr, short);
 self.suf:= suf;
 self.MAXL_suf := 40;
return;
end;
constructor function names(abbr varchar2, maxl_abbr pls_integer,
  short varchar2, maxl_short pls_integer, suf varchar2, maxl_suf pls_integer)
 return self as result is
begin
 self.abbr:= abbr;
 self.MAXL_ABBR := maxl_abbr;
 self.short:= short;
 self.MAXL_short := maxl_short;
 self.suf:= suf;
 self.MAXL_suf := MAXL_suf;
return;
end;
end;
/