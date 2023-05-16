--
-- GRP_D_  (View) 
--
--  Dependencies: 
--   DIM_LEVELS (Table)
--   GRP_D (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.GRP_D_
(GRP_ID, IS_LEAF, GRP_TYPE, DIM_LEV_ID, DIM_LEV_CODE, 
 COND_ID, ORDNO)
BEQUEATH DEFINER
AS 
select g."GRP_ID",g."IS_LEAF",g."GRP_TYPE",g."DIM_LEV_ID",g."DIM_LEV_CODE",g."COND_ID", coalesce(l.ordno, 0) ordno
 from grp_d g, dim_levels l
 where g.dim_lev_id=l.id and dim_lev_code is not null;