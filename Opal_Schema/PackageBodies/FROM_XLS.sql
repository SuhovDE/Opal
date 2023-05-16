--
-- FROM_XLS  (Package Body) 
--
--  Dependencies: 
--   FROM_XLS (Package)
--   AREAS (Table)
--   ATTRS (Table)
--   ATTRS2CUBES (Table)
--   ATTRS2RECS (Table)
--   ATTR_TYPES (Table)
--   CONDS (Table)
--   CONSTANTS (Package)
--   CUBES (Table)
--   DATA_SERVICE (Package)
--   DIMS (Table)
--   DIM_LEVELS (Table)
--   DOMAINS (Table)
--   EXPRS (Table)
--   FROM_XLS_UTILS (Package)
--   FUNC_ROW (View)
--   GROUPS (Table)
--   GROUPS_FNC (Package)
--   GROUPS_NOT_FROM_D (View)
--   GRP_C (Table)
--   GRP_D (Table)
--   GRP_TREE (Table)
--   LEAFS4CONDS (Table)
--   LEAFS4EXPRS (Table)
--   QRYS (Table)
--   QRYS_SEL (Table)
--   RECS2CUBES (Table)
--   RS_CODES4DIMS (Table)
--   TREE_FNC (Package)
--   TYPES_COMP (Table)
--   T_PARAMETER (Type)
--   T_PARAMETERS (Type)
--   ALL_TAB_COLUMNS (Synonym)
--   PLITBLM (Synonym)
--   USER_SYNONYMS (Synonym)
--   USER_TAB_COLUMNS (Synonym)
--   STANDARD (Package)
--
CREATE OR REPLACE package body OPAL_FRA.from_xls as
fixed_attrs constant t_parameters
 := t_parameters(t_parameter( 'IO', 0), t_parameter('PLACEHOLDER', -1));
fixed_areas constant t_parameters
 := t_parameters(t_parameter( 'Service', 0));
procedure delete_qrydata is
begin
-- delete qrys_ord;
 delete qrys_sel;
 delete qrys;
-- delete aggrs;
 delete leafs4conds;
 delete grp_tree;
 delete groups;
 delete conds;
 commit;
end;
-----------------------------------------------------------------------------
procedure delete_metadata is
begin
 delete_qrydata;
 delete types_comp;
 delete rs_codes4dims;
 delete attrs2cubes;
 delete leafs4exprs;
 delete attrs;
 delete exprs;
 delete dim_levels;
 delete areas;
 delete recs2cubes;
 delete cubes;
 delete dims;
 delete func_row;
 delete attr_types where dim_lev_id is not null;
 delete domains where nvl(domain_kind, '!') <> tree_fnc.basic_type;
 commit;
end;
-----------------------------------------------------------------------------
function is_fixed(fixed_attrs t_parameters, abbr varchar2) return integer is
 id_ binary_integer;
begin
 if fixed_attrs.first is not null then
  for i in fixed_attrs.first..fixed_attrs.last loop
   if abbr=fixed_attrs(i).name then
    id_ := fixed_attrs(i).value;
    exit;
   end if;
  end loop;
 end if;
 return id_;
end;
-----------------------------------------------------------------------------
procedure i_areas(
  abbr varchar2, maxl_abbr integer, short varchar2, maxl_short integer,
  full varchar2, maxl_full integer,
  parent_abbr varchar2, scode varchar2) is
 id_ areas.id%type := is_fixed(fixed_areas, abbr);
 pid_ areas.parent_id%type;
BEGIN
 pid_ := from_xls_utils.get_id(parent_abbr, 'areas');
 insert into areas(id, PARENT_ID, abbr, short, full, scode) values(id_, pid_,
   i_areas.abbr, i_areas.short, i_areas.full, i_areas.scode);
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Area "' || abbr);
END;
-----------------------------------------------------------------------------
procedure i_attrs(
  abbr varchar2, maxl_abbr integer,
  attr_type varchar2, dim_lev varchar2, area varchar2, expr varchar2,
  parent_abbr varchar2,
  storage_type varchar2, attr_size integer, attr_precision integer,
  unit varchar2,
  short varchar2, maxl_short integer,
  full varchar2, maxl_full integer, scode varchar2) is
 id_ attrs.id%type := is_fixed(fixed_attrs, abbr);
 parent_id_ attrs.id%type;
 expr_id_ exprs.id%type;
 dim_lev_id_ dim_levels.id%type;
 area_id_ areas.id%type;
 ATTR_TYPE_ attrs.ATTR_TYPE%type;
 STORAGE_TYPE_ attrs.STORAGE_TYPE%type;
