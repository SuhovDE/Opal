--
-- FROM_XLS  (Package) 
--
--  Dependencies: 
--   RS_CODES4DIMS (Table)
--   STANDARD (Package)
--
CREATE OR REPLACE package OPAL_FRA.from_xls as
--procedure create_qrytabs(qry_name varchar2 default null);
procedure delete_qrydata;
procedure delete_metadata;
procedure dims2groups;
procedure i_areas(
  abbr varchar2, maxl_abbr integer, short varchar2, maxl_short integer,
  full varchar2, maxl_full integer,
  parent_abbr varchar2, scode varchar2);
procedure i_attrs(
  abbr varchar2, maxl_abbr integer,
  attr_type varchar2, dim_lev varchar2, area varchar2, expr varchar2,
  parent_abbr varchar2,
  storage_type varchar2, attr_size integer, attr_precision integer,
  unit varchar2,
  short varchar2, maxl_short integer,
  full varchar2, maxl_full integer, scode varchar2);
procedure i_attrs2cubes(attr varchar2, cube varchar2, show varchar2, col varchar2,
 elem_rec varchar2);
procedure i_cubes(
 abbr varchar2, maxl_abbr integer, short varchar2, maxl_short integer,
 full varchar2, maxl_full integer, tab_ varchar2,
 parent_abbr varchar2,
 c_abbr varchar2, c_maxl_abbr integer, c_short varchar2, c_maxl_short integer,
 c_full varchar2, c_maxl_full integer, scode varchar2);
procedure i_dims(
  abbr varchar2, tabname varchar2, maxl_abbr integer, short varchar2, maxl_short integer,
  full varchar2, maxl_full integer, add_dim varchar2, parent_abbr varchar2,
  dom_name varchar2, scode varchar2);
procedure i_domains(
  abbr varchar2, maxl_abbr integer, short varchar2, maxl_short integer,
  full varchar2, maxl_full integer, scode varchar2);
procedure i_dim_levels(
  abbr varchar2, maxl_abbr integer,
  Dim_Abbr varchar2, Ordno integer, dom_name varchar2,
  tab_name varchar2, col_name varchar2, parent_col_name varchar2,
  col_in_dims varchar2, storage_type varchar2,
  short varchar2, maxl_short integer,
  full varchar2, maxl_full integer, scode varchar2);
procedure i_attr_types(
  abbr varchar2, Parent_Abbr varchar2, type_size integer,
  type_precision integer, type_mask varchar2, dom_name varchar2, scode varchar2);
procedure i_res_set(dim_lev varchar2, attr_type_code rs_codes4dims.attr_type_code%type,
 attr_type_name rs_codes4dims.attr_type_name%type,
 display_format rs_codes4dims.display_format%type,
 rs_name_suf rs_codes4dims.rs_name_suf%type, colname rs_codes4dims.colname%type,
 noshow rs_codes4dims.noshow%type, scode varchar2);
procedure i_exprs(
  descr varchar2, parent_descr varchar2, Ordno integer,
  op_sign varchar2, is_leaf integer);
procedure i_func_row(
  id varchar2, func_type varchar2, par_no integer, subst varchar2,
  par_type varchar2, ret_type varchar2);
procedure i_exprs_leafs(
  descr varchar2, un_sign varchar2, attr varchar2, const varchar2,
  func_row_id varchar2);
procedure i_attrs2recs(elem_rec_id varchar2, attr varchar2, col_name varchar2);
procedure i_recs2cubes(elem_rec_id varchar2, cube varchar2, parent_id varchar2,
 how_much varchar2);
procedure i_types_comp(type_id varchar2, comp_type_id varchar2,
 func_row_id varchar2, func_row_back varchar2);
procedure i_qrys(abbr varchar2, qry_type integer, where_ varchar2, having_ varchar2,
 predefined varchar2, cube varchar2, short varchar2);
/*
procedure i_aggrs(aggr varchar2, group_abbr varchar2, aggr_typ varchar2);
procedure i_aggr_levels(aggr varchar2, ordno integer, level_down integer,
  group_abbr varchar2);
*/
procedure i_qrys_sel(abbr varchar2, attr varchar2, func_grp_id varchar2, grp varchar2,
 grp_lev_ordno integer, ordno integer, dim_lev varchar2 := '');
--procedure i_qrys_ord(abbr varchar2, sel_list_no integer, ordno integer, sort_kind varchar2);
--procedure i_qrys_top(abbr varchar2, ordno integer, tb varchar2, rows_no integer,
--   sel_attr varchar2, ord_attr varchar2, others varchar2);
procedure i_grp_tree(abbr varchar2, parent_abbr varchar2, ordno number, allrest varchar2);
procedure i_groups(abbr varchar2, maxl_abbr integer, predefined varchar2,
 grp_type varchar2, attr varchar2, attr_type varchar2, Dim_Abbr varchar2, is_leaf integer,
 short varchar2, maxl_short integer, full varchar2, maxl_full integer);
/*
procedure i_qrys_grp(abbr varchar2, attr varchar2, grp varchar2, grp_lev_ordno integer);
procedure i_group_levels(
  Grp_Abbr varchar2, Ordno integer,
  abbr varchar2, maxl_abbr integer,
  short varchar2, maxl_short integer,
  full varchar2, maxl_full integer);
*/
--procedure i_grp_a(abbr varchar2, attr_vals vals);
procedure i_grp_c(grp_abbr varchar2, cond varchar2);
procedure i_grp_d(grp_abbr varchar2, dim_lev varchar2,
 dim_lev_code varchar2, cond varchar2);
procedure i_conds(
  descr varchar2, parent_descr varchar2, Ordno integer,
  op_sign varchar2, is_leaf integer, gh varchar2);
procedure i_conds_leafs(
  cond varchar2, op_sign varchar2, is_compare varchar2,
  left_attr varchar2, left_dim_lev varchar2 := '', left_func_row_id varchar2, left_func_grp_id varchar2,
  const varchar2, grp varchar2,
  right_attr varchar2, right_dim_lev varchar2 := '', right_func_row_id varchar2, right_func_grp_id varchar2);
procedure dims2types;
procedure dims2attrs;
procedure updtypes4dims;
end;
/