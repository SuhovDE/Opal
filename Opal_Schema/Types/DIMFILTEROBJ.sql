--
-- DIMFILTEROBJ  (Type) 
--
--  Dependencies: 
--   STANDARD (Package)
--
CREATE OR REPLACE TYPE OPAL_FRA."DIMFILTEROBJ" as OBJECT
(
    GroupId NUMBER(9) -- GroupId of Group item (only for Dimensions, Dimension Levels and Group Level)
);
/