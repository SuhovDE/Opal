--
-- NAMES  (Type) 
--
--  Dependencies: 
--   STANDARD (Package)
--
CREATE OR REPLACE TYPE OPAL_FRA."NAMES" AS OBJECT
(
  suf varchar2(20),
  MAXL_suf NUMBER(2),
  ABBR VARCHAR2(20),
  MAXL_ABBR NUMBER(2),
  SHORT VARCHAR2(256),
  MAXL_SHORT NUMBER(3),
  FULL VARCHAR2(4000),
  MAXL_FULL NUMBER(4),
  constructor function names(abbr varchar2) return self as result,
  constructor function names(abbr varchar2, short varchar2) return self as result,
  constructor function names(abbr varchar2, short varchar2, suf varchar2)
   return self as result,
  constructor function names(abbr varchar2, maxl_abbr pls_integer,
    short varchar2, maxl_short pls_integer, suf varchar2, maxl_suf pls_integer)
   return self as result
)
 alter type "OPAL_FRA"."NAMES" modify attribute abbr varchar2(40 char) cascade
 alter type "OPAL_FRA"."NAMES" modify attribute suf varchar2(40 char) cascade
 alter type "OPAL_FRA"."NAMES" modify attribute (FULL varchar2(4000 char)) cascade
 alter type "OPAL_FRA"."NAMES" modify attribute (SHORT varchar2(256 char)) cascade
/