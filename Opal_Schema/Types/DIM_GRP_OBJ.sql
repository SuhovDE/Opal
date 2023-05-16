--
-- DIM_GRP_OBJ  (Type) 
--
--  Dependencies: 
--   TREE_NODES (Type)
--   STANDARD (Package)
--
CREATE OR REPLACE TYPE OPAL_FRA."DIM_GRP_OBJ" as object
(dim_id number(9),
 attr_id number(9),
 type_id number(9),
 predefined char(1),
 name varchar2(40 char),
 description varchar2(256 char),
 nodes tree_nodes, --contains(grp_id, parent_id)
 is_grp_priv char(1),
 cr_user varchar2(30),
 CONSTRUCTOR FUNCTION dim_grp_obj(name VARCHAR2) RETURN SELF AS RESULT
)
/