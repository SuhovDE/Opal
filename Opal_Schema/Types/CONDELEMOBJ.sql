--
-- CONDELEMOBJ  (Type) 
--
--  Dependencies: 
--   STANDARD (Package)
--
CREATE OR REPLACE TYPE OPAL_FRA."CONDELEMOBJ" AS OBJECT
(
    ID      NUMBER(9),
    ATTR_ID NUMBER(9),
    Oper    VARCHAR2(30),
    VALUE   VARCHAR2(255),
    SHOW    CHAR(1))
 alter type "OPAL_FRA"."CONDELEMOBJ" modify attribute (OPER varchar2(30 char)) cascade
 alter type "OPAL_FRA"."CONDELEMOBJ" modify attribute (VALUE varchar2(255 char)) cascade
/