BEGIN
 dim_lev_id_ := from_xls_utils.get_id(dim_lev, 'dim_levels');
 expr_id_ := from_xls_utils.get_id(expr, 'exprs', 'descr');
 area_id_ := from_xls_utils.get_id(area, 'areas');
 storage_type_ := from_xls_utils.get_id(upper(storage_type),
  'attr_types', 'upper(descr)');
 attr_type_ := from_xls_utils.get_id(upper(attr_type),
  'attr_types', 'upper(descr)');
 if attr_type_=0 then attr_type_ := dim_lev_id_; end if;
 parent_id_ := from_xls_utils.get_id(parent_abbr, 'attrs');
 insert into attrs(id, abbr, short, full, ATTR_TYPE, DIM_LEV_ID, AREA_ID, EXPR_ID, parent_id,
   STORAGE_TYPE, ATTR_SIZE, ATTR_PRECISION, unit, scode) values(id_,
   i_attrs.abbr, i_attrs.short, i_attrs.full,
  ATTR_TYPE_, DIM_LEV_ID_, AREA_ID_, EXPR_ID_, parent_id_,
  STORAGE_TYPE_, i_attrs.ATTR_SIZE, i_attrs.ATTR_PRECISION, i_attrs.unit, i_attrs.scode);
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Attr "' || abbr);
END;
-----------------------------------------------------------------------------
procedure i_attrs2cubes(attr varchar2, cube varchar2, show varchar2, col varchar2,
  elem_rec varchar2)is
 cube_ areas.parent_id%type;
 attr_ attrs.id%type;
BEGIN
 cube_ := from_xls_utils.get_id(cube, 'cubes');
 attr_ := from_xls_utils.get_id(attr, 'attrs');
 insert into attrs2cubes(ATTR_ID, CUBE_ID, SHOW, col, elem_rec_id) values(attr_,
   cube_, i_attrs2cubes.show, col, elem_rec);
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Attr "' || attr);
END;
-----------------------------------------------------------------------------
procedure i_cubes(
  abbr varchar2, maxl_abbr integer, short varchar2, maxl_short integer,
  full varchar2, maxl_full integer, tab_ varchar2,
  parent_abbr varchar2,
  c_abbr varchar2, c_maxl_abbr integer, c_short varchar2, c_maxl_short integer,
  c_full varchar2, c_maxl_full integer, scode varchar2) is
 pid_ cubes.parent_id%type;
BEGIN
 pid_ := from_xls_utils.get_id(parent_abbr, 'cubes');
 insert into cubes(PARENT_ID, abbr, short, full, tab, scode) values (
  pid_,
  i_cubes.abbr, i_cubes.short, i_cubes.full,
  tab_, i_cubes.scode
);
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Cube "' || abbr);
END;
-----------------------------------------------------------------------------
procedure i_dims(
  abbr varchar2, tabname varchar2, maxl_abbr integer, short varchar2, maxl_short integer,
  full varchar2, maxl_full integer, add_dim varchar2, parent_abbr varchar2,
  dom_name varchar2, scode varchar2) is
 msg    varchar2(2048);
 id_ pls_integer;
 pid_ pls_integer;
 did_ pls_integer;
BEGIN
 pid_ := from_xls_utils.get_id(parent_abbr, 'dims');
 did_ := from_xls_utils.get_id(dom_name, 'domains');
 if scode=constants.dummy_dim then id_ := 0; end if;
 insert into dims(id, tabname, abbr, short, full, add_dim, parent_id, dom_id, scode)
   values(id_, i_dims.tabname,
    i_dims.abbr, i_dims.short, i_dims.full, i_dims.add_dim,
    pid_, did_, i_dims.scode);
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Dim "' || abbr);
END;
-----------------------------------------------------------------------------
procedure i_domains(
  abbr varchar2, maxl_abbr integer, short varchar2, maxl_short integer,
  full varchar2, maxl_full integer, scode varchar2) is
 msg    varchar2(2048);
 id_ pls_integer;
BEGIN
 if scode=constants.dummy_dim then id_ := 0; end if;
 insert into domains(id, abbr, short, full, scode) values(id_,
   i_domains.abbr, i_domains.short, i_domains.full, i_domains.scode);
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Domain "' || abbr);
END;
-----------------------------------------------------------------------------
procedure i_dim_levels(
  abbr varchar2, maxl_abbr integer,
  Dim_Abbr varchar2, Ordno integer, dom_name varchar2,
  tab_name varchar2, col_name varchar2, parent_col_name varchar2,
  col_in_dims varchar2,  storage_type varchar2,
  short varchar2, maxl_short integer,
  full varchar2, maxl_full integer, scode varchar2) is
 dim_id_ dims.id%type;
 id_ dim_levels.id%type;
 did_ domains.id%type;
 STORAGE_TYPE_ attrs.STORAGE_TYPE%type;
