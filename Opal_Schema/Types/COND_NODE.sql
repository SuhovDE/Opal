--
-- COND_NODE  (Type) 
--
--  Dependencies: 
--   STANDARD (Package)
--
CREATE OR REPLACE TYPE OPAL_FRA."COND_NODE" as object
(id number(9),
 name varchar2(20 char),
 lbound varchar2(4000 char),
 lph number(9),
 ubound varchar2(4000 char),
 uph number(9),
 description varchar2(256 char),
 ordno number(3),
 date_from date,
 date_to date,
 CONSTRUCTOR FUNCTION cond_node RETURN SELF AS RESULT)
/