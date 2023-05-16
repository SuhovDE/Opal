--
-- QRYSELOBJ  (Type) 
--
--  Dependencies: 
--   DIMFILTERLIST (Type)
--   DIMLEVELLIST (Type)
--   RS4DIM_OBJLIST (Type)
--   VALFUNCTIONLIST (Type)
--   STANDARD (Package)
--
CREATE OR REPLACE TYPE OPAL_FRA."QRYSELOBJ" as OBJECT
(
    AttrId NUMBER(9),         -- Attribute Id of current Dimension/Measure item
    AttrCode VARCHAR2(50),    -- Attribute Name of current Dimension/Measure item
    AttrType char(1),
    DimLevels DimLevelLIST,   -- List of Dimension and Dimension Levels in query selection
    GrpLevels DimLevelLIST,   -- List of Group Levels in query selection
    DimFilter DimFilterLIST,  -- List of Group Items in Filter selection
    ValLevels ValFunctionLIST, -- List of Functions in Measure selection
    rs4dimlevels rs4dim_objlist,
    flags number(2),
    CONSTRUCTOR FUNCTION qryselobj RETURN SELF AS RESULT --sets all the member collections to their empty constructors
)
 alter type "OPAL_FRA"."QRYSELOBJ" modify attribute (ATTRCODE varchar2(50 char)) cascade
/