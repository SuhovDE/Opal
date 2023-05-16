--
-- QUERYOBJ  (Type Body) 
--
--  Dependencies: 
--   CONDELEMLIST (Type)
--   CONDEXPRLIST (Type)
--   QRYSELLIST (Type)
--   STANDARD (Package)
--   QUERYOBJ (Type)
--
CREATE OR REPLACE TYPE BODY OPAL_FRA."QUERYOBJ" as
CONSTRUCTOR FUNCTION queryobj(name VARCHAR2) RETURN SELF AS RESULT is
begin
 self.Name:= name;
 self.CubeId := null;
 self.Selection := QrySelLIST();
 self.FilterConds := CondExprLIST();
 self.FilterElems := CondElemLIST();
 self.description := '';
 self.settings := empty_clob();
 self.layout := empty_clob();
 return;
end;
end;
/