BEGIN
 dim_id_ := from_xls_utils.get_id(dim_abbr, 'dims');
 did_ := from_xls_utils.get_id(dom_name, 'domains');
 if scode=constants.dummy_dim then id_ := 0; end if;
 storage_type_ := from_xls_utils.get_id(upper(storage_type),
  'attr_types', 'upper(descr)');
 insert into dim_levels(id, DIM_ID, ORDNO, abbr, short, full, TAB_NAME, COL_NAME, PARENT_COL_NAME,
 col_in_dims, storage_type, dom_id, scode) values(
  id_, dim_id_, i_dim_levels.ordno,
  i_dim_levels.abbr, i_dim_levels.short, i_dim_levels.full,
  i_dim_levels.TAB_NAME, i_dim_levels.COL_NAME, i_dim_levels.PARENT_COL_NAME,
  i_dim_levels.col_in_dims, storage_type_, did_, i_dim_levels.scode)
  returning id into id_;
EXCEPTION
when DUP_VAL_ON_INDEX then
 from_xls_utils.signal_dupval('Dim level "' || abbr );
END;
-----------------------------------------------------------------------------
procedure i_attr_types(
  abbr varchar2, Parent_Abbr varchar2, type_size integer,
  type_precision integer, type_mask varchar2, dom_name varchar2, scode varchar2) is
 dim_lev_id_ dim_levels.id%type;
 did_ domains.id%type;
 parent_id_ attr_types.parent_id%type;
BEGIN
 dim_lev_id_ := from_xls_utils.get_id(abbr, 'dim_levels');
 parent_id_ := from_xls_utils.get_id(upper(parent_abbr),
   'attr_types', 'upper(descr)');
 did_ := from_xls_utils.get_id(dom_name, 'domains');
 insert into attr_types(ID, DESCR, CD, PARENT_ID, TYPE_SIZE, TYPE_PRECISION,
  TYPE_KIND, DIM_LEV_ID, type_mask, dom_id, scode)
  select dim_lev_id_, abbr, t.CD, ID, i_attr_types.TYPE_SIZE,
     i_attr_types.TYPE_PRECISION, t.TYPE_KIND,  dim_lev_id_, i_attr_types.type_mask,
	 did_, i_attr_types.scode
   from attr_types t where id=parent_id_;
EXCEPTION
when DUP_VAL_ON_INDEX then
 from_xls_utils.signal_dupval('Type from Dim level "' || abbr );
end;
-----------------------------------------------------------------------------
procedure i_res_set(dim_lev varchar2, attr_type_code rs_codes4dims.attr_type_code%type,
 attr_type_name rs_codes4dims.attr_type_name%type,
 display_format rs_codes4dims.display_format%type,
 rs_name_suf rs_codes4dims.rs_name_suf%type, colname rs_codes4dims.colname%type,
 noshow rs_codes4dims.noshow%type, scode varchar2) is
 dim_lev_id_ dim_levels.id%type;
BEGIN
 dim_lev_id_ := from_xls_utils.get_id(dim_lev, 'dim_levels');
 insert into rs_codes4dims(DIM_LEV_ID, ATTR_TYPE_CODE, ATTR_TYPE_NAME,
  RS_NAME_SUF, DISPLAY_FORMAT, colname, noshow, scode)
   values(DIM_LEV_ID_, i_res_set.ATTR_TYPE_CODE,
  i_res_set.ATTR_TYPE_NAME, i_res_set.RS_NAME_SUF, i_res_set.DISPLAY_FORMAT,
  i_res_set.colname, i_res_set.noshow, i_res_set.scode);
end;
-----------------------------------------------------------------------------
procedure i_exprs(
  descr varchar2, parent_descr varchar2, Ordno integer,
  op_sign varchar2, is_leaf integer) is
 pid_ integer;
BEGIN
 pid_ := from_xls_utils.get_id(parent_descr, 'exprs', 'descr');
 insert into exprs(descr, OP_SIGN, PARENT_ID, IS_LEAF, ORDNO) values(
  i_exprs.descr, i_exprs.op_sign, pid_, i_exprs.is_leaf, i_exprs.ordno);
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Expr "' || descr);
END;
-----------------------------------------------------------------------------
procedure i_func_row(
  id varchar2, func_type varchar2, par_no integer, subst varchar2,
  par_type varchar2, ret_type varchar2)is
 par_TYPE_ func_row.PAR_TYPE%type;
 ret_TYPE_ func_row.RET_TYPE%type;
