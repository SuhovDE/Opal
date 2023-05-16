--
-- SHOW_QRYS_SEL_  (View) 
--
--  Dependencies: 
--   ANALYZER (Package)
--   ATTRS (Table)
--   ATTRS2CUBES (Table)
--   DIMS (Table)
--   DIM_LEVELS (Table)
--   EXPRS (Table)
--   FUNC_GRP (Table)
--   GET_CONST (Function)
--   GROUPS (Table)
--   MULTIPLIER (Table)
--   QRYS (Table)
--   QRYS_SEL (Table)
--   QRYS_SEL_RS4DIMS (Table)
--   RECS_TREE (View)
--   RS_CODES4DIMS_ALL (View)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_QRYS_SEL_
(QRY_ID, QRY_SEL_ID, LEVEL_ID, BASIC_ATTR_ID, ORDNO, 
 BASIC_ATTR_TYPE, ATTR_INFO_TYPE, BASIC_ATTR_NAME, LEVEL_NAME, ATTR_LVL, 
 LEVEL_TYPE, DIM_LEV_ID, GRP_TYPE, STORAGE_TYPE)
BEQUEATH DEFINER
AS 
select
  qry_id, qry_sel_id, level_id, basic_attr_id, ordno, basic_attr_type,
  (select json_arrayagg(
    json_object(KEY 'attr_type_code' VALUE coalesce(func_grp_id, ATTR_TYPE_CODE),
     KEY 'attr_type_name' VALUE ATTR_TYPE_NAME, KEY 'rs_name' VALUE concat(concat(result_set_colname,
       case when RS_NAME_SUF is not null then '_' end), RS_NAME_SUF),
     KEY 'rs_display_name' VALUE concat(concat(rtrim(concat(concat(basic_attr_suf, ' '), attr_info_type)), ' '), attr_type_name),
     KEY 'display_format' VALUE case when qb.dim_lev_id is not null then rs.display_format
      else (select display_format from attrs where id=basic_attr_id) end,
     KEY 'colname' VALUE colname,
     KEY 'rs_ftype' VALUE case when expr_id is not null and grp_type<>get_const('grp_type_nomulti') then
      case when analyzer.get_version=3 then to_number(case when unit='%' then '100' else nvl(unit, 1) end) else 1 end else 0 end, --what means this 1, nobody knows
     KEY 'rs_expr' VALUE case when expr_id is not null and grp_type<>get_const('grp_type_nomulti') then (select replace(rs_expr, ':%NO', qb.ordno)  from exprs where id=qb.expr_id) end))
    from rs_codes4dims_all rs where dim_lev_id=rs_dim_lev_id
     and (coalesce(qb.dim_lev_id, -99)<0 or 0=(select count(*) from qrys_sel_rs4dims where qry_id=qb.qry_id and ordno=qb.ordno)
       or rs.attr_type_code in (select val from qrys_sel_rs4dims where qry_id=qb.qry_id and ordno=qb.ordno))
   )  attr_info_type
  , basic_attr_name, level_name,
  (select rng from attrs2cubes where attr_id=qb.basic_attr_id and cube_id=qb.cube_id) attr_lvl,
  case when grp_id is not null then 'G' else case when basic_attr_type=get_const('show_val') then 'F' else 'L' end end level_type, qb.dim_lev_id, grp_type, storage_type
 from (
  select qa.qry_id, qa.qry_sel_id,
    coalesce(grp_id, qa.dim_lev_id, qa.attr_id) level_id,
    qa.basic_attr_id,
    qa.ordno, concat('F', qa.ordno) result_set_colname,
    cast(case when grp_id is not null or qa.dim_lev_id is not null then get_const('show_key')
          else (select nvl(max(ac.show), get_const('show_val')) from attrs2cubes ac where attr_id=qa.basic_attr_id and qa.cube_id=ac.cube_id)
         end as varchar(1)) basic_attr_type,
    coalesce(case when qa.parent_id is not null then d.suf
             else case when (select show_basic_level from dims where id=d.dim_id) is not null then d.suf end end,
     coalesce(case when qa.grp_id>0 then case when g.predefined<>'N' then g.abbr end end,
     case when func_grp_id<>'GRP' then func_grp_id end)) attr_info_type,
    s.abbr basic_attr_name, s.suf basic_attr_suf,
    case when grp_id is not null then case when g.predefined<>'N' then g.abbr else qa.abbr end
     else coalesce(case when qa.dim_lev_id<>0 then d.abbr end, qa.abbr) end level_name,
    case when qa.grp_id>0 then (select case when predefined=get_const('GRP_TEMPORARY') then -3 else -2 end from groups where id=qa.grp_id)
     when qa.dim_lev_id is not null then qa.dim_lev_id
     else -1 end rs_dim_lev_id,
    qa.func_grp_id,
    case when qa.grp_id is not null then cast(get_const('chartype') as integer)
         when coalesce(f.res_type, 0)=0 then
           case when case when qa.dim_lev_id<>0 then qa.dim_lev_id end is null then qa.storage_type else coalesce(d.storage_type, qa.storage_type) end
      else f.res_type end storage_type,
    qa.attr_precision, qa.unit, qa.cube_id, qa.grp_id,
    qa.expr_id, f.grp_type, qa.dim_lev_id
   from (
     select --+index(q)
       q.QRY_ID, q.QRY_SEL_ID, q.ATTR_ID,  q.ORDNO, q.CUBE_ID,
       case when q.func_grp_id<>'GRP' then func_grp_id end func_grp_id, q.GRP_ID, q.GRP_LEV_ORDNO,
       coalesce(aa.abbr, a.abbr) abbr, coalesce(aa.short, a.short) descr,
       coalesce(aa.parent_id, q.attr_id) basic_attr_id,
       coalesce(q.dim_lev_id, aa.dim_lev_id) dim_lev_id, aa.parent_id,
       a.storage_type,
       coalesce(a.attr_precision, 0) attr_precision, a.unit, a.expr_id
      from qrys_sel q join attrs a on q.attr_id=a.id left outer join attrs aa on q.attr_id=aa.parent_id and q.dim_lev_id=aa.dim_lev_id
      where q.noshow is null
     ) qa join attrs s on qa.basic_attr_id = s.id left outer join dim_levels d on qa.dim_lev_id=d.id
        left outer join groups g on qa.grp_id = g.id left outer join func_grp f on qa.func_grp_id=f.id
 ) qb
 union all
  select id, 1000+m.n qry_sel_id, null level_id, null basic_attr_id, 1000+m.n ordno, 'K' basic_attr_type,
    json_array(json_object(KEY 'attr_type_code' VALUE 'CODE',
     KEY 'attr_type_name' VALUE '', KEY 'rs_name' VALUE concat('RN', m.n),
     KEY 'rs_display_name' VALUE concat('ID ', (select max(lvl_name) from recs_tree where rng=m.n and cube_id=q.cube_id)),
     KEY 'display_format' VALUE '',
     KEY 'colname' VALUE '',
     KEY 'rs_ftype' VALUE 0,
     KEY 'rs_expr' VALUE '')
    ), '' basic_attr_name, '' level_name, m.n attr_lvl,
    'L' level_type, null dim_lev_id, null grp_type, -1 storage_type
   from qrys q, multiplier m
   where m.n in (1,2);