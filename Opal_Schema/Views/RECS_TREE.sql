--
-- RECS_TREE  (View) 
--
--  Dependencies: 
--   RECS2CUBES (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.RECS_TREE
(CUBE_ID, ELEM_REC_ID, LVL, REC, RNG, 
 LVL_NAME)
BEQUEATH DEFINER
AS 
select cube_id, rec1 elem_rec_id, lvl, rec,
   case when rng='N' then 2 when rng like '%N%' then 3 when rng like '%C%' then 2 else 1 end rng,
   lvl_name
from (
with /*recursive*/ ftree(elem_rec_id, parent_id, cube_id, lvl, rng, lvl_name, rec1, rec) as (
 select t.elem_rec_id, t.parent_id, t.cube_id, 1 lvl, case when t.how_much<>'1' then t.how_much end rng,t.lvl_name, elem_rec_id rec1, elem_rec_id rec
  from recs2cubes t  where parent_id is null
 union all
 select t.elem_rec_id, t.parent_id, t.cube_id, ft.lvl+1 lvl, concat(ft.rng, case when t.how_much<>'1' then t.how_much end) rng,
   t.lvl_name, ft.rec1, t.elem_rec_id rec
  from recs2cubes t join ftree ft on ft.elem_rec_id=t.parent_id and ft.cube_id=t.cube_id
)
select r.* from ftree r
) r;