BEGIN
 par_type_ := from_xls_utils.get_id(upper(par_type),
  'attr_types', 'upper(descr)');
 ret_type_ := from_xls_utils.get_id(upper(ret_type),
  'attr_types', 'upper(descr)');
 insert into func_row(ID, FUNC_TYPE, PAR_NO, SUBST, PAR_TYPE, RET_TYPE) values(
   i_func_row.id, i_func_row.func_type,
   i_func_row.par_no, i_func_row.subst, par_type_, ret_type_);
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Row func "' || id);
END;
-----------------------------------------------------------------------------
procedure i_exprs_leafs(
  descr varchar2, un_sign varchar2, attr varchar2, const varchar2,
  func_row_id varchar2) is
 pid_ areas.parent_id%type;
 attr_ attrs.id%type;
BEGIN
 pid_ := from_xls_utils.get_id(descr, 'exprs', 'descr');
 attr_ := from_xls_utils.get_id(attr, 'attrs');
 insert into leafs4exprs(LEAF_ID, UN_SIGN, CONST, ATTR_ID, FUNC_ROW_ID) values(pid_,
   i_exprs_leafs.un_sign, i_exprs_leafs.const,
   attr_, i_exprs_leafs.func_row_id);
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Expr leaf "' || descr);
END;
-----------------------------------------------------------------------------
procedure i_attrs2recs(elem_rec_id varchar2, attr varchar2, col_name varchar2) is
 attr_ attrs.id%type;
BEGIN
 attr_ := from_xls_utils.get_id(attr, 'attrs');
 insert into attrs2recs(ATTR_ID, ELEM_REC_ID, COL_NAME)
  values(attr_, i_attrs2recs.elem_rec_id, i_attrs2recs.col_name);
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Attr "' || attr);
END;
-----------------------------------------------------------------------------
procedure i_recs2cubes(elem_rec_id varchar2, cube varchar2, parent_id varchar2,
 how_much varchar2)is
 cube_ cubes.id%type;
BEGIN
 cube_ := from_xls_utils.get_id(cube, 'cubes');
 insert into recs2cubes(CUBE_ID, ELEM_REC_ID, parent_id, how_much)
   values(cube_, i_recs2cubes.elem_rec_id, i_recs2cubes.parent_id, i_recs2cubes.how_much);
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Cube "' || cube);
END;
-----------------------------------------------------------------------------
procedure i_types_comp(type_id varchar2, comp_type_id varchar2,
  func_row_id varchar2, func_row_back varchar2)is
 TYPE_ID_ types_comp.TYPE_ID%type;
 COMP_TYPE_ID_ types_comp.COMP_TYPE_ID%type;
BEGIN
 TYPE_ID_ := from_xls_utils.get_id(upper(type_id),
  'attr_types', 'upper(descr)');
 COMP_TYPE_ID_ := from_xls_utils.get_id(upper(comp_type_id),
  'attr_types', 'upper(descr)');
 delete types_comp where type_id=type_id_ and comp_type_id=comp_type_id_
  and fun_row_conv is null;
 insert into types_comp(TYPE_ID, COMP_TYPE_ID, FUN_ROW_CONV, FUN_ROW_BACK) values(
   TYPE_ID_, COMP_TYPE_ID_, func_row_id, func_row_back);
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Types compatibility "' ||type_id||
    '" "'||comp_type_id||'"');
END;
-----------------------------------------------------------------------------
procedure i_qrys(abbr varchar2, qry_type integer, where_ varchar2, having_ varchar2,
 predefined varchar2, cube varchar2, short varchar2)is
 cube_ areas.parent_id%type;
 where_id_ qrys.where_id%type;
 having_id_ qrys.having_id%type;
BEGIN
 cube_ := from_xls_utils.get_id(cube, 'cubes');
 where_id_ := from_xls_utils.get_id(where_, 'conds', 'descr');
 having_id_ := from_xls_utils.get_id(having_, 'conds', 'descr');
 insert into qrys(QRY_TYPE, CUBE_ID, WHERE_ID, HAVING_ID, ABBR, SHORT, PREDEFINED)
  values(i_qrys.qry_type, cube_, where_id_, having_id_,i_qrys.abbr, i_qrys.short, i_qrys.predefined);
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Cube "' || cube);
END;
-----------------------------------------------------------------------------
/*
procedure i_aggrs(aggr varchar2, group_abbr varchar2, aggr_typ varchar2)is
 grp_id_ aggrs.grp_id%type;
BEGIN
 grp_id_ := from_xls_utils.get_id(group_abbr, 'groups');
 insert into aggrs(GRP_ID, AGGR_TYP, DESCR)
  values(grp_id_, i_aggrs.aggr_typ, i_aggrs.aggr);
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Aggr "' || aggr);
END;
-----------------------------------------------------------------------------
procedure i_aggr_levels(aggr varchar2, ordno integer, level_down integer,
  group_abbr varchar2)is
 grp_id_ aggrs.grp_id%type;
 aggr_id_ aggrs.id%type;
BEGIN
 aggr_id_ := from_xls_utils.get_id(aggr, 'aggrs', 'descr');
 grp_id_ := from_xls_utils.get_id(group_abbr, 'groups');
 insert into aggr_levels(AGGR_ID, ORDNO, LEVEL_DOWN, GRP_ID)
  values(aggr_id_, i_aggr_levels.ordno, i_aggr_levels.level_down, grp_id_);
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Aggr "' || aggr||'", ordno "'||ordno);
END;
*/
-----------------------------------------------------------------------------
function get_attr_id_with_dim(attr varchar2, dim_lev varchar2)
  return attrs.id%type is
 dim_lev_id_ dim_levels.id%type;
 attr_id_ attrs.id%type;
