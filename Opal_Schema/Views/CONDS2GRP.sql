--
-- CONDS2GRP  (View) 
--
--  Dependencies: 
--   CONDS (Table)
--   GRP_C (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.CONDS2GRP
(LEAF_ID, GRP_ID)
BEQUEATH DEFINER
AS 
select c.id leaf_id, gc.grp_id
 from conds c join grp_c gc on gc.cond_id=c.parent_id;