--
-- INT_GRP_OBJ  (Type Body) 
--
--  Dependencies: 
--   COND_NODES (Type)
--   STANDARD (Package)
--   INT_GRP_OBJ (Type)
--
CREATE OR REPLACE TYPE BODY OPAL_FRA."INT_GRP_OBJ" as
CONSTRUCTOR FUNCTION int_grp_obj(name VARCHAR2) RETURN SELF AS RESULT is
begin
 self.attr_id := null;
 self.type_id := null;
 self.predefined := null;
 self.name := name;
 self.description := null;
 self.int_type:= null;
 self.ubcond := null;
 self.lbcond := null;
 self.nodes := cond_nodes();
 return;
end;
end;
/