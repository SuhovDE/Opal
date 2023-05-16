--
-- DIM_GRP_OBJ  (Type Body) 
--
--  Dependencies: 
--   TREE_NODES (Type)
--   STANDARD (Package)
--   DIM_GRP_OBJ (Type)
--
CREATE OR REPLACE TYPE BODY OPAL_FRA."DIM_GRP_OBJ" as
CONSTRUCTOR FUNCTION dim_grp_obj(name VARCHAR2) RETURN SELF AS RESULT is
begin
 self.dim_id := null;
 self.attr_id := null;
 self.type_id := null;
 self.predefined := null;
 self.name := name;
 self.description := null;
 self.nodes := tree_nodes();
 return;
end;
end;
/