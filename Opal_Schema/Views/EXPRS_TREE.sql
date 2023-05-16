--
-- EXPRS_TREE  (View) 
--
--  Dependencies: 
--   EXPRS (Table)
--   LEAFS4EXPRS (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.EXPRS_TREE
(ID, PARENT_ID, ATTR_ID, ROOT_ID, ORDNO, 
 HIE, LVL)
BEQUEATH DEFINER
AS 
with el_basic as
   (select e.id, e.parent_id, l.attr_id, e.ordno from exprs e left outer join leafs4exprs l on e.id=l.leaf_id),
   /*recursive*/ el(id, parent_id, attr_id, root_id, ordno, hie, lvl) as
   (select b.id, b.parent_id, b.attr_id, b.id root_id, b.ordno, lpad(id,3, '0') hie, 1 lvl
      from el_basic b
      where parent_id is null
      union all
     select b.id, b.parent_id, b.attr_id, e.root_id, b.ordno, concat(e.hie, lpad(b.id,3, '0')), e.lvl+1 lvl
      from el_basic b join el e on b.parent_id=e.id
    )
    select e."ID",e."PARENT_ID",e."ATTR_ID",e."ROOT_ID",e."ORDNO",e."HIE",e."LVL"
     from el e where attr_id is not null;