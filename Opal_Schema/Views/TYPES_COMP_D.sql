--
-- TYPES_COMP_D  (View) 
--
--  Dependencies: 
--   DIM_LEVELS (Table)
--   TYPES_COMP (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.TYPES_COMP_D
(TYPE_ID, COMP_TYPE_ID, DIM_ID_T, DIM_ID_C)
BEQUEATH DEFINER
AS 
select
 tc.TYPE_ID, tc.COMP_TYPE_ID, d1.dim_id dim_id_t, d2.dim_id dim_id_c
from types_comp tc, dim_levels d1, dim_levels d2
where tc.type_id=d1.id and tc.comp_type_id=d2.id;