begin
 attr_id_ := from_xls_utils.get_id(attr, 'attrs');
 if dim_lev is not null then
  dim_lev_id_ := from_xls_utils.get_id(dim_lev, 'dim_levels');
  select id into attr_id_ from attrs where
    attr_id_ in (id, parent_id) and attr_type=dim_lev_id_;
 end if;
 return attr_id_;
end;
-----------------------------------------------------------------------------
procedure i_qrys_sel(abbr varchar2, attr varchar2, func_grp_id varchar2,  grp varchar2,
 grp_lev_ordno integer, ordno integer, dim_lev varchar2 := '')is
 qry_id_ qrys.id%type;
 attr_id_ attrs.id%type;
 grp_id_ groups.id%type;
 cube_id_ cubes.id%type;
BEGIN
 qry_id_ := from_xls_utils.get_id(abbr, 'qrys', 'abbr');
 attr_id_ := get_attr_id_with_dim(attr, dim_lev);
 grp_id_ := from_xls_utils.get_id(grp, 'groups');
 select cube_id into cube_id_ from qrys where id=qry_id_;
 insert into qrys_sel(QRY_ID, ATTR_ID, FUNC_GRP_ID, GRP_ID, GRP_LEV_ORDNO, ORDNO, cube_id)
  values(qry_id_, attr_id_, i_qrys_sel.func_grp_id, grp_id_,
  i_qrys_sel.grp_lev_ordno, i_qrys_sel.ordno, cube_id_);
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Qry "' || abbr||'", attr "'||attr||':'||dim_lev||'" func "'||func_grp_id);
END;
/*-----------------------------------------------------------------------------
procedure i_qrys_ord(abbr varchar2, sel_list_no integer, ordno integer, sort_kind varchar2)is
 qry_id_ qrys.id%type;
 qry_sel_id_ qrys_ord.qry_sel_id%type;
BEGIN
 qry_id_ := from_xls_utils.get_id(abbr, 'qrys', 'abbr');
 select QRY_SEL_ID into qry_sel_id_ from qrys_sel
  where qry_id=qry_id_ and ordno=i_qrys_ord.sel_list_no;
 insert into qrys_ord(QRY_ID, ORDNO, SORT_KIND, QRY_SEL_ID)
  values(qry_id_, i_qrys_ord.ordno, i_qrys_ord.sort_kind, qry_sel_id_);
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Qry "' || abbr||'", Ordno "'||ordno);
 when NO_DATA_FOUND then
   raise_application_error (error_codes.KEY_NOT_FOUND_N,
    'Qry "' || abbr||'", Ordno "'||ordno || '" gibt es nicht.', TRUE);
 END;
-----------------------------------------------------------------------------
procedure i_qrys_top(abbr varchar2, ordno integer, tb varchar2, rows_no integer,
   sel_attr varchar2, ord_attr varchar2, others varchar2) is
 qry_id_ qrys.id%type;
 sel_attr_id_ attrs.id%type;
 ord_attr_id_ attrs.id%type;
BEGIN
 qry_id_ := from_xls_utils.get_id(abbr, 'qrys', 'abbr');
 sel_attr_id_ := from_xls_utils.get_id(sel_attr, 'attrs');
 ord_attr_id_ := from_xls_utils.get_id(ord_attr, 'attrs');
 insert into qrys_top(QRY_ID, ORDNO, TB, ROWS_NO, SEL_ATTR_ID, ORD_ATTR_ID, OTHERS)
  values(qry_id_, i_qrys_top.ordno, i_qrys_top.tb, i_qrys_top.rows_no,
  sel_attr_id_, ord_attr_id_, i_qrys_top.others);
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Qry "' || abbr||'", Ordno "'||ordno);
END;
-----------------------------------------------------------------------------
procedure i_qrys_grp(abbr varchar2, attr varchar2, grp varchar2, grp_lev_ordno integer)is
 qry_id_ qrys.id%type;
 attr_id_ attrs.id%type;
 grp_id_ groups.id%type;
BEGIN
 qry_id_ := from_xls_utils.get_id(abbr, 'qrys', 'abbr');
 attr_id_ := from_xls_utils.get_id(attr, 'attrs');
 grp_id_ := from_xls_utils.get_id(grp, 'groups');
 insert into qrys_grp(QRY_ID, ATTR_ID, GRP_ID, GRP_LEV_ORDNO)
  values(qry_id_, attr_id_, grp_id_, i_qrys_grp.grp_lev_ordno);
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Qry "' || abbr||'", attr "'||attr||'", grp "'||grp
   ||'" of level "'||grp_lev_ordno);
END;
*/
-----------------------------------------------------------------------------
procedure i_grp_tree(abbr varchar2, parent_abbr varchar2,
   ordno number, allrest varchar2) is
 id_ grp_tree.id%type;
 pid_ grp_tree.parent_id%type;
