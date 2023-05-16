--
-- VALFUNCTIONOBJ  (Type) 
--
--  Dependencies: 
--   STANDARD (Package)
--
CREATE OR REPLACE TYPE OPAL_FRA."VALFUNCTIONOBJ" as OBJECT
(
    FnctId VARCHAR2(20) -- Measure Function identifier (Only for Measures)
)
 alter type "OPAL_FRA"."VALFUNCTIONOBJ" modify attribute (FNCTID varchar2(20 char)) cascade
/