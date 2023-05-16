--
-- FROM_DB_UTILS  (Package Body) 
--
--  Dependencies: 
--   FROM_DB_UTILS (Package)
--   ATTRS (Table)
--   ATTRS2CUBES (Table)
--   ATTRS2RECS (Table)
--   ATTR_TYPES (Table)
--   CONSTANTS (Package)
--   CUBES (Table)
--   DIM_LEVELS (Table)
--   EXPRS (Table)
--   FUNC_GRP (Table)
--   FUNC_ROW (View)
--   GROUPS (Table)
--   LEAFS4EXPRS (Table)
--   QRYS (Table)
--   QRYS_IU (Procedure)
--   RECS_TREE (View)
--   REF_PROCESS (Synonym)
--   RS_CODES4DIMS (Table)
--   TREE_FNC (Package)
--   TYPES_COMP (Table)
--   DBMS_UTILITY (Synonym)
--   PLITBLM (Synonym)
--   USER_OBJECTS (Synonym)
--   USER_TABLES (Synonym)
--   STANDARD (Package)
--
CREATE OR REPLACE package body OPAL_FRA.from_db_utils as
unit_prc constant attrs.unit%type := '%';
expr_col_suf constant char(2) := '_E';
sel_col_pref constant char(1) := 'F';
type numtab is table of pls_integer;
function get_qry_tab(qry_id_ NUMBER) return varchar2 is
  s qrys.abbr%type :=  'PARAM';
begin
 IF qry_id_>= 0 THEN
--  SELECT q.abbr INTO s FROM QRYS q WHERE ID=qry_id_;
  s := 'ZQRY_'||qry_id_;
 END IF;
 return s;
