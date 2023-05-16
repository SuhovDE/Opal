--
-- SHOW_QRYS_SEL  (View) 
--
--  Dependencies: 
--   ANALYZER (Package)
--   ATTRS (Table)
--   DIMS (Table)
--   DIM_LEVELS (Table)
--   FROM_DB_UTILS (Package)
--   FUNC_GRP (Table)
--   GET_CONST (Function)
--   GROUPS (Table)
--   QRYS (Table)
--   QRYS_SEL (Table)
--   QRYS_SEL_RS4DIMS (Table)
--   RS_CODES4DIMS_ALL (View)
--   RS_CODES_INFO (Type)
--   RS_CODES_INFOS (Type)
--   TREE_FNC (Package)
--   STANDARD (Package)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_QRYS_SEL
(QRY_ID, QRY_SEL_ID, LEVEL_ID, BASIC_ATTR_ID, ORDNO, 
 BASIC_ATTR_TYPE, ATTR_INFO_TYPE, BASIC_ATTR_NAME, LEVEL_NAME, ATTR_LVL, 
 LEVEL_TYPE, DIM_LEV_ID, GRP_TYPE, STORAGE_TYPE)
BEQUEATH DEFINER
AS 
select
  qry_id, qry_sel_id, level_id, basic_attr_id, ordno, basic_attr_type,
  cast(multiset(
    select
     coalesce(func_grp_id, ATTR_TYPE_CODE),
     ATTR_TYPE_NAME, result_set_colname||
     case when RS_NAME_SUF is not null then '_' end||RS_NAME_SUF,
     rtrim(basic_attr_suf||' '||attr_info_type)||' '||attr_type_name,
     from_db_utils.get_display_format(dim_lev_id, storage_type, attr_precision, unit, attr_type_code, basic_attr_type) display_format,
     colname,
     case when expr_id is not null and grp_type<>get_const('grp_type_nomulti') then
       case when analyzer.get_version=3 then to_number(case when unit='%' then '100' else nvl(unit, 1) end) else 1 end else 0 end, --what means this 1, nobody knows
     case when expr_id is not null and grp_type<>get_const('grp_type_nomulti') then from_db_utils.get_expr4sel(expr_id, ordno) end
    from rs_codes4dims_all rs where dim_lev_id=rs_dim_lev_id
     and (coalesce(qb.dim_lev_id, -99)<0 or 0=(select count(*) from qrys_sel_rs4dims where qry_id=qb.qry_id and ordno=qb.ordno) or rs.attr_type_code in (select val from qrys_sel_rs4dims where qry_id=qb.qry_id and ordno=qb.ordno))
   ) as rs_codes_infos) attr_info_type
  , basic_attr_name, level_name,
  from_db_utils.get_attr_lvl(basic_attr_id, cube_id) attr_lvl,
  case when grp_id is not null then 'G' else case when basic_attr_type=get_const('show_val') then 'F' else 'L' end end level_type, qb.dim_lev_id, grp_type, storage_type
 from (
  select qa.qry_id, qa.qry_sel_id,
    coalesce(grp_id, qa.dim_lev_id, qa.attr_id) level_id,
    qa.basic_attr_id,
    qa.ordno, cast(from_db_utils.get_selcolname(qa.ordno) as varchar(30)) result_set_colname,
    cast(tree_fnc.get_show(grp_id, qa.dim_lev_id, qa.basic_attr_id, qa.cube_id) as varchar(1)) basic_attr_type,
    coalesce(case when qa.parent_id is not null then d.suf
             else case when (select show_basic_level from dims where id=d.dim_id) is not null then d.suf end end,
     coalesce(case when qa.grp_id>0 then case when g.predefined<>'N' then g.abbr end end,
     case when func_grp_id<>'GRP' then func_grp_id end)) attr_info_type,
    s.abbr basic_attr_name, s.suf basic_attr_suf,
    case when grp_id is not null then case when g.predefined<>'N' then g.abbr else qa.abbr end
     else coalesce(case when qa.dim_lev_id<>0 then d.abbr end, qa.abbr) end level_name,
    FROM_DB_UTILS.GET_RS_DIM_LEV_ID(qa.grp_id, qa.dim_lev_id) rs_dim_lev_id,
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
  select id, 1001 qry_sel_id, null level_id, null basic_attr_id, 1001 ordno, 'K' basic_attr_type,
    rs_codes_infos(rs_codes_info('CODE', '', 'RN1', 'ID '||analyzer.get_level_name(cube_id, 1), '', '', 0, '')) attr_info_type, '' basic_attr_name, '' level_name, 1 attr_lvl,
    'L' level_type, null dim_lev_id, null grp_type, -1 storage_type
   from qrys q where ANALYZER.GET_VERSION>2
 union all
  select id, 1002 qry_sel_id, null level_id, null basic_attr_id, 1002 ordno, 'K' basic_attr_type,
    rs_codes_infos(rs_codes_info('CODE', '', 'RN2', 'ID '||analyzer.get_level_name(cube_id, 2), '', '', 0, '')) attr_info_type, '' basic_attr_name, '' level_name, 2 attr_lvl,
    'L' level_type, null dim_lev_id, null grp_type, -1 storage_type
   from qrys q where ANALYZER.GET_VERSION>2;