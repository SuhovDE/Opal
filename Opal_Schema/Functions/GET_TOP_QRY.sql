--
-- GET_TOP_QRY  (Function) 
--
--  Dependencies: 
--   CONSTANTS (Package)
--   ERRORS (Synonym)
--   FROM_DB_UTILS (Package)
--   SHOW_QRYS_SEL_FLAT (View)
--   TOPELEM (Type)
--   TOPLIST (Type)
--   T_PARAMETER (Type)
--   T_PARAMETERS (Type)
--   PLITBLM (Synonym)
--   STANDARD (Package)
--   SYS_STUB_FOR_PURITY_ANALYSIS (Package)
--
CREATE OR REPLACE function OPAL_FRA.get_top_qry
(queryid in number, list in toplist) return varchar2 as
 err_no_top constant pls_integer := 11;
 fmt constant varchar2(30) := '90.000';
 qry varchar2(32000);
 type numtab is table of pls_integer index by binary_integer;
 i pls_integer;
 j pls_integer;
 k pls_integer;
 CRLF constant varchar2(2) := chr(13)||chr(10);
 tbl constant varchar2(30) := ':TBL';
 sel constant varchar2(30) := ':SEL';
 prt constant varchar2(30) := ':PRT';
 prv constant varchar2(30) := ':PRV';
 mes constant varchar2(30) := ':MES';
 mel constant varchar2(30) := ':MEL';
 grp constant varchar2(30) := ':GRP';
 tot constant varchar2(30) := ':TOT';
 cas constant varchar2(30) := ':CAS';
 dsc constant varchar2(30) := ':ASC';
 fun constant varchar2(30) := ':FUN';
 fld constant varchar2(30) := ':FLD';
 rng constant varchar2(30) := ':RNG';
 cnd constant varchar2(30) := ':CND';
 rst constant varchar2(30) := ':RST';
 rngnum constant pls_integer := 1000;
 selq varchar2(1000);
 prtq varchar2(256) := 'partition by ';
 prvq varchar2(256);
 melq varchar2(256);
 zmelq varchar2(256);
 grpq varchar2(256);
 totq varchar2(1000);
 casq varchar2(4000);
 casqtmp varchar2(256);
 fldq varchar2(30);
 rngq varchar2(256);
 cndq varchar2(256);
 rstq varchar2(256);
 exprcols varchar2(1000);
 casl t_parameters := t_parameters();
 totl t_parameters := t_parameters();
 allords numtab;
 alltyps numtab;
 alllevs numtab;
 qrya constant varchar2(1000) :=
 'select '||grp||','||tot||'