BEGIN
 id_ := from_xls_utils.get_id(abbr, 'groups');
 pid_ := from_xls_utils.get_id(parent_abbr, 'groups');
 insert into grp_tree(ID, PARENT_ID, ordno_in_root, allrest) values (id_, pid_,
  i_grp_tree.ordno, i_grp_tree.allrest);
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Grp tree code"' || abbr||'" in parent_group "'||parent_abbr);
END;
-----------------------------------------------------------------------------
procedure i_groups(abbr varchar2, maxl_abbr integer, predefined varchar2,
 grp_type varchar2, attr varchar2, attr_type varchar2, Dim_Abbr varchar2, is_leaf integer,
 short varchar2, maxl_short integer, full varchar2, maxl_full integer) is
 dim_id_ dims.id%type;
 ATTR_TYPE_ attrs.ATTR_TYPE%type;
 id_ groups.id%type;
BEGIN
 dim_id_ := from_xls_utils.get_id(dim_abbr, 'dims');
 attr_type_ := from_xls_utils.get_id(upper(attr_type),
  'attr_types', 'upper(descr)');
 id_ := groups_fnc.ins2group(predefined, grp_type, null, abbr, short, attr_type_, dim_id_, is_leaf, full_=>i_groups.full);
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Group "' || abbr);
END;
-----------------------------------------------------------------------------
/*
procedure i_group_levels(
  Grp_Abbr varchar2, Ordno integer,
  abbr varchar2, maxl_abbr integer,
  short varchar2, maxl_short integer,
  full varchar2, maxl_full integer) is
 grp_id_ groups.id%type;
BEGIN
 if ordno<tree_fnc.group_level_filled then return; end if;
 grp_id_ := from_xls_utils.get_id(Grp_abbr, 'groups');
 insert into group_levels(GRP_ID, ordno, name)
 values (
  grp_id_, i_group_levels.ordno,
  names(i_group_levels.abbr, i_group_levels.maxl_abbr,
   i_group_levels.short, i_group_levels.maxl_short, i_group_levels.full, i_group_levels.maxl_full));
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Group "' || Grp_abbr||'", level "'||ordno);
END;
-----------------------------------------------------------------------------
procedure i_grp_a(abbr varchar2, attr_vals vals) is
 grp_id_ groups.id%type;
BEGIN
 grp_id_ := from_xls_utils.get_id(abbr, 'groups');
 insert into grp_a(GRP_ID, ATTR_VALS) values (
  grp_id_, i_grp_a.attr_vals);
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Attribute Group "' || abbr);
END;
*/
-----------------------------------------------------------------------------
procedure i_grp_c(grp_abbr varchar2, cond varchar2) is
 grp_id_ groups.id%type;
 cond_id_ attrs.id%type;
BEGIN
 grp_id_ := from_xls_utils.get_id(grp_abbr, 'groups');
 cond_id_ := from_xls_utils.get_id(cond, 'conds', 'descr');
 insert into grp_c(GRP_ID, COND_ID) values ( grp_id_, cond_id_);
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Conditional Group "' || grp_abbr);
END;
-----------------------------------------------------------------------------
procedure i_grp_d(grp_abbr varchar2, dim_lev varchar2,
 dim_lev_code varchar2, cond varchar2) is
 grp_id_ groups.id%type;
 cond_id_ attrs.id%type;
 dim_lev_id_ dim_levels.id%type;
BEGIN
 grp_id_ := from_xls_utils.get_id(grp_abbr, 'groups');
 dim_lev_id_ := from_xls_utils.get_id(dim_lev, 'dim_levels');
 cond_id_ := from_xls_utils.get_id(cond, 'conds', 'descr');
 insert into grp_d(GRP_ID, DIM_LEV_ID, DIM_LEV_CODE, COND_ID)
   values (grp_id_, dim_lev_id_, i_grp_d.DIM_LEV_CODE, cond_id_);
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Dimensional Group "' || grp_abbr);
END;
-----------------------------------------------------------------------------
procedure i_conds(
  descr varchar2, parent_descr varchar2, Ordno integer,
  op_sign varchar2, is_leaf integer, gh varchar2)is
 pid_ integer;
