--
-- TREE_NODE  (Type) 
--
--  Dependencies: 
--   STANDARD (Package)
--
CREATE OR REPLACE TYPE OPAL_FRA."TREE_NODE" as object
(id number(9), parent_id number(9), ordno integer, rest char(1),
 date_from date, date_to date)
/