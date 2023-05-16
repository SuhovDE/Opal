--
-- RS4DIM_OBJ  (Type) 
--
--  Dependencies: 
--   STANDARD (Package)
--
CREATE OR REPLACE TYPE OPAL_FRA."RS4DIM_OBJ" as object (
dim_lev_id integer,
rs_code varchar2(15)
)
 alter type "OPAL_FRA"."RS4DIM_OBJ" modify attribute (RS_CODE varchar2(15 char)) cascade
/