BEGIN
 pid_ := from_xls_utils.get_id(parent_descr, 'conds', 'descr');
 insert into conds(descr, OP_SIGN, PARENT_ID, IS_LEAF, ORDNO, gh) values(
  i_conds.descr, i_conds.op_sign, pid_, i_conds.is_leaf, i_conds.ordno, i_conds.gh);
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Cond "' || descr);
END;
-----------------------------------------------------------------------------
procedure i_conds_leafs(
  cond varchar2, op_sign varchar2, is_compare varchar2,
  left_attr varchar2, left_dim_lev varchar2 := '', left_func_row_id varchar2, left_func_grp_id varchar2,
  const varchar2, grp varchar2,
  right_attr varchar2, right_dim_lev varchar2 := '', right_func_row_id varchar2, right_func_grp_id varchar2) is
 grp_id_ groups.id%type;
 cond_id_ conds.id%type;
 lattr_id_ attrs.id%type;
 rattr_id_ attrs.id%type;
BEGIN
 cond_id_ := from_xls_utils.get_id(cond, 'conds', 'descr');
 grp_id_ := from_xls_utils.get_id(grp, 'groups');
 lattr_id_ := get_attr_id_with_dim(left_attr, left_dim_lev);
 rattr_id_ := get_attr_id_with_dim(right_attr, right_dim_lev);
 insert into leafs4conds(LEAF_ID, OP_SIGN, IS_COMPARE,
   LEFT_ATTR_ID, LEFT_FUNC_ROW_ID, LEFT_FUNC_GRP_ID, CONST, GRP_ID,
   RIGHT_ATTR_ID, RIGHT_FUNC_ROW_ID, RIGHT_FUNC_GRP_ID)
  values (cond_id_, i_conds_leafs.op_sign, i_conds_leafs.is_compare,
   lattr_id_, i_conds_leafs.LEFT_FUNC_ROW_ID, i_conds_leafs.LEFT_FUNC_GRP_ID,
   i_conds_leafs.const, grp_id_,
   rattr_id_, i_conds_leafs.RIGHT_FUNC_ROW_ID, i_conds_leafs.RIGHT_FUNC_GRP_ID);
EXCEPTION
 when DUP_VAL_ON_INDEX then
  from_xls_utils.signal_dupval('Cond "' || cond);
END;
-----------------------------------------------------------------------------
procedure dims2types is
begin
merge into attr_types a using(
select distinct id, descr,
 case when is_data<>0 then tree_fnc.cont_type||tree_fnc.discr_type
                     else tree_fnc.discr_type end cd,
 storage_type parent_id, --there is a problem of type!!!
 data_length, --case when is_data=0 then data_length else null end,
 tree_fnc.dim_type type_kind, dom_id, scode
from (
select distinct v.id, descr, data_length,
 case when di.scode!=constants.dates_dim then 0 else 1 end is_data, storage_type,
 v.dom_id, v.scode
from (
select ID, d.abbr descr, data_length, dim_id, storage_type, d.dom_id, d.scode
 from dim_levels d, user_tab_columns where
  tab_name=table_name and col_name=column_name
union all
select ID, d.abbr descr, data_length, dim_id, storage_type, d.dom_id, d.scode
 from dim_levels d, user_synonyms s, all_tab_columns a where
  tab_name=synonym_name and s.table_name=a.table_name and
  a.owner=s.table_owner and col_name=column_name
) v, dims di
where di.id=v.dim_id
)) d on (a.scode=d.scode)
when matched then
 update set a.id=d.id, a.parent_id=d.parent_id, a.type_size=d.data_length,
  a.dom_id=d.dom_id, a.descr=d.descr
when not matched then
 insert (ID, DESCR, CD, PARENT_ID, TYPE_SIZE, TYPE_KIND, dom_id, scode)
  values(d.ID, d.DESCR, d.CD, d.PARENT_ID, d.data_length, d.TYPE_KIND, d.dom_id, d.scode);
insert into types_comp(TYPE_ID, COMP_TYPE_ID)
  select a.id, b.id from dim_levels a, dim_levels b where
   a.dim_id=b.dim_id and a.ordno>=b.ordno
  and not exists(select 1 from types_comp
   where TYPE_ID=a.id and COMP_TYPE_ID=b.id);
commit;
end;
-----------------------------------------------------------------------------
procedure dims2attrs is
 mid attrs.id%type;
