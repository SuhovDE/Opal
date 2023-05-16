--
-- CONDEXPROBJ  (Type) 
--
--  Dependencies: 
--   STANDARD (Package)
--
CREATE OR REPLACE TYPE OPAL_FRA."CONDEXPROBJ" AS OBJECT
(
    ID       NUMBER(9),
    optype   VARCHAR2(30),
    ParentID NUMBER(9),
    ElemID   NUMBER(9)
)
 alter type "OPAL_FRA"."CONDEXPROBJ" modify attribute (OPTYPE varchar2(30 char)) cascade
/