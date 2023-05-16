--
-- QRYSELOBJ  (Type Body) 
--
--  Dependencies: 
--   DIMFILTERLIST (Type)
--   DIMLEVELLIST (Type)
--   RS4DIM_OBJLIST (Type)
--   VALFUNCTIONLIST (Type)
--   STANDARD (Package)
--   QRYSELOBJ (Type)
--
CREATE OR REPLACE TYPE BODY OPAL_FRA."QRYSELOBJ" as
CONSTRUCTOR FUNCTION qryselobj RETURN SELF AS RESULT is
begin
 self.AttrId := null;
 self.AttrCode := null;
 self.attrtype := null;
 self.DimLevels := DimLevelLIST();
 self.GrpLevels := DimLevelLIST();
 self.DimFilter := DimFilterLIST();
 self.ValLevels := ValFunctionLIST();
 self.rs4dimlevels := rs4dim_objlist();
 self.flags := 0;
 return;
end;
end;
/