begin
 select max(id) into mid from attrs;
 merge into attrs am using(
  select u.*,
    row_number() over(partition by ui order by parent_id, dim_id, ordno) rn
   from (
  select D1.suf, d1.abbr, d1.SHORT, d1.full, D1.ID attr_type, D1.ID dim_lev_id, aa.area_id,
    nvl((select storage_type from dim_levels where id=d1.id),
     nvl(t.parent_id, aa.storage_type)) storage_type,
    nvl(t.TYPE_SIZE, aa.attr_size) attr_size,
    nvl(t.TYPE_PRECISION, aa.attr_precision) attr_precision,
    aa.ID parent_id, D1.ordno, D1.dim_id, (select nvl(max(1), 0) from attrs where parent_id=aa.id and dim_lev_id=D1.id) ui
   from (
     select a.ID, a.AREA_ID, a.STORAGE_TYPE, a.ATTR_SIZE, a.ATTR_PRECISION, a.attr_type,
      tree_fnc.nearest_dim(a.attr_type) dim_lev_id
     from attrs a
   where parent_id is null
  ) aa, dim_levels d1, attr_types t, types_comp tc
   where (aa.dim_lev_id=tc.type_id or aa.attr_type=tc.type_id) and d1.id=tc.comp_type_id and tc.type_id<>tc.comp_type_id
    and t.id=d1.id
  ) u
 ) v on (am.parent_id=v.parent_id and am.dim_lev_id=v.dim_lev_id)
 when matched then
  update set am.suf=v.suf, am.abbr=v.abbr, am.short=v.short, am.full=v.full, am.storage_type=v.storage_type, am.attr_type=v.attr_type
 when not matched then
  insert(id, suf, abbr, short, full, ATTR_TYPE, DIM_LEV_ID, AREA_ID, STORAGE_TYPE,
    ATTR_SIZE, ATTR_PRECISION, PARENT_ID) values
   (mid+v.rn, v.suf, v.abbr, v.short, v.full, v.ATTR_TYPE, v.DIM_LEV_ID, v.AREA_ID, v.STORAGE_TYPE,
    v.ATTR_SIZE, v.ATTR_PRECISION, v.PARENT_ID);
 insert into attrs2cubes(ATTR_ID, CUBE_ID, SHOW)
  select A.ID, ac.CUBE_ID, ac.SHOW
   from attrs2cubes ac, attrs a
   where a.parent_id=ac.attr_id
     and not exists(select 1 from attrs2cubes
      where attr_id=a.id and cube_id=ac.cube_id);
 commit;
end;
-----------------------------------------------------------------------------
procedure updtypes4dims is
begin
  update attr_types t
   set id=(select nvl(max(l.id), t.id) from dim_levels l where l.abbr=t.descr),
   parent_id=(select nvl(max(l.id), t.parent_id) from dim_levels l, attr_types a where
    l.abbr=a.descr and t.parent_id=a.id)
   where type_kind=tree_fnc.dim_type;
commit;
end;
/*-----------------------------------------------------------------------------
procedure create_qrytabs(qry_name varchar2 default null) is
 cursor qq is
  select * from qrys where abbr=qry_name or qry_name is null;
 s varchar2(4000);
 nm varchar2(30);
 tp varchar2(30);
begin
dbms_output.enable;
 for q in qq loop
  s := 'create table "'||q.abbr||'"(';
  for i in (select * from qrys_cols where id=q.id order by ordno) loop
   nm := i.col_name;
   if i.func_grp_id is not null then
	nm :=i.func_grp_id||'('||nm||')';
    i.col_size := i.col_size + 6;
   end if;
   tp := i.col_type;
   if tp<>'DATE' then
	tp := tp||'('||i.col_size;
	if nullif(i.col_precision, 0) is not null then
	 tp := tp||','||i.col_precision;
	end if;
	tp := tp||')';
   end if;
   if i.ordno !=1 then
	s := s||',';
   end if;
   s := s||'"'||nm||'" '||tp;
  end loop;
  s := s||')';
  execute immediate s;
  dbms_output.put_line(s);
 end loop;
end;  */
-----------------------------------------------------------------------------
procedure dims2groups is
begin
-- data_service.ins_dummy_groups; --obsolete, included to ins_dims2groups
--next deletes from grp_tree all the roots, where a group is included somewhere,
--and is temporary or a leaf of conditional or dimentional group
 delete (select t.id from grp_tree t, groups_not_from_d  g
          where t.id=g.id
  and (g.predefined=tree_fnc.get_grp_temporary
       or g.is_leaf=1 and g.grp_type in (tree_fnc.get_cont_group, tree_fnc.get_dim_group))
  and parent_id=tree_fnc.get_root_not_d
  and exists(select 1 from grp_tree where id=t.id));
 delete grp_tree where id<0;
 delete groups where id<0;
 commit;
 data_service.ins_dims2groups;
end;
-----------------------------------------------------------------------------
end;
/