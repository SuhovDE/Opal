--
-- FROM_DB_UTILS  (Package) 
--
--  Dependencies: 
--   ATTRS (Table)
--   ATTRS2CUBES (Table)
--   ATTR_TYPES (Table)
--   CONSTANTS (Package)
--   CUBES (Table)
--   DIM_LEVELS (Table)
--   EXPRS (Table)
--   FUNC_GRP (Table)
--   GROUPS (Table)
--   QRYS (Table)
--   REF_PROCESS (Synonym)
--   TSTRINGS32 (Synonym)
--   STANDARD (Package)
--
CREATE OR REPLACE package OPAL_FRA.from_db_utils as
 expr_sep constant char(1) := ';';
 grp_type_nomulti constant func_grp.grp_type%type := 2;
 func_grp4exprs constant func_grp.id%type := 'SUM';
 subst_par constant varchar2(30) := ':%R1';
 rs_dim_lev_fun constant dim_levels.id%type := -1;
 rs_dim_lev_grp constant dim_levels.id%type := -2;
 rs_dim_lev_tmp constant dim_levels.id%type := -3;
 grp_time_attrs constant tstrings32 := tstrings32('ACTDATE', 'PLANDATE', 'ACTDATE IN', 'PLANDATE IN', 'ACTDATE OUT', 'PLANDATE OUT','TRAVEL_DT');
function get_qry_tab(qry_id_ NUMBER) return varchar2;
pragma restrict_references(get_qry_tab, wnds, wnps);
-----------------------------------------------------------------------------------------
function to_our_date(dt varchar2, msk varchar2 := ref_process.day_mask) return varchar2
  deterministic;
pragma restrict_references(to_our_date, wnds);
 --------------------------------------------------------------------------------
function to_our_date(dt date, msk varchar2 := ref_process.day_mask) return varchar2
 deterministic;
pragma restrict_references(to_our_date, wnds);
 --------------------------------------------------------------------------------
function get_grp_type_nomulti return func_grp.grp_type%type;
 --------------------------------------------------------------------------------
function get_qry_tab_date(qry_id_ NUMBER) return date;
--We use this 2 functions for work with units, not table, because there are too few units
function get_mask4unit(unit attrs.unit%type) return varchar2 deterministic;
pragma restrict_references(get_mask4unit, wnds, wnps, rnds);
function get_mult4unit(unit attrs.unit%type) return number deterministic;
pragma restrict_references(get_mult4unit, wnds, wnps, rnds);
--------------------------------------------------------------------------------
function get_attr_lvl(id_ attrs.id%type, cube_ cubes.id%type)
 return pls_integer;
pragma restrict_references(get_attr_lvl, wnps, wnds, rnps);
--------------------------------------------------------------------------------
function get_expr4sel(id_ exprs.id%type, ordno pls_integer) --the most stupid version
 return varchar2;
pragma restrict_references(get_expr4sel, wnps, wnds);
--------------------------------------------------------------------------------
function get_selcolname(ordno pls_integer)
 return varchar2;
pragma restrict_references(get_selcolname, wnps, wnds, rnps);
--------------------------------------------------------------------------------
function get_exprcolname(ordno pls_integer, ordno_expr pls_integer)
 return varchar2;
pragma restrict_references(get_exprcolname, wnps, wnds, rnps);
--------------------------------------------------------------------------------
function is_exprcolname(colname varchar2)
 return boolean;
pragma restrict_references(is_exprcolname, wnps, wnds, rnps);
--------------------------------------------------------------------------------
procedure concatlist(qry in out nocopy varchar2, str varchar2);
procedure concatbyunit(s in out nocopy varchar2, unit varchar2);
procedure drop_qry_tab(qry_id_ qrys.id%type);
procedure mark_qry(qry_id_ qrys.id%type, starttime number, co_org number := null);
--------------------------------------------------------------------------------
function concat_fun(attr varchar2, FUNC_GRP_ID varchar2,
  func_row_id varchar2 := null) return varchar2;
pragma restrict_references(concat_fun, wnps, wnds);
--------------------------------------------------------------------------------
function get_converted(col_ varchar2, dim_lev_id_ dim_levels.id%type,
  b_attr_id attrs.id%type) return varchar2;
pragma restrict_references(get_converted, wnps, wnds);
--------------------------------------------------------------------------------
function get_display_format(dim_lev_id_ dim_levels.id%type,
   storage_type_ attr_types.id%type, precision_ attrs.attr_precision%type:= null,
   unit attrs.unit%type := null, code_ varchar2 := constants.code_code,
   show_ attrs2cubes.show%type := constants.show_val
 ) return varchar2;
pragma restrict_references(get_display_format, wnds);
--------------------------------------------------------------------------------
function escape_like(s varchar2) return varchar2 deterministic;
pragma restrict_references(escape_like, wnds, wnps, rnds);
--------------------------------------------------------------------------------
function get_rs_dim_lev_id(grp_id_ groups.id%type, dim_lev_ dim_levels.id%type) return dim_levels.id%type;
pragma restrict_references(get_rs_dim_lev_id, wnds, wnps);
pragma restrict_references(from_db_utils, wnds, wnps, rnds);
end;
/