end;
-----------------------------------------------------------------------------------------
function to_our_date(dt varchar2, msk varchar2 := ref_process.day_mask) return varchar2 is
begin
 return 'to_date('''||dt||''','''||msk||''')';
end;
 --------------------------------------------------------------------------------
function to_our_date(dt date, msk varchar2 := ref_process.day_mask) return varchar2 is
begin
 return to_our_date(to_char(dt, msk), msk);
end;
----------------------------------------------------------------------------------
procedure concatlist(qry in out nocopy varchar2, str varchar2) is
begin
 qry := qry||case when qry is not null then ',' end||str;
end;
--------------------------------------------------------------------------------
procedure drop_qry_tab(qry_id_ qrys.id%type) is
  tab varchar2(30) := get_qry_tab(qry_id_);
 begin
  for c in (select table_name, temporary from user_tables where (table_name=tab or table_name like tab||'\__' escape '\') and temporary='N') loop
--   execute immediate 'truncate table "'||c.table_name||'"'; --this can be added not to check TEMPORARY, to avoid theoretically possible conflicts with table name.
   execute immediate 'drop table "'||c.table_name||'" purge';
  end loop;
end;
--------------------------------------------------------------------------------
procedure mark_qry(qry_id_ qrys.id%type, starttime number, co_org number := null) is
  tab constant varchar2(30) := get_qry_tab(qry_id_);
  dt qrys.ex_time%type;
  us qrys.ex_user%type;
  ho qrys.ex_host%type;
  te qrys.ex_term%type;
  t1 number;
  co pls_integer := co_org;
 begin
  if qry_id_ is null then return; end if;
  if co_org is null then
   execute immediate 'select count(*) from "'||tab||'"' into co;
  end if;
  t1 := (dbms_utility.get_time - starttime)/100;
  qrys_iu(us, ho, te, dt);
  update qrys set ex_user=us, ex_host=ho, ex_term=te, ex_time=dt,
    duration=t1, reccount=co
   where id=qry_id_;
end;
-----------------------------------------------------------------------------------------
function get_qry_tab_date(qry_id_ NUMBER) return date is
 tbl varchar2(30) := get_qry_tab(qry_id_);
 dt date;
begin
 select max(last_ddl_time) into dt from user_objects where
  object_type='TABLE' and object_name=tbl;
 return dt;
end;
-----------------------------------------------------------------------------------------
function get_mask4unit(unit attrs.unit%type) return varchar2 is
begin
 if unit=unit_prc then return unit_prc; end if;
 return null;
end;
-----------------------------------------------------------------------------------------
function get_mult4unit(unit attrs.unit%type) return number is
begin
 if unit=unit_prc then return 100; end if;
 if rtrim(unit, '1234567890.') is null then return to_number(unit); end if;
 return null;
end;
-----------------------------------------------------------------------------------------
procedure concatbyunit(s in out nocopy varchar2, unit varchar2) is
 mult number := get_mult4unit(unit);
begin
 s := s||case when mult is not null then '*'||mult end;
end;
--------------------------------------------------------------------------------
procedure get_expr_attrs(id_ exprs.id%type, expr_attrs out nocopy numtab) is
begin
 select * bulk collect into expr_attrs from (
 select l.attr_id
  from exprs e, leafs4exprs l
 where e.id=l.leaf_id(+)
  start with e.id=id_
  connect by e.parent_id=prior e.id
  order siblings by e.ordno
 ) where attr_id is not null;
end;
--------------------------------------------------------------------------------
function get_attr_lvl_base(id_ attrs.id%type, cube_ cubes.id%type)
 return pls_integer is
 rng_ pls_integer;
begin
-- select rng from recs4attrs where
--  attr_id=id_ and cube_id=cube_;
 select min(rng) rng into rng_
  from (
  select r.rng
   from recs_tree r, attrs2recs ar, attrs2cubes ac
   where r.rec=ar.elem_rec_id and ar.attr_id=
     (select nvl(a.parent_id, a.id) from attrs a where id=id_)
	and r.cube_id=cube_
    and ac.cube_id=cube_ and ar.attr_id=ac.attr_id
	and nvl(ac.elem_rec_id, ar.elem_rec_id)=ar.elem_rec_id
  );
return rng_;
exception
when no_data_found then
 return to_number(null);
end;
--------------------------------------------------------------------------------
function get_attr_lvl(id_ attrs.id%type, cube_ cubes.id%type)
 return pls_integer is
 rng_ pls_integer;
 expr_attrs numtab;
 expr_id_ attrs.expr_id%type;
 rng_loc pls_integer;
 i pls_integer;
begin
 rng_ := get_attr_lvl_base(id_, cube_);
 if rng_ is null then
  select max(expr_id) into expr_id_ from attrs where id=id_;
  if expr_id_ is not null then
   get_expr_attrs(expr_id_, expr_attrs);
   i := expr_attrs.first;
   while i is not null loop
    rng_loc := get_attr_lvl_base(expr_attrs(i), cube_);
    if rng_loc>nvl(rng_, -1) then
	  rng_ := rng_loc;
	end if;
    i := expr_attrs.next(i);
   end loop;
  end if;
 end if;
 return rng_;
end;
--------------------------------------------------------------------------------
function get_selcolname(ordno pls_integer)
 return varchar2 is
begin
 return sel_col_pref||ordno;
end;
--------------------------------------------------------------------------------
function is_exprcolname(colname varchar2)
 return boolean is
 i pls_integer := instr(colname, expr_col_suf);
 rc boolean := false;
begin
 if i=0 then return false; end if;
 i := substr(colname, i+length(expr_col_suf));
 return true;
exception
when value_error then
 return false;
end;
--------------------------------------------------------------------------------
function get_exprcolname(ordno pls_integer, ordno_expr pls_integer)
 return varchar2 is
begin
 return get_selcolname(ordno)||expr_col_suf||ordno_expr;
end;
--------------------------------------------------------------------------------
function get_expr4sel(id_ exprs.id%type, ordno pls_integer)
 return varchar2 is
 s varchar2(4000);
 expr_attrs numtab;
 ordno_expr pls_integer := 0;
 i pls_integer;
begin
 get_expr_attrs(id_, expr_attrs);
 i := expr_attrs.first;
 while i is not null loop
  ordno_expr := ordno_expr + 1;
  if s is not null then
   s := s||expr_sep;
  end if;
  s := s||get_exprcolname(ordno, ordno_expr);
  i := expr_attrs.next(i);
 end loop;
 return s;
end;
--------------------------------------------------------------------------------
function get_grp_type_nomulti return func_grp.grp_type%type is
begin
 return grp_type_nomulti;
end;
--------------------------------------------------------------------------------
function concat_fun(attr varchar2, FUNC_GRP_ID varchar2,
  func_row_id varchar2 := null) return varchar2 is
 rl varchar2(255) := attr;
 subst_ func_row.subst%type;
begin
 if FUNC_ROW_ID is not null then
  select subst into subst_ from func_row where id=func_row_id;
  if subst_ is not null then
   rl := replace(subst_, subst_par, rl);
  else
   rl := FUNC_ROW_ID||'('||rl||')';
  end if;
 end if;
 if FUNC_GRP_ID is not null then
  rl := FUNC_GRP_ID||'('||rl||')';
 end if;
 return rl;
end;
--------------------------------------------------------------------------------
function get_converted(col_ varchar2, dim_lev_id_ dim_levels.id%type,
  b_attr_id attrs.id%type) return varchar2 is
 fnc func_row.id%type;
begin
 select max(fun_row_conv) into fnc
  from types_comp tc, attrs a
  where type_id in (a.dim_lev_id, a.attr_type) and comp_type_id=dim_lev_id_
   and a.id=b_attr_id;
 if fnc is null then return null; end if;
 return from_db_utils.concat_fun(col_, null, fnc);
end;
--------------------------------------------------------------------------------
function get_display_format(dim_lev_id_ dim_levels.id%type,
   storage_type_ attr_types.id%type, precision_ attrs.attr_precision%type:= null,
   unit attrs.unit%type := null, code_ varchar2 := constants.code_code,
   show_ attrs2cubes.show%type := constants.show_val) return varchar2 is
 type_mask_ attr_types.type_mask%type;
begin
 /*if show_ = constants.show_key and storage_type_
   not in (constants.timetype, constants.datetype) then
  return null;
 end if;
*/ if nvl(nullif(dim_lev_id_, 0), -1)<>-1 then
  select DISPLAY_FORMAT into type_mask_ from RS_CODES4DIMS
   where DIM_LEV_ID=DIM_LEV_ID_ and ATTR_TYPE_CODE=code_;
 else
  select type_mask||decode(storage_type_,
	  constants.numtype, substr('0000000000', 1, nvl(precision_, type_precision)))
  into type_mask_
  from attr_types where id=storage_type_ and type_mask is not null;
 end if;
 return type_mask_||get_mask4unit(unit);
exception
when no_data_found then return null;
end;
--------------------------------------------------------------------------------
function escape_like(s varchar2) return varchar2 deterministic is
 esc constant char(1) := '|';
 wc1 constant char(1) := '*';
 to1 constant char(1) := '%';
 wc2 constant char(1) := '?';
 to2 constant char(1) := '_';
 ss varchar2(255) := s;
begin
 ss := replace(ss, to1, esc||to1);
 ss := replace(ss, to2, esc||to2);
 ss := replace(ss, wc1, to1);
 ss := replace(ss, wc2, to2);
 if ss <> s then
  ss := ss||' escape '''||esc||'''';
 end if;
 return ss;
end;
----------------------------------------------------------------------------------
function get_rs_dim_lev_id(grp_id_ groups.id%type, dim_lev_ dim_levels.id%type) return dim_levels.id%type is
 rc dim_levels.id%type := rs_dim_lev_fun;
begin
 if grp_id_>0 then
  select decode(predefined, tree_fnc.is_temporary, rs_dim_lev_tmp, rs_dim_lev_grp)
   into rc from groups where id=grp_id_;
 elsif dim_lev_ is not null then
  rc := dim_lev_;
 end if;
 return rc;
end;
----------------------------------------------------------------------
end;
/