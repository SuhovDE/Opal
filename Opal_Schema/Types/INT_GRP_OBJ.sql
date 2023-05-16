--
-- INT_GRP_OBJ  (Type) 
--
--  Dependencies: 
--   COND_NODES (Type)
--   STANDARD (Package)
--
CREATE OR REPLACE TYPE OPAL_FRA."INT_GRP_OBJ" as object
(attr_id number(9),
 type_id number(9),
 predefined char(1),
 name varchar2(20 char),
 description varchar2(256 char),
 int_type number(1), --1 or 2
 ubcond varchar2(4000 char),
 lbcond varchar2(4000 char), --at the moment is filled automatically
 nodes cond_nodes, --contains list of condition leafs
 is_grp_priv char(1),
 cr_user varchar2(30),
 CONSTRUCTOR FUNCTION int_grp_obj(name VARCHAR2) RETURN SELF AS RESULT
)
/