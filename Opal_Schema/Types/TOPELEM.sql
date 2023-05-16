--
-- TOPELEM  (Type) 
--
--  Dependencies: 
--   STANDARD (Package)
--
CREATE OR REPLACE TYPE OPAL_FRA."TOPELEM" AS OBJECT
(
  Dimfield VARCHAR2(30),
  factfield VARCHAR2(30),
  Absprc NUMBER(1),
  toplevel NUMBER(9),
  Showrest NUMBER(1),
  rdimsqlval VARCHAR2(30),
  strict NUMBER(1)
)
 alter type "OPAL_FRA"."TOPELEM" modify attribute (DIMFIELD varchar2(30 char)) cascade
 alter type "OPAL_FRA"."TOPELEM" modify attribute (FACTFIELD varchar2(30 char)) cascade
 alter type "OPAL_FRA"."TOPELEM" modify attribute (RDIMSQLVAL varchar2(30 char)) cascade
/