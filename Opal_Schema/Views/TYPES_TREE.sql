--
-- TYPES_TREE  (View) 
--
--  Dependencies: 
--   ATTR_TYPES (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.TYPES_TREE
(TYPE_ID, GRP_TYPE_ID, DESCR, SCODE, TYPE_KIND)
BEQUEATH DEFINER
AS 
with /*recursive*/ ftree(id, parent_id) as (
 select t.id, t.parent_id from attr_types t
 union all
 select t.id, t.parent_id grp_type_id from attr_types t join ftree ft on ft.id=t.parent_id
),
 /*recursive*/ ftree1(id, parent_id) as (
 select t.id, t.parent_id from ftree t
 union all
 select t.id, ft.parent_id grp_type_id from ftree t join ftree1 ft on ft.id=t.parent_id
)
select t.id type_id, t2.id grp_type_id, t.descr, t.scode, t.type_kind
 from attr_types t, attr_types t2
where
 t2.id in
 (select id from ftree1 where t.id in (id, parent_id));