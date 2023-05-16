--
-- COND_NODE  (Type Body) 
--
--  Dependencies: 
--   COND_NODE (Type)
--
CREATE OR REPLACE TYPE BODY OPAL_FRA."COND_NODE" as
CONSTRUCTOR FUNCTION cond_node RETURN SELF AS RESULT is
begin
 self.id := null;
 self.name := name;
 self.lbound := null;
 self.lph := null;
 self.ubound := null;
 self.uph := null;
 self.description := null;
 self.ordno:= null;
 return;
end;
end;
/