from (
select
 '||cas||mel||'
from (
select '||sel||', min(ron) over('||prt||') '||fld||'
from (
select '||sel||',
 '||fun||'() over('||prv||' order by case when ron=1 then cs end '
  ||dsc||' nulls last) ron
from (
select
  '||sel||',
  row_number() over('||prt||' order by 1) ron,
    sum('||mes||') over('||prt||') cs
 from '||tbl||'
))))';
 qryp constant varchar2(1000) :=
 'select '||grp||','||tot||'
from (
select
 '||cas||mel||'
from (
select '||sel||', '||fld||',
 nvl(sum(cs)
  over('||prv||' order by '||rng||' range between unbounded preceding and 1 preceding), 0) cs
  from (
select '||sel||',
  case when ron=1 then cs end cs,
  dense_rank() over('||prv||' order by cs '||dsc||') '||fld||'
 from (
select
  '||sel||',
  sum('||mes||') over('||prt||')/nullif(sum('||mes||') over('||prv||'), 0) cs,
  row_number() over('||prt||' order by 1) ron
 from '||tbl||'
))))';
qrytmp varchar2(32000);
lvl pls_integer := 0;
toplvl number;
toplvlstr varchar2(30);
currord pls_integer;
qrylvl pls_integer := -1;
tmp varchar2(256);
tmpn varchar2(256);
j1 pls_integer;
RDim varchar2(256);
rn_dummy constant pls_integer := 999999999;
procedure extend_t_par(par in out nocopy t_parameters) is
begin
 if par is null then par := t_parameters(); end if;
 par.extend; par(par.last) := t_parameter(null, null);
end;
begin
 if list is null or queryid is null then goto ret_null; end if;
 for c in (select basic_attr_id, ordno, basic_attr_type, attr_lvl, grp_type,
 	   	  	    storage_type, rs_name, rs_expr, attr_type_code, rs_ftype
            from show_qrys_sel_flat q
            where qry_id=queryid
			order by ordno) loop
  if selq is not null then selq:=selq||','; end if;
  if c.basic_attr_type=constants.show_key then
   if grpq is not null then grpq:=grpq||','; end if;
   grpq := grpq||c.rs_name;
   extend_t_par(casl); j := casl.last;
   casl(j).value := c.rs_name;
   casl(j).name := c.rs_name;
   allords(j) := c.ordno;
   alltyps(j) := c.storage_type;
   alllevs(j) := c.attr_lvl;
  else
   melq := melq||','||c.rs_name;
   zmelq := zmelq||','||c.rs_name;
--   qrylvl := greatest(c.attr_lvl, qrylvl);
   if c.rs_expr is not null then
    c.rs_expr := replace(c.rs_expr, from_db_utils.expr_sep, ',');
    if exprcols is not null then exprcols := exprcols||','; end if;
    exprcols := exprcols||c.rs_expr;
   end if;
   extend_t_par(totl); j := totl.last;
   j1 := j;
   if c.rs_expr is null or c.grp_type=from_db_utils.grp_type_nomulti then
    totl(j).value := c.rs_name;
    if  c.attr_type_code is not null then
     totl(j).value := from_db_utils.concat_fun(totl(j).value, c.attr_type_code);
    end if;
   else
    if c.rs_ftype=1 then --the most stupid way, but let it be
     k := instr(c.rs_expr, ',');
     totl(j).value := '100*'||
	     from_db_utils.concat_fun(trim(substr(c.rs_expr, 1, k-1)), from_db_utils.func_grp4exprs)||
      '/'||from_db_utils.concat_fun(trim(substr(c.rs_expr, k+1)), from_db_utils.func_grp4exprs,
	       'NULLIF0');
	   end if;
    tmp := c.rs_expr||',';
    k := instr(tmp, ',');
    while k>0 loop
     extend_t_par(totl);
     tmpn := trim(substr(tmp, 1, k-1));
     totl(totl.last).value := from_db_utils.concat_fun(tmpn, from_db_utils.func_grp4exprs)||' '||tmpn;
     tmp := ltrim(substr(tmp, k+1));
     k := instr(tmp, ',');
    end loop;
   end if;
   totl(j).value := totl(j).value||' '||c.rs_name;
   if c.grp_type<>from_db_utils.grp_type_nomulti then
    for jj in j1..totl.last loop
     totl(jj).name:=c.attr_lvl;
    end loop;
   end if;
  end if;
  selq := selq||c.rs_name;
 end loop;
 extend_t_par(casl);
 casl(casl.last).value :=
   'case when '||cnd||' then '||fld||' else '||rn_dummy||' end '||fld;
 allords(casl.last) := null;
 alltyps(casl.last) := null;
 if exprcols is not null then
  selq := selq||','||exprcols;
  melq := melq||','||exprcols;
  zmelq := zmelq||','||exprcols;
 end if;
 i := list.first;
 qry := from_db_utils.get_qry_tab(queryid);
 while i is not null loop
  lvl := lvl+1;
  fldq := 'rn'||lvl;
  toplvl := list(i).TopLevel;
  RDim := nullif(rtrim(list(i).rdimsqlval), 'NULL');
  j := casl.first;
  currord := null;
  while j is not null loop
   if casl(j).name=list(i).DimField then
    currord := allords(j);
	qrylvl := alllevs(j);
	exit;
   end if;
   j := casl.next(j);
  end loop;
  if currord is null then
   errors.raise_err(err_no_top, constants.qry_task, list(i).DimField, lvl, do_raise=>true);
  end if;
  if alltyps(j)<>constants.chartype then
   RDim := null;
  end if;
  if list(i).absprc=1 then
   cndq := fldq;
   qrytmp := qrya;
   ToplvlStr := to_char(round(abs(Toplvl)));
  else
   cndq := 'cs';
   if rngq is not null then
    rngq := '('||rngq||')*'||rngnum||'+';
   end if;
   rngq:= rngq||fldq;
   toplvl := toplvl/100;
   toplvlstr := to_char(abs(toplvl), fmt);
   qrytmp := qryp;
  end if;
  if i<>list.first then
   qry := '('||qry||')';
   prtq := prtq||',';
  end if;
  qrytmp := replace(qrytmp, tbl, qry);
  prtq := prtq||list(i).DimField;
  grpq := grpq||','||fldq;
  if rdim is not null then
   rstq := ''''||rdim||'''';
  else
   rstq := 'null';
  end if;
  qrytmp := replace(qrytmp, prt, prtq);
  qrytmp := replace(qrytmp, prv, prvq);
  qrytmp := replace(qrytmp, fld, fldq);
  qrytmp := replace(qrytmp, sel, selq);
  qrytmp := replace(qrytmp, grp, grpq);
  qrytmp := replace(qrytmp, mel, melq);
  qrytmp := replace(qrytmp, rng, rngq);
  qrytmp := replace(qrytmp, mes, list(i).FactField);
  qrytmp := replace(qrytmp, fun,
    case when list(i).Strict=1 then 'row_number' else 'dense_rank' end);
  qrytmp := replace(qrytmp, dsc,
    case when TopLvl>0 then 'desc' else 'asc' end);
  j := casl.first; casq := null;
  cndq := cndq||'<='||Toplvlstr;
  while j is not null loop
   casqtmp := casl(j).value;
   if allords(j)=currord then
    casqtmp :=  'case when '||cnd||' then '||casqtmp||' else '||rst||' end '||casqtmp;
   end if;
   casqtmp := replace(replace(casqtmp, cnd, cndq), fld, fldq);
   casqtmp := replace(casqtmp, rst,
	 case when allords(j)=currord then rstq else 'null' end);
   if casq is not null then casq := casq||','||crlf; end if;
   casq := casq||casqtmp;
   j := casl.next(j);
  end loop;
  qrytmp := replace(qrytmp, cas, casq);
  if list(i).showrest=0 then
   totq := zmelq;
   qrytmp := qrytmp||crlf||'where nullif('||fldq||', '||rn_dummy||') is not null';
  else
   qrytmp := qrytmp||crlf||'group by '||grpq;
   totq := null;
   j := totl.first;
   while j is not null loop
    tmp := totl(j).value;
    if to_number(totl(j).name)<qrylvl then
     k := instr(tmp, ' ', -1);
     tmp := '('||substr(tmp, 1, k-1)||')*nvl2('
      ||'nullif('||fld||','||rn_dummy||'), 1, null) '||substr(tmp, k+1);
	    end if;
    if totq is not null then totq := totq||','; end if;
	   totq := totq||replace(tmp, fld, fldq);
    j := totl.next(j);
   end loop;
  end if;
  totq := ltrim(totq, ','); --very strange!!!!!!!!
  qrytmp := replace(qrytmp, tot, totq);
  qry := qrytmp;
  i := list.next(i);
  prvq := prtq;
  selq := selq||','||fldq;
  melq := melq||','||fldq;
 end loop;
 return qry;
<<ret_null>>
 return null;
end;
/