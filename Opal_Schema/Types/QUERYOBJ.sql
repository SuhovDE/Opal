--
-- QUERYOBJ  (Type) 
--
--  Dependencies: 
--   CONDELEMLIST (Type)
--   CONDEXPRLIST (Type)
--   QRYSELLIST (Type)
--   STANDARD (Package)
--
CREATE OR REPLACE TYPE OPAL_FRA."QUERYOBJ" as OBJECT
(
    Name VARCHAR2(100 char),        -- Name of query
    CubeId NUMBER(9),    -- Cube identification number
    Selection QrySelLIST, -- List of Dimension and Measures used in this query
    FilterConds CondExprLIST,    -- List of filter conditions tree (without leafs)
    FilterElems CondElemLIST,     -- List of filter conditions tree (only leafs)
    description varchar2(1000 char), --Description of query,
    settings clob,
    is_private char(1),
    layout clob,
    CONSTRUCTOR FUNCTION queryobj(name VARCHAR2) RETURN SELF AS RESULT
)
/