--
-- J_FULL  (Function) 
--
--  Dependencies: 
--   ANALYZER (Package)
--   ATTRS (Table)
--   EXPRS (Table)
--   FUNC_GRP (Table)
--   GET_CONST (Function)
--   QRYS (Table)
--   QRYS_SEL (Table)
--   QRYS_SEL_RS4DIMS (Table)
--   RS_CODES4DIMS_ALL (View)
--   DUAL (Synonym)
--   STANDARD (Package)
--   SYS_STUB_FOR_PURITY_ANALYSIS (Package)
--
CREATE OR REPLACE function OPAL_FRA.j_full(qry_id_ qrys.id%type, ordno_ qrys_sel.ordno%type, expr_id_ ATTRS.EXPR_ID%type, dim_lev_id_ qrys_sel.dim_lev_id%type,
  rs_dim_lev_id  qrys_sel.dim_lev_id%type, grp_type_ func_grp.grp_type%type, unit attrs.unit%type, attr_info_type varchar2, basic_attr_suf attrs.suf%type,
  result_set_colname varchar2, func_grp_id qrys_sel.func_grp_id%type, basic_attr_id attrs.id%type) return varchar2 as
 rc varchar2(4000);
begin
 select (select json_arrayagg(
    json_object(KEY 'attr_type_code' VALUE coalesce(func_grp_id, ATTR_TYPE_CODE),
     KEY 'attr_type_name' VALUE ATTR_TYPE_NAME, KEY 'rs_name' VALUE concat(concat(result_set_colname,
       case when RS_NAME_SUF is not null then '_' end), RS_NAME_SUF),
     KEY 'rs_display_name' VALUE concat(concat(rtrim(concat(concat(basic_attr_suf, ' '), attr_info_type)), ' '), attr_type_name),
     KEY 'display_format' VALUE case when dim_lev_id_ is not null then rs.display_format
      else (select display_format from attrs where id=basic_attr_id) end,
     KEY 'colname' VALUE colname,
     KEY 'rs_ftype' VALUE case when expr_id_ is not null and grp_type_<>get_const('grp_type_nomulti') then
      case when analyzer.get_version=3 then to_number(case when unit='%' then '100' else nvl(unit, 1) end) else 1 end else 0 end, --what means this 1, nobody knows
     KEY 'rs_expr' VALUE case when expr_id_ is not null and grp_type_<>get_const('grp_type_nomulti') then (select replace(rs_expr, ':%NO', ordno_)  from exprs where id=expr_id_) end))
    from rs_codes4dims_all rs where dim_lev_id=rs_dim_lev_id
     and (coalesce(dim_lev_id_, -99)<0 or 0=(select count(*) from qrys_sel_rs4dims where qry_id=qry_id_ and ordno=ordno_)
       or rs.attr_type_code in (select val from qrys_sel_rs4dims where qry_id=qry_id_ and ordno=ordno_))
   ) into rc from dual;
 return rc;
end;
/