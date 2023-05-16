--
-- FROM_DB  (Package Body) 
--
--  Dependencies: 
--   FROM_DB (Package)
--   TSTRINGS32 (Type)
--   ANALYZER (Package)
--   APP_LOG (Synonym)
--   ATTRS (Table)
--   ATTRS2CUBES (Table)
--   ATTR_TYPES (Table)
--   CONDS (Table)
--   CONSTANTS (Package)
--   CUBES (Table)
--   DATASETS (Table)
--   DB_DIFF (Package)
--   DIMS (Table)
--   DIM_LEVELS (Table)
--   ERRORS (Synonym)
--   ERROR_CODES (Package)
--   EXPRS (Table)
--   FOR_QRY (Package)
--   FROM_DB_UTILS (Package)
--   FUNC_GRP (Table)
--   FUNC_ROW (View)
--   GEN_COPY4USER (Synonym)
--   GET_PH_GROUP (Function)
--   GROUPS (Table)
--   GROUPS_FNC (Package)
--   GRP_C (Table)
--   GRP_D (Table)
--   GRP_MEMBER (Type)
--   GRP_MEMBERS (Type)
--   GRP_P (Table)
--   GRP_TREE (Table)
--   LEAFS4CONDS (Table)
--   LEAFS4EXPRS (Table)
--   MULTIPLIER (Table)
--   PARAMS (Table)
--   QRYS (Table)
--   QRYS_SEL (Table)
--   QRY_GRP_HEADERS (Table)
--   RECS_TREE (View)
--   REF_PROCESS (Synonym)
--   RS_CODES4DIMS (Table)
--   SHOW_ATTRS (View)
--   SHOW_QRYS_SEL_FLAT (View)
--   SQLERRM4USER (Synonym)
--   STR4USER (Synonym)
--   TEST_QRY (Table)
--   TMP_GROUPS (Table)
--   TREE_FNC (Package)
--   TREE_NODE (Type)
--   TREE_NODES (Type)
--   TSTRINGS32 (Synonym)
--   TYPES_COMP (Table)
--   UTILS (Synonym)
--   WRITE_LOG (Synonym)
--   COLS (Synonym)
--   DBMS_UTILITY (Synonym)
--   PLITBLM (Synonym)
--   USER_TAB_COLUMNS (Synonym)
--   DBMS_STANDARD (Package)
--   STANDARD (Package)
--
CREATE OR REPLACE PACKAGE BODY OPAL_FRA.From_Db AS
 TYPE attrs_type_rec IS RECORD(ID ATTRS.ID%TYPE, bid ATTRS.ID%TYPE, ordno PLS_INTEGER,
  in_cond VARCHAR(1), proc_lvl PLS_INTEGER, COL ATTRS2CUBES.COL%TYPE,
  code show_attrs.code%TYPE, dim_lev_id ATTRS.dim_lev_id%TYPE, dim_id DIMS.ID%TYPE,
  storage_type ATTRS.storage_type%TYPE, grp_id GROUPS.ID%TYPE, rng PLS_INTEGER,
  func_grp_id FUNC_GRP.ID%TYPE, expr_id ATTRS.expr_id%TYPE, unit ATTRS.unit%TYPE, show attrs2cubes.show%type, scode attrs.scode%type);
 TYPE attrs_type_tab IS TABLE OF attrs_type_rec;
 TYPE qry_head_type IS RECORD(ID QRYS.ID%TYPE, where_ QRYS.where_id%TYPE,
  having_ QRYS.having_id%TYPE, cube_ QRYS.cube_id%TYPE, qry_type_ QRYS.qry_type%TYPE,
  abbr QRYS.abbr%TYPE, TAB VARCHAR2(30), is_grouping PLS_INTEGER,
  minrng PLS_INTEGER := 999999, maxrng PLS_INTEGER := -1,
  is_fun_top PLS_INTEGER := 0, is_fun_mid  PLS_INTEGER := 0, maxsrcrng PLS_INTEGER);
 TYPE sel_list_rec IS RECORD(ATTR_ID QRYS_SEL.ATTR_ID%TYPE,
   FUNC_GRP_ID QRYS_SEL.FUNC_GRP_ID%TYPE, GRP_ID QRYS_SEL.GRP_ID%TYPE,
   GRP_LEV_ORDNO QRYS_SEL.GRP_LEV_ORDNO%TYPE, ORDNO QRYS_SEL.ORDNO%TYPE,
   grp_type FUNC_GRP.grp_type%TYPE, attr_ind PLS_INTEGER, COL ATTRS2CUBES.COL%TYPE,
   act_col VARCHAR2(255), how QRYS_SEL.HOW%TYPE, scode attrs.scode%type);
 TYPE sel_list_tab IS TABLE OF sel_list_rec INDEX BY BINARY_INTEGER;
 TYPE condrow IS RECORD (ID CONDS.ID%TYPE, parent_id CONDS.parent_id%TYPE,
  op_sign CONDS.op_sign%TYPE, is_leaf PLS_INTEGER, lvl PLS_INTEGER);
 TYPE condrows IS TABLE OF condrow;
 TYPE gen_state_type IS RECORD(lvl PLS_INTEGER, alias VARCHAR2(30),
   addcolno PLS_INTEGER:=0, is_rownum1 BOOLEAN := FALSE, is_rownum2 BOOLEAN := FALSE);
 TYPE chartab IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
 TYPE numtab IS TABLE OF PLS_INTEGER INDEX BY BINARY_INTEGER;
 TYPE numtab2 IS TABLE OF numtab INDEX BY BINARY_INTEGER;
 TYPE longcharwithtype IS RECORD(s VARCHAR2(16000), t CHAR(1));
 TYPE longchartab IS TABLE OF longcharwithtype INDEX BY BINARY_INTEGER;
 TYPE longchartab2 IS TABLE OF longchartab INDEX BY BINARY_INTEGER;
 ds_list gen_copy4user.vc_list;
 qry_attrs attrs_type_tab;
 qry_head qry_head_type;
 gen_state gen_state_type;
 sel_list sel_list_tab;
 exprs_list longchartab2;
 listdelim VARCHAR2(3) := '|';
 NOT_IN_GROUP CONSTANT VARCHAR2(30) := 'IRRELEVANT';
 err_no_attr CONSTANT PLS_INTEGER := 6;
 err_no_db CONSTANT PLS_INTEGER := 7;
 CRLF CONSTANT VARCHAR2(2) := utils.crlf;
 add_col_alias CONSTANT VARCHAR2(30) := 'FA';
 nested_col_alias CONSTANT VARCHAR2(30) := 'FN';
 FRONT_DATE_MASK CONSTANT VARCHAR2(30) := 'YYYY.MM.DD';
 top_rng PLS_INTEGER := 1;
 mid_rng PLS_INTEGER := 2;
 low_rng PLS_INTEGER := 3;
 tree_cond PLS_INTEGER := 1;
 tree_expr PLS_INTEGER := 2;
 tabopenbr CONSTANT CHAR := '(';
 tabclosebr CONSTANT CHAR := ')';
 taboper CONSTANT CHAR := 'O';
 tabattr CONSTANT CHAR := 'A';
 tabtmp CONSTANT CHAR := 'T';
 maxordno CONSTANT PLS_INTEGER := 9999;
 reg_qry CONSTANT PLS_INTEGER := 1;
 reg_sel CONSTANT PLS_INTEGER := 2;
 reg_ind_sel CONSTANT PLS_INTEGER := 3;
 int_type_single CONSTANT PLS_INTEGER := 1;
 int_type_mult  CONSTANT PLS_INTEGER := 2;
 ph CONSTANT CHAR(1) := CHR(1);
 int_where CONSTANT VARCHAR2(30) := ph||'WHERE'||ph;
 int_rownum CONSTANT VARCHAR2(30) := ph||'ROWNUM'||ph;
 rownum_col1 CONSTANT VARCHAR2(30) := 'rownum_1';
 rownum_col2 CONSTANT VARCHAR2(30) := 'rownum_2';
 rownumds_col1 CONSTANT VARCHAR2(30) := 'rownumds_1';
 rownumds_col2 CONSTANT VARCHAR2(30) := 'rownumds_2';
 intsep CONSTANT CHAR(1) := CHR(1);
 grp_time_attr attrs.id%type;
 grp_time_dim_lev dim_levels.id%type;
 dataset_nos numtab;
 curr_dataset_no pls_integer := 0;
 opal_ver constant pls_integer := ANALYZER.GET_VERSION;
----------------------------------------------------------------------------------
procedure adjust_column(s in out nocopy varchar2, column_name cols.column_name%type, data_type cols.data_type%type, data_length cols.data_length%type,
 data_precision cols.data_precision%type) is
begin
  if data_type='NUMBER' and data_length=22 and data_precision is null then
   s := s||' cast(t.'||column_name||' as number(28, 5)) '||column_name;
  else
   s := s||'t.'||column_name;
  end if;
  s := s||',';
end;
----------------------------------------------------------------------------------
function get_main_qry(qry_tab varchar2, rng pls_integer := 0) return varchar2 is
 s varchar2(4000);
begin
 for c in (select column_name, data_type, data_length, data_precision from user_tab_columns where table_name=qry_tab) loop
  adjust_column(s, c.column_name, c.data_type, c.data_length, c.data_precision);
 end loop;
 return 'select '||rtrim(s, ',')||' from "'||qry_tab||'" t where dataset_no='||rng;
end;
----------------------------------------------------------------------------------
procedure set_grp_time_attr is
begin
 grp_time_attr := null;
 for i in (select * from table(from_db_utils.grp_time_attrs) order by 1 desc) loop
  for j in 1..sel_list.count loop
   if sel_list(j).scode=i.column_value then
    grp_time_attr := sel_list(j).attr_id;
    return;
   end if;
  end loop;
  for j in 1..qry_attrs.count loop
   if qry_attrs(j).scode=i.column_value then
    grp_time_attr := qry_attrs(j).id;
    return;
   end if;
  end loop;
 end loop;
end;
----------------------------------------------------------------------------------
procedure check_grp_time(grp_id_ groups.id%type) is
 name_ groups.abbr%type;
begin
 if grp_time_attr is null then
  for c in (select id from grp_tree where parent_id=grp_id_ and (date_from is not null or date_to is not null)) loop
   select g.abbr into name_ from groups g where id=grp_id_;
   errors.raise_err(25, constants.qry_task, name_, do_raise=>true);
  end loop;
 end if;
end;
----------------------------------------------------------------------------------
PROCEDURE form_conds(qry IN OUT NOCOPY VARCHAR2, cond_id_ CONDS.ID%TYPE,
  prefix VARCHAR2 := '', attr_id ATTRS.ID%TYPE := NULL,
  tree_kind PLS_INTEGER := tree_cond, grp_id_ GROUPS.ID%TYPE := NULL);
----------------------------------------------------------------------------------
PROCEDURE form_qry(qry IN OUT VARCHAR2, sel_str VARCHAR2, from_str VARCHAR2 :=NULL,
  group_str VARCHAR2 := NULL, hints_str VARCHAR2 := NULL) IS
BEGIN
  if qry like '%select%' then qry := '('||qry||')'; end if;  --no extra brackets in mysql
  qry := 'select '||hints_str||sel_str||case when gen_state.lvl>6 and instr(sel_str, 'dataset_no')=0 then ', '||db_diff.get_nvl||'(dataset_no, 0) dataset_no' end
   ||crlf||' from '
   ||qry||' '||NVL(from_str, gen_state.alias)||crlf||
   CASE WHEN group_str IS NOT NULL THEN 'group by '||group_str END;
END;
FUNCTION is_only_top_rng RETURN BOOLEAN IS
BEGIN
 RETURN (qry_head.maxrng=top_rng AND qry_head.maxsrcrng<low_rng);
END;
----------------------------------------------------------------------------------
FUNCTION is_dim_date(dim_id DIMS.ID%TYPE, storage_type ATTRS.storage_type%TYPE := NULL)
 RETURN BOOLEAN IS
  ret PLS_INTEGER;
BEGIN
 IF storage_type IN (Constants.datetype,Constants.timetype) THEN
  RETURN TRUE;
 END IF;
 IF dim_id IS NULL THEN RETURN FALSE; END IF;
 SELECT MAX(1) INTO ret FROM DIMS d
  WHERE ID=dim_id AND scode=Constants.dates_dim;
 RETURN (ret IS NOT NULL);
END;
----------------------------------------------------------------------------------
FUNCTION is_add_col_empty(col_ VARCHAR2) RETURN BOOLEAN IS
BEGIN
 RETURN col_ IS NULL OR RTRIM(col_, '0123456789')=add_col_alias;
END;
 --------------------------------------------------------------------------------
FUNCTION is_col_nested(col_ VARCHAR2) RETURN BOOLEAN IS
BEGIN
 RETURN col_ IS NOT NULL AND RTRIM(col_, '0123456789')=nested_col_alias;
END;
 --------------------------------------------------------------------------------
 PROCEDURE set_addcol(i PLS_INTEGER, alias VARCHAR2 := add_col_alias) IS
 BEGIN
  IF qry_attrs(i).COL IS NULL THEN
   gen_state.addcolno := gen_state.addcolno+1;
   qry_attrs(i).COL := alias||gen_state.addcolno;
  END IF;
 END;
 --------------------------------------------------------------------------------
 FUNCTION extend_qry_attrs(i PLS_INTEGER) RETURN PLS_INTEGER IS
  last_added PLS_INTEGER;
 BEGIN
  qry_attrs.EXTEND;
  last_added := qry_attrs.LAST;
  qry_attrs(last_added) := qry_attrs(i);
  qry_attrs(last_added).COL := '';
  RETURN last_added;
 END;
 --------------------------------------------------------------------------------
FUNCTION quote_const(storage_type ATTRS.storage_type%TYPE,
 const_ VARCHAR2, dim_lev_id_ DIM_LEVELS.ID%TYPE := NULL) RETURN VARCHAR2 IS
 msk VARCHAR2(30);
BEGIN
 IF storage_type IN (Constants.chartype, Constants.timetype) THEN
  RETURN ''''||const_||'''';
 ELSIF storage_type IN (Constants.datetype) THEN --we decode only day constants from front end
  msk := FRONT_DATE_MASK;
--  if dim_lev_id_ is not null then
--   select nvl(max(type_mask), msk) into msk from show_types where id=dim_lev_id_;
--  end if;
  RETURN Db_Diff.get_date(const_, msk);
 END IF;
 RETURN const_;
END;
----------------------------------------------------------------------------------
FUNCTION quote_between(col_ VARCHAR2, dim_lev_code GRP_D.dim_lev_code%TYPE,
  dim_lev DIM_LEVELS.ID%TYPE) RETURN VARCHAR2 IS
 dt1 DATE;
 dt2 DATE;
BEGIN
 if dim_lev is null then return null; end if;
 for_qry.get_dates_from_code(dim_lev_code, dim_lev, dt1, dt2);
 IF dt2 IS NOT NULL THEN
  RETURN col_||' between '||Db_Diff.get_date(dt1)||' and '||Db_Diff.get_date(dt2);
 ELSE
  RETURN col_||' = '||Db_Diff.get_date(dt1);
 END IF;
exception
when no_data_found then raise_application_error(-20102, col_||':'||dim_lev||dim_lev_code, true);
END;
----------------------------------------------------------------------------------
PROCEDURE add_tab2qry(s IN OUT VARCHAR2, TAB longchartab, prefix VARCHAR2 := '',
 reg PLS_INTEGER := reg_qry) IS
  j PLS_INTEGER;
BEGIN
 IF TAB.FIRST IS NULL THEN RETURN; END IF;
 s := s||prefix;
 FOR i IN TAB.FIRST..TAB.LAST LOOP
  IF TAB(i).t=tabattr THEN
   j := TO_NUMBER(TAB(i).s);
   s := s||CASE reg WHEN reg_qry THEN qry_attrs(j).COL
     WHEN reg_sel THEN sel_list(j).COL ELSE ph||TAB(i).s||ph END;
  ELSE
   s := s||TAB(i).s;
  END IF;
 END LOOP;
END;
 --------------------------------------------------------------------------------
PROCEDURE ins2tab(el IN OUT NOCOPY longchartab, ai IN OUT NOCOPY PLS_INTEGER,
  func_grp_id FUNC_GRP.ID%TYPE) IS
 li PLS_INTEGER := el.LAST;
BEGIN
 WHILE (li>ai) LOOP
  el(li+2):= el(li);
  li := el.PRIOR(li);
 END LOOP;
 el(ai+2).s := ')'; el(ai+2).t := tabtmp;
 el(ai+1).s := el(ai).s; el(ai+1).t := el(ai).t;
 el(ai).s := func_grp_id||'('; el(ai).t := tabtmp;
 ai := ai+2;
END;
 --------------------------------------------------------------------------------
FUNCTION add_expr_to_qry(i PLS_INTEGER, func_grp_id FUNC_GRP.ID%TYPE :=NULL,
   reg PLS_INTEGER := reg_qry) --1 - qry_attrs ids in tabattr, 2 - sel_list
  RETURN VARCHAR2 IS
 s VARCHAR2(1000);
 el longchartab;
 ii PLS_INTEGER := qry_attrs(i).expr_id;
 j PLS_INTEGER;
 BEGIN
  IF ii IS NOT NULL THEN
   el := exprs_list(ii);
   j := el.FIRST;
   WHILE (j IS NOT NULL) LOOP
    IF el(j).t = tabtmp OR el(j).s IS NULL THEN el.DELETE(j); END IF;
    j := el.NEXT(j);
   END LOOP;
   IF func_grp_id IS NOT NULL THEN
    j := el.FIRST;
    WHILE (j IS NOT NULL) LOOP
     IF el(j).t = tabattr THEN ins2tab(el, j, func_grp_id); END IF;
     j := el.NEXT(j);
    END LOOP;
   END IF;
   add_tab2qry(s, el, '', reg);
  END IF;
  RETURN s;
 END;
 --------------------------------------------------------------------------------
PROCEDURE add_to_qry(i PLS_INTEGER, qry IN OUT NOCOPY VARCHAR2, from_ IN OUT NOCOPY
  VARCHAR2) IS
 col_loc VARCHAR2(1000) := qry_attrs(i).COL;
 tabname VARCHAR2(30);
 basic_col_ref VARCHAR2(30);
 attr_col VARCHAR2(30);
 basic_col VARCHAR2(30);
 basic_col_in_sub VARCHAR2(60);
 reason PLS_INTEGER := 0;
 subqry_ attrs2cubes.subqry%type;
-- add_alias boolean := false;
BEGIN --additional column alias can be provided while WHERE formation
 IF is_add_col_empty(qry_attrs(i).COL) THEN
  col_loc := ''; --add_alias := true;
  IF qry_attrs(i).expr_id IS NULL THEN
   IF qry_attrs(i).bid IS NULL OR qry_attrs(i).dim_lev_id IS NULL THEN GOTO afin; END IF;
   reason := 1;
   IF qry_attrs(i).dim_id IS NULL THEN --why it can be????
    SELECT dim_id INTO qry_attrs(i).dim_id FROM DIM_LEVELS WHERE ID=qry_attrs(i).dim_lev_id;
   END IF;
   SELECT TABNAME INTO add_to_qry.tabname
     FROM DIMS WHERE ID=qry_attrs(i).dim_id;
   reason := 2;
   SELECT COL_IN_DIMS INTO attr_col
    FROM DIM_LEVELS WHERE ID=qry_attrs(i).dim_lev_id;
   reason := 3;
   SELECT MAX(COL_IN_DIMS) INTO basic_col_ref
    FROM DIM_LEVELS d, ATTRS a WHERE a.ID=qry_attrs(i).bid AND a.dim_lev_id=d.ID;
   reason := 4;
   SELECT COL INTO basic_col FROM ATTRS2CUBES WHERE
    cube_id=qry_head.cube_ AND attr_id=qry_attrs(i).bid;
   basic_col_in_sub := gen_state.alias||'.'||basic_col;
--   if qry_attrs(i).storage_type in (constants.datetype/*,timetype*/) then
--    reason := 5;
--    if attr_col=MONTH_DIM then col_loc := 'trunc('||basic_col_in_sub||', ''MM'')';
--    elsif attr_col=YEAR_DIM then col_loc := 'trunc('||basic_col_in_sub||', ''YYYY'')';
--    else errors.raise_err(err_no_lev, constants.qry_task, attr_col, qry_attrs(i).dim_lev_id, do_raise=>true);
--    end if;
   col_loc := From_Db_Utils.get_converted(basic_col, qry_attrs(i).dim_lev_id, qry_attrs(i).bid);
   IF col_loc IS NULL THEN
    IF tabname IS NOT NULL AND attr_col IS NOT NULL THEN
--   else--here, probably, optimisation!!!!!!!!!:
 --  instead of selects introduce joins
     col_loc := '(select '||attr_col||' from '||tabname||
       ' where '||basic_col_ref||'='||basic_col_in_sub||')';
     DB_DIFF.SET_LIMIT(col_loc, 1);
    END IF; --here to raise an error when not found
   end if;
--   end if;
   set_addcol(i);
   From_Db_Utils.concatbyunit(col_loc, qry_attrs(i).unit);
  ELSE
   col_loc := add_expr_to_qry(i);
  END IF;
  if rtrim(col_loc) is not null then col_loc := col_loc||' '||qry_attrs(i).COL; end if;
 ELSE
  SELECT max(SUBQRY) INTO subqry_ FROM ATTRS2CUBES WHERE
    cube_id=qry_head.cube_ AND attr_id=qry_attrs(i).id;
  if subqry_ is null then
   col_loc := gen_state.alias||'.'||col_loc;
   From_Db_Utils.concatbyunit(col_loc, qry_attrs(i).unit);
  else --Currently: only 1-level attributes, by ID_MVM=>ID
   col_loc := '('||subqry_||case when instr(upper(subqry_), 'WHERE')=0 then ' WHERE ' else ' AND ' end
    ||'id_mvm='||gen_state.alias||'.id)';
   From_Db_Utils.concatbyunit(col_loc, qry_attrs(i).unit);
   col_loc := col_loc||' '||qry_attrs(i).COL;
  END IF;
 END IF;
-- if add_alias then
-- end if;
<<afin>>
 IF rtrim(col_loc) IS NULL THEN RAISE NO_DATA_FOUND; END IF;
 qry := qry||CRLF||col_loc;
EXCEPTION
WHEN NO_DATA_FOUND THEN
  errors.raise_err(err_no_attr, Constants.qry_task, qry_attrs(i).code, basic_col
  ||',dim_lev='||qry_attrs(i).dim_lev_id||',dim='||qry_attrs(i).dim_id||',bid='
  ||qry_attrs(i).bid||':'||sqlerrm4user);
END;
--------------------------------------------------------------------------------
PROCEDURE set_qry_attr1(attr_id_ ATTRS.ID%TYPE, attrtab IN OUT NOCOPY numtab,
   ordno PLS_INTEGER := maxordno-2, in_cond VARCHAR2 := 'Y') IS
 i PLS_INTEGER;
BEGIN
 IF attr_id_ IS NULL THEN RETURN; END IF;
 qry_attrs.EXTEND;
 i := qry_attrs.LAST;
 SELECT attr_id_, a.parent_id, ordno, in_cond, 0 proc_lvl,
   ac.COL, a.abbr code, a.dim_lev_id,
   (SELECT dim_id FROM DIM_LEVELS WHERE ID=a.dim_lev_id) dim_id,
   a.storage_type, TO_NUMBER(NULL) grp_id, TO_NUMBER(NULL) rng, '' func_grp_id,
   a.expr_id, a.unit, ac.show, a.scode
  INTO qry_attrs(i)
  FROM ATTRS a, ATTRS2CUBES ac
  WHERE attr_id_=a.ID
  AND ac.cube_id(+)=qry_head.cube_ AND
    ac.attr_id(+)=attr_id_;
 attrtab(attr_id_) := qry_attrs.LAST;
EXCEPTION
WHEN NO_DATA_FOUND THEN RAISE_APPLICATION_ERROR(-20100, 'attr '||attr_id_, TRUE);
END;
--------------------------------------------------------------------------------
PROCEDURE add_mandatory_cols(qry IN OUT NOCOPY VARCHAR2, reg PLS_INTEGER := 1) IS
BEGIN --reg=1 - select list, 2 - grouping
 From_Db_Utils.concatlist(qry, ' id1');
 IF reg=1 THEN From_Db_Utils.concatlist(qry, ' stopno stopno_'); END IF;
 IF reg=3 THEN From_Db_Utils.concatlist(qry, ' stopno_'); END IF;
END;
----------------------------------------------------------------------------------
PROCEDURE set_select_all(qry IN OUT NOCOPY VARCHAR2) IS
 addcomma BOOLEAN := FALSE;
 from_ VARCHAR2(4000);
 i PLS_INTEGER := qry_attrs.FIRST;
BEGIN
  qry := 'select ';
  from_ := ' from '||qry_head.TAB||' '||gen_state.alias||int_where;
  WHILE(i IS NOT NULL) LOOP
--   if qry_attrs(i).bid is null or qry_attrs(i).in_cond='Y' then --here, probably, optimisation!!!!!!!!!:
-- Not all derivative attrs can be calculated at this level!!!!!!!!!;
   IF addcomma THEN qry:= qry||','; END IF;
   addcomma := TRUE;
   add_to_qry(i, qry, from_);
   qry_attrs(i).proc_lvl := gen_state.lvl;
--   end if;
   i := qry_attrs.NEXT(i);
  END LOOP;
  add_mandatory_cols(qry, 1);
  qry := qry||crlf||from_;
END;
----------------------------------------------------------------------------------
PROCEDURE add2cond_line(cond_line IN OUT NOCOPY longchartab,
   addstr VARCHAR2, addtype CHAR := NULL) IS
 ii PLS_INTEGER := NVL(cond_line.LAST, 1);
BEGIN
 IF addstr IS NOT NULL THEN
  IF cond_line(ii).s IS NOT NULL THEN ii := ii+1; END IF;
  cond_line(ii).s := addstr;
  IF addtype IS NOT NULL THEN cond_line(ii).t := addtype; END IF;
 END IF;
END;
----------------------------------------------------------------------------------
FUNCTION add_fun2tab(attr_ind PLS_INTEGER, cond_line IN OUT NOCOPY longchartab,
   func_row_id VARCHAR2 := NULL) RETURN PLS_INTEGER IS
 subst_ FUNC_ROW.subst%TYPE;
 i PLS_INTEGER := -1;
 before_ VARCHAR2(300);
 after_ VARCHAR2(300);
BEGIN
 IF FUNC_ROW_ID IS NOT NULL THEN
  SELECT subst INTO subst_ FROM FUNC_ROW WHERE ID=func_row_id;
  IF subst_ IS NOT NULL THEN
   before_ := subst_;
   i := INSTR(subst_, From_Db_Utils.subst_par);
   IF i>0 THEN
    before_ := SUBSTR(subst_, 1, i-1);
    after_ := SUBSTR(subst_, i+LENGTH(From_Db_Utils.subst_par));
   END IF;
  ELSE
   before_ := FUNC_ROW_ID||'(';
   after_ := ')';
  END IF;
 END IF;
 add2cond_line(cond_line, before_);
 add2cond_line(cond_line, attr_ind, tabattr);
 add2cond_line(cond_line, after_);
 RETURN cond_line.LAST;
END;
----------------------------------------------------------------------------------
FUNCTION get_attr_ind(id_ ATTRS.ID%TYPE, grp_id_ GROUPS.ID%TYPE := NULL,
   mandatory BOOLEAN := FALSE, func_grp_id_ FUNC_GRP.ID%TYPE := NULL)
    RETURN PLS_INTEGER IS
 j PLS_INTEGER:= qry_attrs.FIRST;
 jz PLS_INTEGER;
 is_found BOOLEAN;
BEGIN
  WHILE (j IS NOT NULL) LOOP --!!!search for func_grp_id is not 100% correct.
   is_found := qry_attrs(j).ID=id_ AND (grp_id_ IS NULL OR qry_attrs(j).grp_id=grp_id_)
    OR (qry_attrs(j).bid=id_ AND grp_id_ IS NOT NULL AND qry_attrs(j).grp_id=grp_id_)
   ;
   EXIT WHEN is_found AND (func_grp_id_ IS NULL OR qry_attrs(j).func_grp_id=func_grp_id_);
   IF is_found THEN jz:=j; END IF;
   j := qry_attrs.NEXT(j);
  END LOOP;
 IF mandatory AND j IS NULL AND jz IS NULL THEN
    RAISE_APPLICATION_ERROR(Error_Codes.ALGORITHM_ERROR_N,
  'INTERNAL ERROR: no attribute '||id_||' '||
  CASE WHEN grp_id_ IS NOT NULL THEN  'group '||grp_id_||' ' END||
  CASE WHEN func_grp_id_ IS NOT NULL THEN  'func '||func_grp_id_||' ' END||
  'in select list element', TRUE);
 END IF;
 RETURN NVL(j, jz);
END;
----------------------------------------------------------------------------------
FUNCTION get_col_in_qry(id_ ATTRS.ID%TYPE) RETURN VARCHAR2 IS
 j PLS_INTEGER:= get_attr_ind(id_);
BEGIN
 IF j IS NOT NULL THEN
   RETURN qry_attrs(j).COL;
 END IF;
 RETURN NULL;
END;
----------------------------------------------------------------------------------
FUNCTION get_addcol(i PLS_INTEGER, is_date BOOLEAN, dim_lev DIM_LEVELS.ID%TYPE,
   grp_id GROUPS.ID%TYPE := NULL, skip_alias boolean := true)
  RETURN VARCHAR2 IS
 col_ VARCHAR2(256);
 id_ ATTRS.ID%TYPE;
 pid_ ATTRS.parent_id%TYPE;
 last_added PLS_INTEGER;
BEGIN --can, probably, be expanded to all denormalized or indexed fields
--dbms_crystal_log.log_messageex('OPAL',i||':'||dim_lev||':'||grp_id);
FOR no_of_runs IN 1..2 LOOP --rerun, if date group is not connected with DB field
 col_ := NULL;
 last_added := NULL;
 IF dim_lev=qry_attrs(i).dim_lev_id AND NOT is_date THEN
  col_ := qry_attrs(i).COL;
 ELSE
  IF id_ IS NULL AND dim_lev IS NOT NULL THEN --second run for dim groups with already known id
   SELECT ID, parent_id INTO id_, pid_ FROM ATTRS WHERE
    (dim_lev_id=dim_lev OR attr_type=dim_lev AND dim_lev_id IS NULL/* or storage_type=constants.timetype*/) AND qry_attrs(i).ID IN (ID, parent_id);
  END IF;
  col_ := get_col_in_qry(id_);
--PKG_OPAL_LOG.LOG_MESSAGE (no_of_runs||'-'||i||':'||id_||case when is_date then ' date' end||' is '||col_);
 END IF;
 IF col_ IS NULL THEN
  last_added := extend_qry_attrs(i);
  qry_attrs(last_added).ID := id_;
  qry_attrs(last_added).bid := pid_;
--dbms_crystal_log.log_messageex('OPAL',id_||':'||pid_);
  SELECT MAX(COL) INTO qry_attrs(last_added).COL FROM ATTRS2CUBES WHERE
   attr_id=id_ AND cube_id=qry_head.cube_;
  qry_attrs(last_added).dim_lev_id := dim_lev;
  SELECT max(storage_type) INTO qry_attrs(last_added).storage_type FROM DIM_LEVELS
   WHERE ID=dim_lev;
  set_addcol(last_added);
  qry_attrs(last_added).grp_id := grp_id;
  col_ := qry_attrs(last_added).COL;
--dbms_crystal_log.log_messageex('OPAL',col_);
 END IF;
 IF is_date AND is_add_col_empty(col_) and skip_alias THEN
  IF last_added IS NOT NULL THEN
   qry_attrs.DELETE(last_added);
  END IF;
  SELECT NVL(parent_id, ID) INTO id_ FROM ATTRS WHERE ID=qry_attrs(i).ID;
  pid_ := NULL;
 ELSE
  EXIT;
 END IF;
END LOOP;
IF col_ IS NULL THEN
 errors.raise_err(err_no_db, Constants.qry_task, qry_attrs(i).code, do_raise =>TRUE);
END IF;
RETURN col_;
END;
----------------------------------------------------------------------------------
function get_grp_time_col return varchar2 is
 col_ varchar2(255);
begin
 for j in 1..qry_attrs.count loop
 if qry_attrs.exists(j) then
  if qry_attrs(j).id=grp_time_attr and qry_attrs(j).dim_lev_id is not null then
--app_log.log_messageex('GRP', j||':'||grp_time_attr);
   col_ := get_addcol(j, false, /*grp_time_dim_lev*/ qry_attrs(j).dim_lev_id, skip_alias=>false);
   exit;
  end if;
  end if;
 end loop;
 return col_;
end;
----------------------------------------------------------------------------------
procedure add_grp_time2member(date_from date, date_to date, ss in out varchar2) is
begin
 if date_from is not null then
  ss := ss||' and '||get_grp_time_col||'>='||Db_Diff.get_date(date_from);
 end if;
 if date_to is not null then
  ss := ss||' and '||get_grp_time_col||'<='||Db_Diff.get_date(date_to);
 end if;
end;
----------------------------------------------------------------------------------
FUNCTION set_filter_group(i PLS_INTEGER, op_sign LEAFS4CONDS.op_sign%TYPE,
   grp_id LEAFS4CONDS.grp_id%TYPE, leafs_only IN OUT BOOLEAN) RETURN VARCHAR2 IS
 s VARCHAR2(32000);
 s1 VARCHAR2(32000);
 s2 VARCHAR2(32000);
 ss VARCHAR2(256);
 col_ VARCHAR2(256);
 col__ VARCHAR2(256);
 is_date CONSTANT BOOLEAN := is_dim_date(qry_attrs(i).dim_id, qry_attrs(i).storage_type);
 is_real_date BOOLEAN;
 fnc FUNC_ROW.subst%TYPE;
 parsed_group groups_fnc.parsed_group_type;
 dim_id_ dim_levels.dim_id%type;
 dim_lev_id_ dim_levels.id%type;
 dim_lev_code_ grp_d.dim_lev_code%type;
 storage_type_ DIM_LEVELS.STORAGE_TYPE%type;
 is_allgrp BOOLEAN := FALSE;
 skip_loop boolean := false;
 ins_tmp pls_integer;
 dim_is_date boolean;
 is_fnc boolean;
 is_col_replaced boolean;
 is_grp_time boolean;
 ns1 pls_integer;
 ns2 pls_integer;
 dos2 boolean;
BEGIN
 Groups_Fnc.check_group(grp_id, Tree_Fnc.dim_group);
 check_grp_time( grp_id);
 GROUPS_FNC.PARSE_GROUP(grp_id, parsed_group);
 leafs_only := parsed_group.leafs_only;
 FOR g IN 1..parsed_group.struct.count LOOP
  dim_lev_id_ := parsed_group.struct(g).dim_lev_id;
  dim_id_ := parsed_group.struct(g).dim_id;
  is_col_replaced := false;
--  exit when dim_lev_id_ IS NULL;
  IF dim_lev_id_ IS NULL THEN
   is_allgrp := TRUE;
   continue;
  END IF;
  select storage_type into storage_type_
    from dim_levels where id=dim_lev_id_;
  dim_is_date := is_dim_date(dim_id_, storage_type_);
  is_fnc := (From_Db_Utils.get_converted(' ', dim_lev_id_, NVL(qry_attrs(i).bid, qry_attrs(i).ID)) is not null);
  IF g>1 THEN
   s := s||') OR ';
  END IF;
  col_ := get_addcol(i, is_date, dim_lev_id_, skip_alias=>true); --this procedure writes to qry_attrs, historically!!!
  col__ := get_addcol(i, is_date, dim_lev_id_, skip_alias=>false);
  if col_<>col__ and not dim_is_date then
   is_col_replaced := true;
   col_ := col__;
  end if;
  s1 := ''; s2 := ''; ns1 := 0; ns2 := 0;
  skip_loop := false;
  if parsed_group.struct(g).members.count>300 and not (dim_is_date or is_fnc)then
   if dim_is_date or is_fnc then
    raise_application_error(-20103, 'Big groups of this type are not supported', true);
   end if;
   skip_loop := true;
  end if;
  if skip_loop then
   select count(*) into ins_tmp from TMP_GROUPS
    where qry_id=qry_head.id  and grp_id=set_filter_group.grp_id
     and dim_lev_id=dim_lev_id_ and rownum=1;
   s1 := s1||'select val from tmp_groups where qry_id='||qry_head.id||
     ' and grp_id='||grp_id||' and dim_lev_id='||dim_lev_id_;
  end if;
  FOR h IN 1..parsed_group.struct(g).members.count LOOP
   dim_lev_code_ := parsed_group.struct(g).members(h).code;
   is_grp_time :=  nvl(parsed_group.struct(g).members(h).date_from, parsed_group.struct(g).members(h).date_to) is not null;
   dos2 := (is_grp_time and not is_date);
   if dos2 then ns2 := ns2+1; else ns1 := ns1+1; end if;
   if skip_loop then
    if is_grp_time and substr(s1, -1)<>')' then
     s1 := s1||' and ('||get_grp_time_col||' between date_from and date_to)';  ---!!!!!!!!!!!!!!get_grp_time_col is false!!!
    end if;
    if ins_tmp=0 then
     insert /*+append*/ into tmp_groups(QRY_ID, GRP_ID, DIM_LEV_ID, VAL, date_from, date_to)
      values(qry_head.id, set_filter_group.grp_id, dim_lev_id_, dim_lev_code_,
       nvl(parsed_group.struct(g).members(h).date_from, constants.creationsday), nvl(parsed_group.struct(g).members(h).date_to, constants.doomsday));
    end if;
   else
    IF ns1>1 and not dos2 THEN s1:=s1||CASE WHEN is_date THEN ' OR ' ELSE ',' END; END IF;
    IF ns2>1 and dos2 THEN s2:=s2||' OR '; end if;
    IF dim_is_date THEN
     s1 := s1||quote_between(col_, dim_lev_code_, dim_lev_id_);
     if is_grp_time then
      add_grp_time2member(parsed_group.struct(g).members(h).date_from, parsed_group.struct(g).members(h).date_to, s1);
     end if;
    ELSE
     if is_fnc then --really we must replace attr_id, not col_!!!
      if is_col_replaced then
       fnc := col_;
      else
       fnc := From_Db_Utils.get_converted(col_, dim_lev_id_, NVL(qry_attrs(i).bid, qry_attrs(i).ID));
      end if;
     --IF fnc IS NOT NULL THEN --here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!storage_type to g cursor
      s1 := s1||fnc||' = '||quote_const(storage_type_, dim_lev_code_, dim_lev_id_);
      if is_grp_time then
       add_grp_time2member(parsed_group.struct(g).members(h).date_from, parsed_group.struct(g).members(h).date_to, s1);
      end if;
     ELSE
      ss := quote_const(
       CASE WHEN dim_lev_id_ IS NOT NULL THEN storage_type_
       ELSE qry_attrs(i).storage_type  END,
       dim_lev_code_, dim_lev_id_);
      if dos2 then
       s2 := s2||col_||'='||ss;
       add_grp_time2member(parsed_group.struct(g).members(h).date_from, parsed_group.struct(g).members(h).date_to, s2);
      else
       s1 := s1||ss;
      end if;
     END IF;
    END IF;
   END IF;
  END LOOP;
  IF is_date THEN --!!!invalid, it must be if the type demands conversion
   s := s||'('||s1;
  ELSE
   if length(s1)>0 then
    s := s||col_||' '||Constants.INOP||'('||s1;
    if length(s2)>0 then s := s||') or '; end if;
   end if;
   if length(s2)>0 then
    s := s||'('||s2;
   end if;
  END IF;
 END LOOP;
 IF is_allgrp THEN
   s := '';
 END IF;
 s:=NVL(s, '(1=1');
 s := s||')';
 IF INSTR(op_sign, Constants.NOTOP)>0 THEN
  s := ' '||Constants.NOTOP||s;
 END IF;
 RETURN s;
END;
----------------------------------------------------------------------------------
PROCEDURE set_cont_filter_group(i PLS_INTEGER, grp_id GROUPS.ID%TYPE,
  type_id ATTR_TYPES.ID%TYPE) IS
 col_ VARCHAR2(256);
 is_date CONSTANT BOOLEAN := FALSE; --is_dim_date(qry_attrs(i).dim_id, qry_attrs(i).storage_type);
BEGIN
 Groups_Fnc.check_group(grp_id, Tree_Fnc.cont_group);
 col_ := get_addcol(i, is_date, type_id, grp_id);
END;
----------------------------------------------------------------------------------
FUNCTION set_in_list(i PLS_INTEGER, op_sign LEAFS4CONDS.op_sign%TYPE,
  const VARCHAR2) RETURN VARCHAR2 IS
 s VARCHAR2(32000);
 nb PLS_INTEGER:=1;
 ne PLS_INTEGER;
 co PLS_INTEGER:=1;
 lc CONSTANT PLS_INTEGER := LENGTH(const);
 ld CONSTANT PLS_INTEGER := LENGTH(listdelim);
BEGIN
 s := op_sign||' (';
 LOOP
  ne := INSTR(const, listdelim, 1, co);
  IF ne=0 THEN ne:= lc + 1; END IF;
  IF co<>1 THEN
   s := s||',';
  END IF;
  s := s||quote_const(qry_attrs(i).storage_type, SUBSTR(const, nb, ne-nb), qry_attrs(i).dim_lev_id);
  nb := ne + ld;
  EXIT WHEN nb>lc;
  co := co+1;
 END LOOP;
 s := s||')';
 RETURN s;
END;
----------------------------------------------------------------------------------
PROCEDURE set_cond_leaf(id_ CONDS.ID%TYPE, s IN OUT NOCOPY VARCHAR2,
  attr_id ATTRS.ID%TYPE := NULL, grp_id_ GROUPS.ID%TYPE := NULL) IS
 rl VARCHAR2(255);
 i PLS_INTEGER := qry_attrs.FIRST;
 cond_id_ CONDS.ID%TYPE;
 no_right BOOLEAN; --not 100% true, we suppose that basic cols are before artificial ones
 no_left BOOLEAN;
 grp_type_id_ ATTR_TYPES.ID%TYPE;
 attr_type_id_ ATTR_TYPES.ID%TYPE;
 storage_id_ ATTR_TYPES.ID%TYPE;
 dim_lev_id_ DIMS.ID%TYPE;
 is_like BOOLEAN;
 attr_id_ ATTRS.ID%TYPE := attr_id;
 param GRP_P.param%TYPE;
 leafs_only BOOLEAN;
BEGIN
 s := '';
 IF grp_id_ IS NOT NULL AND attr_id_ IS NOT NULL THEN
  SELECT NVL(MAX(a.ID), attr_id_) INTO attr_id_ FROM ATTRS a, GROUPS g
   WHERE attr_id_ IN (a.ID, parent_id) AND g.ID=grp_id_ AND
   g.type_id=a.attr_type;
 END IF;
 FOR c IN (SELECT
    DECODE(LEFT_ATTR_ID, Groups_Fnc.placeholder, attr_id_, left_attr_id) LEFT_ATTR_ID,
    DECODE(RIGHT_ATTR_ID, Groups_Fnc.placeholder, attr_id_, RIGHT_attr_id) RIGHT_ATTR_ID,
    CONST, GRP_ID, OP_SIGN,
    LEFT_FUNC_GRP_ID, RIGHT_FUNC_GRP_ID, LEFT_FUNC_ROW_ID, RIGHT_FUNC_ROW_ID,
    g.grp_type, g.IS_LEAF
   FROM LEAFS4CONDS, GROUPS g WHERE leaf_id=id_ AND grp_id=g.ID(+)) LOOP
  IF c.op_sign=Constants.ELSOP THEN
   s := Constants.ELSOP;
  ELSE
   s := ' '||c.op_sign||' ';
   no_left := c.left_attr_id IS NOT NULL; no_right := c.right_attr_id IS NOT NULL;
   is_like := (INSTR(c.op_sign, Constants.LIKEOP)>0);
   WHILE (i IS NOT NULL) LOOP
    IF no_left AND qry_attrs(i).ID=c.left_attr_id THEN
    no_left := FALSE;
    IF INSTR(c.op_sign, Constants.INOP)<>0 THEN
     IF c.grp_id IS NOT NULL THEN
      if c.grp_id>999999 then
       c.grp_id := get_ph_group(c.grp_id); c.grp_type := TREE_FNC.DIM_GROUP;
      end if;
      IF c.grp_type = Tree_Fnc.dim_group THEN
       s := set_filter_group(i, c.op_sign, c.grp_id, leafs_only);
      ELSIF c.grp_type = Tree_Fnc.cont_group THEN
       IF c.is_leaf=1 THEN
        SELECT cond_id INTO cond_id_ FROM GRP_C WHERE grp_id=c.grp_id;
        s := REPLACE(s, Constants.INOP, ''); --in the old cond line - IN operation, invalid there
        form_conds(s, cond_id_, '', c.left_attr_id, tree_cond, c.grp_id);
--app_log.log_messageex('CO',  cond_id_||':'||c.grp_id, s);
       ELSE
        s := '';
       END IF;
      END IF;
     ELSE
      s := qry_attrs(i).COL||' '||set_in_list(i, c.op_sign, c.const);
     END IF;
     EXIT;
    END IF;
    storage_id_ := qry_attrs(i).storage_type;
/*  if grp_id_ is not null then
      select nvl(type_id, attr_type) into grp_type_id_
    from groups g, attrs a
    where g.id=grp_id_ and a.id(+)=g.attr_id;
   select attr_type into attr_type_id_
    from attrs where id=c.left_attr_id;
   select FUN_ROW_CONV, storage_type into c.left_func_row_id, storage_id_
    from types_comp where type_id=attr_type_id_ and comp_type_id=grp_type_id_;
  end if;
*/  rl := From_Db_Utils.concat_fun(qry_attrs(i).COL, c.LEFT_FUNC_GRP_ID, c.left_func_row_id);
    s := rl||s; rl := '';
    IF c.const IS NOT NULL THEN
     IF grp_id_ IS NOT NULL THEN
      SELECT NVL(MAX(type_id), qry_attrs(i).dim_lev_id) INTO dim_lev_id_
       FROM GROUPS WHERE ID=grp_id_;
     END IF;
     c.const := quote_const(storage_id_, c.const, dim_lev_id_);
     IF is_like THEN
       rl := From_Db_Utils.escape_like(c.const);
     ELSE
       rl := From_Db_Utils.concat_fun(c.const, c.RIGHT_FUNC_GRP_ID, c.right_func_row_id);
     END IF;
    END IF;
    IF c.grp_id IS NOT NULL AND c.grp_type='P' THEN --!!!??? because of new system of PH processing??? but id does not take place!!
     SELECT g.FUNC_ID, g.param INTO c.right_func_row_id, param --it must be possibility for int groups wirth PH write = condition, not < or >
       FROM GRP_P g WHERE g.grp_id=c.grp_id;
        rl := From_Db_Utils.concat_fun(param, '', c.right_func_row_id);
    END IF;
    s := s||rl;
   END IF;
   IF no_right AND qry_attrs(i).ID=c.right_attr_id THEN
    no_right := FALSE;
    rl := From_Db_Utils.concat_fun(qry_attrs(i).COL, c.RIGHT_FUNC_GRP_ID, c.right_func_row_id);
    s := s||rl;
   END IF;
   EXIT WHEN NOT no_left AND NOT no_right;
   i := qry_attrs.NEXT(i);
   END LOOP;
  END IF;
 END LOOP;
 IF s IS NOT NULL THEN s := s||crlf; END IF;
END;
----------------------------------------------------------------------------------
PROCEDURE set_expr_leaf(id_ CONDS.ID%TYPE, s IN OUT longchartab,
  attr_id_ ATTRS.ID%TYPE) IS --here attr_id is the id of the source attr
 rl VARCHAR2(255);
 i PLS_INTEGER := qry_attrs.FIRST;
 storage_type_ ATTRS.storage_type%TYPE;
 ii PLS_INTEGER := s.LAST;
 dim_lev_id_ DIMS.ID%TYPE;
BEGIN
 s(ii).s := '';
 FOR c IN (SELECT UN_SIGN, CONST, ATTR_ID, FUNC_ROW_ID
   FROM LEAFS4EXPRS WHERE leaf_id=id_) LOOP
  IF c.un_sign IS NOT NULL THEN s(ii).s := c.un_sign; END IF;
  IF c.const IS NOT NULL THEN --!!!!one more restriction for formulas
   SELECT storage_type, dim_lev_id INTO storage_type_, dim_lev_id_
    FROM ATTRS WHERE ID=attr_id_;
   c.const := quote_const(storage_type_, c.const, dim_lev_id_);
   rl := From_Db_Utils.concat_fun(c.const, NULL, c.func_row_id);
   s(ii).s := s(ii).s||rl;
  ELSE
   WHILE (i IS NOT NULL) LOOP
    IF qry_attrs(i).ID=c.attr_id THEN
  ii := add_fun2tab(i, s, c.func_row_id);
  EXIT;
    END IF;
    i := qry_attrs.NEXT(i);
   END LOOP;
  END IF;
 END LOOP;
END;
----------------------------------------------------------------------------------
PROCEDURE form_conds(qry IN OUT NOCOPY VARCHAR2, cond_id_ CONDS.ID%TYPE,
  prefix VARCHAR2 := '', attr_id ATTRS.ID%TYPE := NULL,
  tree_kind PLS_INTEGER := tree_cond, grp_id_ GROUPS.ID%TYPE := NULL) IS
 cond_line longchartab;
 level_op chartab;
 curr_lev PLS_INTEGER := -1;
 conds_ condrows;
 prev_lev PLS_INTEGER;
 ii PLS_INTEGER;
 empty_cond VARCHAR2(30);
 PROCEDURE closebr(ii PLS_INTEGER) IS
 BEGIN
  cond_line(ii).s := ')';
  cond_line(ii).t := tabclosebr;
 END;
BEGIN
 IF tree_kind=tree_cond THEN --conditions tree
  SELECT ID, parent_id, op_sign, is_leaf, LEVEL lvl
   BULK COLLECT INTO conds_
   FROM CONDS
   START WITH ID=cond_id_
   CONNECT BY parent_id=PRIOR ID
   ORDER SIBLINGS BY ordno;
 ELSIF tree_kind=tree_expr THEN --expressions tree
   SELECT ID, parent_id, op_sign, is_leaf, LEVEL lvl
    BULK COLLECT INTO conds_
    FROM EXPRS
    START WITH ID=cond_id_
    CONNECT BY parent_id=PRIOR ID
    ORDER SIBLINGS BY ordno;
 END IF;
 IF conds_.FIRST IS NULL THEN RETURN; END IF;
 conds_.EXTEND;
 conds_(conds_.LAST).lvl := 1; --fictitious point
 FOR c IN conds_.FIRST..conds_.LAST LOOP
  IF conds_(c).lvl<=curr_lev THEN
   IF cond_line.LAST IS NOT NULL THEN
    ii := cond_line.PRIOR(cond_line.LAST);
    IF ii IS NOT NULL AND cond_line(ii).s IS NULL THEN
     empty_cond := '1=1';
     IF level_op.EXISTS(conds_(c).lvl-1) THEN
   IF INSTR(level_op(conds_(c).lvl-1), Constants.OROP) > 0 THEN
    empty_cond := '1=0';
   END IF;
  END IF;
     cond_line(ii).s := empty_cond;
 END IF;
    closebr(cond_line.LAST);
   END IF;
   FOR i IN REVERSE conds_(c).lvl+1..level_op.LAST LOOP
    closebr(cond_line.LAST+1);
    level_op.DELETE(i);
   END LOOP;
   IF conds_(c).lvl>1 THEN
    ii := cond_line.LAST+1;
    cond_line(ii).s := level_op(conds_(c).lvl-1);
    cond_line(ii).t := taboper;
   END IF;
  END IF;
  level_op(conds_(c).lvl) := RTRIM(REPLACE(conds_(c).op_sign, Constants.NOTOP, ''));
  IF conds_(c).ID IS NOT NULL THEN
   IF INSTR(conds_(c).op_sign, Constants.NOTOP) <>0 THEN
    cond_line(NVL(cond_line.LAST, 0)+1).s := ' '||Constants.NOTOP;
   END IF;
   ii := NVL(cond_line.LAST, 0)+1;
   cond_line(ii).s := '(';
   cond_line(ii).t := tabopenbr;
  END IF;
  curr_lev := conds_(c).lvl;
  IF conds_(c).is_leaf=1 THEN
   cond_line(NVL(cond_line.LAST, 0)+1).s := '';
   IF tree_kind=tree_cond THEN
    set_cond_leaf(conds_(c).ID, cond_line(cond_line.LAST).s, attr_id, grp_id_);
   ELSIF tree_kind=tree_expr THEN
    set_expr_leaf(conds_(c).ID, cond_line, attr_id);
   END IF;
   prev_lev := conds_(c).lvl-1;
   ii := cond_line.LAST+1;
   IF level_op.EXISTS(prev_lev) THEN
    cond_line(ii).s := level_op(prev_lev);
    cond_line(ii).t := taboper;
   ELSE
    cond_line(ii).s := '';
   END IF;
  END IF;
 END LOOP;
 IF tree_kind=tree_cond THEN
  add_tab2qry(qry, cond_line, prefix);
 ELSIF tree_kind=tree_expr THEN
  exprs_list(cond_id_) := cond_line;
 END IF;
END;
----------------------------------------------------------------------------------
PROCEDURE add_exprs(qry_ IN OUT NOCOPY VARCHAR2) IS
 i PLS_INTEGER := qry_attrs.FIRST;
 mult NUMBER;
 expr_ PLS_INTEGER;
 ii PLS_INTEGER;
BEGIN
 WHILE i IS NOT NULL LOOP
  expr_ := qry_attrs(i).expr_id;
  IF expr_ IS NOT NULL THEN
   form_conds(qry_, expr_, '', qry_attrs(i).ID, tree_expr);
   mult := From_Db_Utils.get_mult4unit(qry_attrs(i).unit);
   IF  NVL(mult, 1)<>1 THEN
    ii := exprs_list(expr_).LAST+1;
    exprs_list(expr_)(ii).s := '*'; --expression is already in brackets
    exprs_list(expr_)(ii).t := taboper;
    exprs_list(expr_)(ii+1).s := mult;
   END IF;
   set_addcol(i);
  END IF;
  i := qry_attrs.NEXT(i);
 END LOOP;
END;
----------------------------------------------------------------------------------
PROCEDURE set_where(qry IN OUT NOCOPY VARCHAR2) IS
BEGIN
 form_conds(qry, qry_head.where_, crlf||' where ', NULL, tree_cond);
END;
----------------------------------------------------------------------------------
procedure store_grp_headers(attr_id_ qrys_sel.attr_id%type, grp_id_ qrys_sel.grp_id%type, how_ qrys_sel.how%type,
 code IN OUT NOCOPY VARCHAR2, ordno PLS_INTEGER, grp_id4val_ groups.id%type) is
begin
 Groups_Fnc.prefix_group_code(code, ordno);
 if bitand(how_, constants.how_null_flag)>0 then --!!!nulls
  insert into qry_grp_headers(QRY_ID, ATTR_ID, GRP_ID, VAL, GRP_ID4VAL)
   values(qry_head.id, attr_id_, grp_id_, code, grp_id4val_);
 end if;
end;
----------------------------------------------------------------------------------
PROCEDURE add_groups_c(cond_str IN OUT NOCOPY VARCHAR2,  grp_id_ GROUPS.ID%TYPE,
  attr_id ATTRS.ID%TYPE, how_ qrys_sel.how%type) IS
 leaf VARCHAR2(4000);
 j PLS_INTEGER;
 longcode VARCHAR2(50);
BEGIN
 cond_str := cond_str||crlf||'case ';
 FOR l IN (SELECT g.grp_id, co.ID cond_id, gt.ordno_in_root ordno
           FROM CONDS co, GRP_C g, GRP_TREE gt WHERE
            co.ID=g.cond_id AND g.grp_id=gt.ID AND gt.parent_id= grp_id_
        ORDER BY co.ordno) LOOP
  leaf := '';
  if l.grp_id>999999 then
   l.grp_id := get_ph_group(l.grp_id);
  end if;
  form_conds(leaf, l.cond_id, '', attr_id, tree_cond, l.grp_id);
  IF leaf<>Constants.ELSOP THEN
   cond_str:= cond_str||' when '||leaf||' then';
  ELSE
   cond_str := cond_str||leaf;
  END IF; --!!!!!!!!!!!here add storage type to l cursor, probably??? Or it is always char?
  longcode := Groups_Fnc.get_grp_name(l.grp_id);
  Groups_Fnc.prefix_group_code(longcode, l.ordno);
  cond_str := cond_str||' '||quote_const(Constants.chartype, longcode)||crlf;
 END LOOP;
 cond_str:=cond_str||'end';
 j := extend_qry_attrs(get_attr_ind(attr_id));
 set_addcol(j);
 qry_attrs(j).grp_id := grp_id_;
 cond_str := cond_str||' '||qry_attrs(j).COL;
END;
----------------------------------------------------------------------------------
function prepare_case4group(grp_id_ GROUPS.ID%TYPE, is_real_group pls_integer, how_ qrys_sel.how%type,
  old_grp_ord IN OUT NOCOPY groups_fnc.nums) return tree_nodes is
 grps groups_fnc.parsed_group_types;
 grp1 groups_fnc.parsed_group_type;
 grp1_ext groups_fnc.parsed_group_type;
 grp_ord tree_nodes;
 new_grp_ord groups_fnc.nums;
 nleafs pls_integer := 0;
 nnodes pls_integer := 32766;
 curr_grp groups.id%type;
 all_grp_ordno constant pls_integer := 99999;
 ngrps pls_integer := 0;
 grp2ord grp_members := grp_members();
 nn pls_integer;
begin
 select /*+use_concat*/
   tree_node(id, parent_id, ordno_in_root, allrest, date_from, date_to)
  bulk collect into grp_ord
  from grp_tree
  where parent_id=grp_id_ and is_real_group>1 or
    id=grp_id_ and is_real_group<=1 order by ordno_in_root;
 for i in 1..grp_ord.count loop
  curr_grp := grp_ord(i).id;
  old_grp_ord(curr_grp) := grp_ord(i).ordno;
  if bitand(how_, constants.how_rest_flag)>0 and grp_ord.count>0 then
   GROUPS_FNC.PARSE_GROUP(curr_grp, grp1);
   --here index 1 always exists, a check must be above
   if grp1.struct(1).dim_lev_id is null then --"All" group
    new_grp_ord(curr_grp) := all_grp_ordno;
   elsif grp1.leafs_only then
--    if grp1.struct.last=1 then
--     if grp1.struct(1).members.count=1 then
      nleafs := nleafs+1;
      new_grp_ord(curr_grp) := nleafs;
--     end if;
 --   end if;
   end if;
   if not new_grp_ord.exists(curr_grp) then
    GROUPS_FNC.GET_PARSE_GROUP_EXT(grp1, grp1_ext);
    grps(nvl(grps.last, 0) + 1) := grp1_ext; --this for further usage
    grp2ord.extend;
    nn := grp2ord.last;
    grp2ord(nn) := grp_member(curr_grp, ' ', null, null);
    for j in 1..grp1_ext.struct.count loop
     grp2ord(nn).code := grp2ord(nn).code||ltrim(to_char(grp1_ext.struct(j).ordno, '00'))||
      ltrim(to_char(grp1_ext.struct(j).members.count, '0000')/*||'/'*/);
     end loop;
    grp2ord(nn).code := grp2ord(nn).code||'A';
   end if;
  end if;
 end loop;
 if grp2ord.count>0 then
  for i in (select id, code from table(grp2ord) t order by nlssort(t.code, 'NLS_SORT=BINARY')) loop
   nnodes := nnodes + 1;
   new_grp_ord(i.id) := nnodes;
  end loop;
 end if;
 for i in 1..grp_ord.count loop
  if new_grp_ord.exists(grp_ord(i).id) then
   grp_ord(i).ordno := new_grp_ord(grp_ord(i).id);
  end if;
 end loop;
 return grp_ord;
end;
----------------------------------------------------------------------------------
PROCEDURE make_case4group(cond_str IN OUT NOCOPY VARCHAR2, attr_id ATTRS.ID%TYPE,
   grp_id_ GROUPS.ID%TYPE, code VARCHAR2, grp_type GROUPS.grp_type%TYPE, is_real_group pls_integer,
    how_ qrys_sel.how%type) IS
 cond_id_ CONDS.ID%TYPE;
 s VARCHAR2(32000);
 cd varchar2(50);
 leafs_only BOOLEAN;
 cond_strs longchartab;
 cond_vals longchartab;
 nn pls_integer := 0;
 old_grp_ord groups_fnc.nums;
 grp_ord tree_nodes := prepare_case4group(grp_id_, is_real_group, how_, old_grp_ord);
BEGIN
 cond_str := cond_str||crlf||'(select case ';
 for i in (select t.id, t.ordno, t.ordno ordno_org
    from table(grp_ord) t order by t.ordno) loop
  nn := nn+1;
  leafs_only := false;
  i.ordno := old_grp_ord(i.id);
  IF grp_type=Tree_Fnc.cont_group THEN
   SELECT cond_id INTO cond_id_ FROM GRP_C WHERE grp_id=i.id;
 --  set_cond_leaf(cond_id_, s, attr_id);
   s := '';
   form_conds(s, cond_id_, '', attr_id, tree_cond);
  ELSE
   s := set_filter_group(get_attr_ind(attr_id), Constants.INOP, i.id, leafs_only);
--raise_application_error(-20111, get_attr_ind(attr_id)||' of '||attr_id||' for '||i.id||':'||s);
  END IF;
  if is_real_group=0 or is_real_group=1 then
   cd := code;
  else
   if i.id>-100 then
    select g.abbr into cd from groups g where id=i.id;
   else
    select dim_lev_code into cd from grp_d g where grp_id=i.id;
   end if;
   if bitand(how_, constants.how_rest_flag)>0 then
    if nn=grp_ord.count then
     cd := 'Rest '||cd;
    end if;
   end if;
   store_grp_headers(attr_id, grp_id_, how_, cd, i.ordno, i.id);
  -- Groups_Fnc.prefix_group_code(cd, i.ordno);
  end if;
  cond_strs(nn).s := s; --!!!!!!!!!!!!!!see if here something except chartype
  cond_strs(nn).t := case when leafs_only then '1' end;
--  cond_str:= cond_str||' when '||s||' then'; --!!!!!!!!!!!!!!see if here something except chartype
  cond_vals(nn).s := ' '||quote_const(Constants.chartype, cd)||crlf;
--  cond_str := cond_str||' '||quote_const(Constants.chartype, cd)||crlf;
  exit when is_real_group<=1;
 end loop;
 for j in 1..cond_strs.count loop
  cond_str := cond_str||' when ';
/*  if bitand(how_, constants.how_rest_flag)>0 and cond_strs(j).t is null and cond_strs.count>1 then
   for jj in 1..cond_strs.count loop
    if jj<>1 then cond_str := cond_str||' and '; end if;
    cond_str := cond_str||case when j<>jj then constants.notop end||'('||cond_strs(jj).s||')'||crlf;
   end loop;
  else*/
   cond_str := cond_str||cond_strs(j).s;
  --end if;
  cond_str := cond_str||' then';
  cond_str := cond_str||cond_vals(j).s;
 end loop;
 cond_str:=cond_str||'end txt '||db_diff.get_dual||')';
END;
----------------------------------------------------------------------------------
PROCEDURE  put_alias2group(cond_str IN OUT NOCOPY VARCHAR2, attr_id ATTRS.ID%TYPE,
   grp_id GROUPS.ID%TYPE, alias VARCHAR2:=add_col_alias) IS
 j PLS_INTEGER := extend_qry_attrs(get_attr_ind(attr_id));
BEGIN
 set_addcol(j, alias);
 qry_attrs(j).grp_id := grp_id;
 cond_str := cond_str||' '||qry_attrs(j).COL;
END;
----------------------------------------------------------------------------------
FUNCTION get_is_real_group(grp_id_ GROUPS.ID%TYPE) RETURN PLS_INTEGER IS
 is_real_group PLS_INTEGER;
 nmbr numtab;
 is_dbl boolean := false;
 tp groups.type_id%type;
 pd groups.predefined%type;
BEGIN
  select predefined into pd from groups where id=grp_id_;
  SELECT --+index(gt i_grp_tree_p) index(g p_groups)
     NVL(MAX(1), 0), max(type_id) INTO is_real_group, tp
    FROM GRP_TREE gt, GROUPS g
    WHERE parent_id=grp_id_ AND g.ID=gt.ID AND ROWNUM=1 AND
    (grp_type<>Tree_Fnc.dim_group OR NVL(is_leaf, 0)<>1);
  if is_real_group=1 then --if the group is non-overlapping
   for i in (select id from grp_tree where parent_id=grp_id_) loop --till the moment the simplest case
    for ii in (select /*+index(g)*/g.id, g.grp_type, g.is_leaf, g.type_id
      from grp_tree gt, groups g where gt.parent_id=i.id and gt.id=g.id) loop
     if ii.grp_type<>Tree_Fnc.dim_group OR NVL(ii.is_leaf, 0)<>1 then
      is_dbl := true;
      exit;
     end if;
     if ii.type_id<>tp or ii.type_id is null then
      is_dbl := true;
      exit;
     end if;
     if nmbr.exists(ii.id) then
      if nmbr(ii.id)<>i.id then
       is_dbl := true;
       exit;
      end if;
     end if;
     nmbr(ii.id) := i.id;
    end loop;
   end loop;
   is_real_group := case when is_dbl then 1 else 2 end;
  end if;
  if is_real_group=0 and pd=tree_fnc.is_temporary then --temporary group - always a complex one.
   is_real_group := 2;
  end if;
  RETURN is_real_group;
END;
----------------------------------------------------------------------------------
function get_is_real_group_how(grp_id_ GROUPS.ID%TYPE, how_ qrys_sel.how%type) return pls_integer is
 is_real_group  PLS_INTEGER  := get_is_real_group(grp_id_);
begin
  if bitand(how_, constants.how_rest_flag)>0 then is_real_group := 2;
  elsif bitand(how_, constants.how_null_flag)>0  then is_real_group := 1;
  end if; --!!!rest
  return is_real_group;
end;
----------------------------------------------------------------------------------
PROCEDURE add_groups_d(cond_str IN OUT NOCOPY VARCHAR2, grp_id_ GROUPS.ID%TYPE,
  attr_id ATTRS.ID%TYPE, grp_lev_ordno QRYS_SEL.grp_lev_ordno%TYPE, code VARCHAR2,
  grp_type GROUPS.grp_type%TYPE, how_ qrys_sel.how%type, is_real_group  PLS_INTEGER) IS
 notfrstsub BOOLEAN;
 longcode VARCHAR2(50);
 how_loc qrys_sel.how%type := how_;
BEGIN
--  if bitand(how_, constants.how_null_flag)>0 and is_real_group=0 then is_real_group := 2; end if; --!!!null
  IF is_real_group <> 1 THEN
   make_case4group(cond_str, attr_id, grp_id_, code, grp_type, is_real_group, how_);
   put_alias2group(cond_str, attr_id, grp_id_, add_col_alias);
  END IF;
--dbms_crystal_log.log_messageex('OPAL', grp_id_||':'||is_real_group, cond_str);
END;
----------------------------------------------------------------------------------
PROCEDURE add_groups_nested(cond_str IN OUT NOCOPY VARCHAR2, grp_id_ GROUPS.ID%TYPE,
  attr_id ATTRS.ID%TYPE, grp_type GROUPS.grp_type%TYPE, how_ qrys_sel.how%type, is_real_group PLS_INTEGER) IS
 notfrstsub BOOLEAN;
 longcode VARCHAR2(50);
 how_loc qrys_sel.how%type := how_;
BEGIN
--  if bitand(how_, constants.how_null_flag)>0 and is_real_group=0 then is_real_group := 2; end if; --!!!null
  IF is_real_group = 1 THEN
   if how_loc>=constants.how_rest_flag then how_loc := how_loc - constants.how_rest_flag; end if;
   cond_str := cond_str||crlf||DB_DIFF.GET_LATERAL||' (select txt from(';
   notfrstsub := FALSE;
   FOR l IN (SELECT --+index(t) index(g)
               t.ID grp_id, g.abbr code, t.ordno_in_root ordno
              FROM GRP_TREE t, GROUPS g WHERE
           parent_id=grp_id_ AND t.ID=g.ID ORDER BY t.ordno_in_root) LOOP
    IF notfrstsub THEN
     cond_str:= cond_str||' union ';
    END IF;
    longcode := l.code;
    notfrstsub := TRUE;
    store_grp_headers(attr_id, grp_id_, how_, longcode, l.ordno, l.grp_id);
    --Groups_Fnc.prefix_group_code(longcode, l.ordno);
    make_case4group(cond_str, attr_id, l.grp_id, longcode, grp_type, is_real_group, how_loc);
   END LOOP;
   cond_str := cond_str||') nc where txt is not null)'; --alias nc is necessary in mysql
   put_alias2group(cond_str, attr_id, grp_id_, nested_col_alias);
   cond_str := cond_str||' '||db_diff.get_on;
  END IF;
--dbms_crystal_log.log_messageex('OPAL', grp_id_||':'||is_real_group, cond_str);
END;
----------------------------------------------------------------------------------
PROCEDURE add_groups(cond_str IN OUT NOCOPY VARCHAR2,
  for_int_type PLS_INTEGER, nested_str in out nocopy varchar2) IS
 notfrst BOOLEAN := FALSE;
 int_type PLS_INTEGER;
BEGIN
  FOR c IN (SELECT q.attr_id, q.grp_id, q.grp_lev_ordno, g.abbr code,
            g.grp_type, g.grp_subtype, g.type_id, q.how,
            get_is_real_group_how(q.grp_id, q.how) is_real_group
             FROM QRYS_SEL q, GROUPS g
             WHERE q.qry_id=qry_head.ID AND g.ID=q.grp_id) LOOP
   if c.grp_id>999999 then
    c.grp_id := get_ph_group(c.grp_id); c.grp_type := TREE_FNC.DIM_GROUP;
   end if;
   Groups_Fnc.check_group(c.grp_id, c.grp_type);
   IF c.grp_type=Tree_Fnc.dim_group THEN
    int_type := int_type_mult;
   ELSIF c.grp_type=Tree_Fnc.cont_group THEN
    int_type := Groups_Fnc.get_int_type(c.grp_subtype);
    SELECT NVL(MAX(ID), c.attr_id) INTO c.attr_id FROM ATTRS WHERE
     parent_id=c.attr_id AND attr_type=c.type_id;
   END IF;
   IF for_int_type IS NULL OR for_int_type=int_type THEN
    IF int_type=int_type_single THEN
     IF notfrst THEN cond_str:= cond_str||','; END IF;
     add_groups_c(cond_str, c.grp_id, c.attr_id, c.how);
    ELSIF c.is_real_group<>1 then
     IF notfrst THEN cond_str:= cond_str||','; END IF;
     add_groups_d(cond_str, c.grp_id, c.attr_id, c.grp_lev_ordno, c.code, c.GRP_TYPE, c.how, c.is_real_group);
    else
     add_groups_nested(nested_str, c.grp_id, c.attr_id, c.GRP_TYPE, c.how, c.is_real_group);
    END IF;
    notfrst := TRUE;
   END IF;
  END LOOP;
END;
----------------------------------------------------------------------------------
PROCEDURE add_atrrs4dimgroups IS
 s VARCHAR2(16000);
 leafs_only BOOLEAN;
BEGIN
  FOR c IN (SELECT q.attr_id, q.grp_id
             FROM QRYS_SEL q, GROUPS g
             WHERE q.qry_id=qry_head.ID AND g.ID=q.grp_id
    AND g.grp_type in (Tree_Fnc.dim_group, Tree_Fnc.ph_group)) LOOP
      if c.grp_id>999999 then
       c.grp_id := get_ph_group(c.grp_id);
      end if;
    s := set_filter_group(get_attr_ind(c.attr_id), Constants.INOP, c.grp_id, leafs_only);
  END LOOP;
END;
----------------------------------------------------------------------------------
PROCEDURE add_atrrs4contgroups IS
BEGIN
  FOR c IN (SELECT q.attr_id, q.grp_id, g.type_id, a.attr_type
             FROM QRYS_SEL q, GROUPS g, ATTRS a
             WHERE q.qry_id=qry_head.ID AND g.ID=q.grp_id AND a.ID=q.attr_id
             AND g.type_id<>a.attr_type
    AND g.grp_type=Tree_Fnc.cont_group) LOOP
   set_cont_filter_group(get_attr_ind(c.attr_id), NULL/*c.grp_id*/, c.type_id);
  END LOOP;
  FOR c IN (SELECT NVL(a.parent_id, a.ID) attr_id, a.attr_type type_id
             FROM (SELECT ID FROM CONDS CONNECT BY PRIOR ID=parent_id
             START WITH ID=qry_head.where_
            ) c, LEAFS4CONDS l, GROUPS g, ATTRS a
           WHERE l.leaf_id=c.ID AND g.ID=l.grp_id AND g.grp_type='C'
            AND a.attr_type=g.type_id AND  left_attr_id IN (a.ID, a.PARENT_ID))LOOP
   set_cont_filter_group(get_attr_ind(c.attr_id), NULL, c.type_id);
  END LOOP;
END;
------------------------------------------------------------------------------
 PROCEDURE add_where_groups(qry IN OUT NOCOPY VARCHAR2, where_str VARCHAR2) IS
  grp_str VARCHAR2(32000);
  nested_str VARCHAR2(32000);
 BEGIN
--dimensional groups we'll add later, they don't allow multilevel grouping
  add_groups(grp_str, int_type_single, nested_str);
  IF where_str IS NULL AND grp_str IS NULL THEN RETURN; END IF;
  IF grp_str IS NOT NULL THEN grp_str:=','||grp_str; END IF;
  form_qry(qry, gen_state.alias||'.*'||grp_str, gen_state.alias||where_str);
 END;
----------------------------------------------------------------------------------
 PROCEDURE add_dim_groups(qry IN OUT NOCOPY VARCHAR2, nested_str IN OUT NOCOPY varchar2) IS
  sel_str VARCHAR2(32000);
 BEGIN
--dimensional groups we'll add later, they don't allow multilevel grouping
  add_groups(sel_str, int_type_mult, nested_str);
  IF sel_str IS NULL AND is_only_top_rng THEN RETURN; END IF;
  sel_str := gen_state.alias||'.*'||CASE WHEN sel_str IS NOT NULL THEN ',' END||sel_str;
--  IF NOT is_only_top_rng THEN
--   sel_str := sel_str||int_rownum;
--  END IF;
  form_qry(qry, sel_str);
 END;
----------------------------------------------------------------------------------
PROCEDURE add_not_func(func BOOLEAN, COL VARCHAR2, selstr IN OUT NOCOPY VARCHAR2,
 grpstr IN OUT NOCOPY VARCHAR2) IS
BEGIN
 IF func THEN RETURN; END IF;
 From_Db_Utils.concatlist(selstr, COL);
 IF NOT is_col_nested(COL) THEN
  From_Db_Utils.concatlist(grpstr, COL);
 END IF;
END;
----------------------------------------------------------------------------------
 PROCEDURE group_by_levels(selitem IN OUT NOCOPY VARCHAR2, reg PLS_INTEGER, COL VARCHAR2,
   func_grp_id VARCHAR2, j PLS_INTEGER, i PLS_INTEGER) IS
  VER CONSTANT PLS_INTEGER := CASE
    WHEN qry_attrs(i).rng=top_rng AND gen_state.is_rownum1 THEN 1
    WHEN qry_attrs(i).rng=mid_rng AND gen_state.is_rownum2 THEN 2
 ELSE 3 END;
 BEGIN
  IF VER IN (1,2) THEN
   From_Db_Utils.concatlist(selitem,
  From_Db_Utils.concat_fun('case when '||
   CASE WHEN VER=1 THEN case when curr_dataset_no=qry_head.maxrng then rownum_col1 else rownumds_col1 end ELSE case when curr_dataset_no=qry_head.maxrng then rownum_col2 else rownumds_col2 end END ||
    '=1 then '||COL||' end', func_grp_id));
  ELSE
   IF qry_attrs(i).expr_id IS NULL THEN
    selitem := From_Db_Utils.concat_fun(COL, func_grp_id); --in fact, only SUM!!!!!!!
   ELSE
    selitem := add_expr_to_qry(i, --if we need indexes, no merging of function - it comes later
  CASE WHEN reg<>reg_ind_sel THEN From_Db_Utils.func_grp4exprs END, reg);
   END IF;
  END IF;
  sel_list(j).act_col := selitem;
--app_log.log_messageex('QRY', ver||':'||curr_dataset_no||':'||selitem);
--  selitem := selitem||' '||COL;
 END;
----------------------------------------------------------------------------------
PROCEDURE calc_qry_rng IS
  i PLS_INTEGER := qry_attrs.FIRST;
  tmp_dataset_nos numtab;
  ii pls_integer := 0;
BEGIN
  WHILE i IS NOT NULL LOOP
--   IF qry_attrs(i).expr_id IS NULL THEN
   qry_attrs(i).rng :=  From_Db_Utils.get_attr_lvl(NVL(qry_attrs(i).bid, qry_attrs(i).ID), qry_head.cube_);
   if qry_attrs(i).rng is not null then --not clear why the range was not calculated with expression attributes
    qry_head.minrng := LEAST(qry_attrs(i).rng, qry_head.minrng);
    qry_head.maxrng := GREATEST(qry_attrs(i).rng, qry_head.maxrng);
    tmp_dataset_nos(qry_attrs(i).rng) := qry_attrs(i).rng;
   END IF;
   i := qry_attrs.NEXT(i);
  END LOOP;
  i := tmp_dataset_nos.last;
  dataset_nos.delete;
  WHILE i IS NOT NULL LOOP
   ii := ii+1; dataset_nos(ii) := i;
   i := tmp_dataset_nos.prior(i);
  END LOOP;
END;
----------------------------------------------------------------------------------
 PROCEDURE add_multilevels_obsolete(qry IN OUT NOCOPY VARCHAR2) IS
  i PLS_INTEGER := qry_attrs.FIRST;
  j PLS_INTEGER;
  is_already BOOLEAN;
  i_new PLS_INTEGER;
  ilast PLS_INTEGER := qry_attrs.LAST;
 BEGIN
  WHILE i IS NOT NULL LOOP
   j := sel_list.FIRST;
   is_already := FALSE;
   WHILE (j IS NOT NULL) LOOP
    IF sel_list(j).attr_id=qry_attrs(i).ID THEN
 IF
    sel_list(j).func_grp_id IS NOT NULL AND
    sel_list(j).func_grp_id=NVL(qry_attrs(i).func_grp_id, sel_list(j).func_grp_id)
    AND (qry_attrs(i).grp_id IS NULL OR qry_attrs(i).grp_id=sel_list(j).grp_id) THEN
  IF sel_list(j).grp_type = From_Db_Utils.grp_type_nomulti THEN
   i_new := extend_qry_attrs(i);
   set_addcol(i_new);
      qry_attrs(i_new).func_grp_id := sel_list(j).func_grp_id;
      qry_attrs(i_new).COL := qry_attrs(i).COL;
  ELSIF NOT is_already THEN
   is_already := TRUE;
  END IF;
    END IF;
 END IF;
 j := sel_list.NEXT(j);
   END LOOP;
   EXIT WHEN i=ilast;
   i := qry_attrs.NEXT(i);
  END LOOP;
 END;
----------------------------------------------------------------------------------
 PROCEDURE add2sel_list_expr(el longchartab, i PLS_INTEGER) IS
  j PLS_INTEGER := el.FIRST;
  jj PLS_INTEGER;
  ordno_expr PLS_INTEGER := 0;
 BEGIN
    WHILE (j IS NOT NULL) LOOP
     IF el(j).t = tabattr THEN
    ordno_expr := ordno_expr+1;
   jj := sel_list.LAST+1;
      sel_list(jj) := sel_list(i);
      sel_list(jj).ATTR_IND := TO_NUMBER(el(j).s);
      sel_list(jj).ATTR_ID :=  qry_attrs(sel_list(jj).ATTR_IND).ID;
   IF sel_list(i).grp_type <> From_Db_Utils.grp_type_nomulti THEN
       sel_list(jj).FUNC_GRP_ID := From_Db_Utils.func_grp4exprs;
   END IF;
   sel_list(jj).COL := From_Db_Utils.get_exprcolname(sel_list(i).ordno, ordno_expr);
  END IF;
     j := el.NEXT(j);
    END LOOP;
 END;
----------------------------------------------------------------------------------
 PROCEDURE add2sel_list IS
  i PLS_INTEGER := sel_list.FIRST;
  ii PLS_INTEGER;
  tmp_func_id FUNC_GRP.ID%TYPE;
 BEGIN
  WHILE i IS NOT NULL LOOP --to fix Oracle bug, we must preliminary calculate, if we have grouping at all
   IF sel_list(i).func_grp_id IS NULL THEN
    qry_head.is_grouping := 1;
   END IF;
   tmp_func_id := NULL;
   IF sel_list(i).grp_type=From_Db_Utils.grp_type_nomulti THEN
    tmp_func_id := sel_list(i).func_grp_id;
   END IF;
   sel_list(i).attr_ind := get_attr_ind(sel_list(i).attr_id, sel_list(i).grp_id, TRUE,
    tmp_func_id);
   ii := qry_attrs(sel_list(i).attr_ind).expr_id;
   IF ii IS NOT NULL AND sel_list(i).grp_type <> From_Db_Utils.grp_type_nomulti THEN
    add2sel_list_expr(exprs_list(ii), i);
   END IF;
   i := sel_list.NEXT(i);
  END LOOP;
 END;
----------------------------------------------------------------------------------
 PROCEDURE add_rs_cols(sel_str IN OUT NOCOPY VARCHAR2, i PLS_INTEGER, col_a VARCHAR2,
   get_rs_suf BOOLEAN, add_sel OUT NOCOPY VARCHAR2) IS
  col_code VARCHAR2(30);
  tmp VARCHAR2(1000);
  TAB VARCHAR2(30);
  j PLS_INTEGER := sel_list(i).attr_ind;
  parent_key VARCHAR2(160) := col_a;
  is_real_group PLS_INTEGER;
  frst boolean := true;
  col_b varchar2(160);
  ii pls_integer;
 BEGIN --now doesn't work without CODE line in rs_...
  add_sel := sel_list(i).COL;
  IF From_Db_Utils.is_exprcolname(sel_list(i).COL) THEN
   sel_str := sel_str||' '||sel_list(i).COL;
  ELSE
   IF get_rs_suf THEN
    FOR c IN (SELECT * FROM show_qrys_sel_flat WHERE
               qry_id=qry_head.ID AND ordno=sel_list(i).ordno
      ORDER BY case when attr_type_code=Constants.code_code then 1 when attr_type_code=Constants.group_code then 2 else 3 end) LOOP
     if frst then
      if qry_attrs(j).dim_lev_id is not null then
      select max(colname) into col_code from rs_codes4dims
       where attr_type_code=Constants.code_code and dim_lev_id=qry_attrs(j).dim_lev_id;
      end if;
      frst := false;
      add_sel := null;
     end if;
     IF NOT(c.attr_type_code IN (Constants.code_code, Constants.group_code) OR c.colname IS NULL) THEN
      if substr(sel_str, -1, 1)<>',' then sel_str := sel_str||','; end if;
      IF qry_attrs(j).storage_type NOT IN (Constants.datetype/*, timetype*/)
          AND c.colname IS NOT NULL AND col_code IS NOT NULL
          AND (NVL(qry_attrs(j).dim_lev_id, 0)<>0 OR qry_attrs(j).grp_id IS NOT NULL) THEN
       IF qry_attrs(j).grp_id IS NOT NULL THEN
        TAB := 'grp_child_name';
        parent_key := qry_attrs(j).grp_id;
        is_real_group := get_is_real_group(qry_attrs(j).grp_id);
        IF is_real_group = 0 THEN
         col_code := 'ID';
        ELSE
         parent_key := qry_attrs(j).grp_id||' and ord='||db_diff.get_substr||'('||col_a||',1,5)';
        END IF;
        parent_key  := parent_key||' and '||col_a||' is not null';
       ELSE
        SELECT tab_name INTO TAB FROM DIM_LEVELS
         WHERE ID=qry_attrs(j).dim_lev_id;
       END IF;
       tmp := '(select '||c.colname||' from '
         ||TAB||' where '||col_code||'='||parent_key;
       if tab='DELAYCODE_SUB' then
        ii := sel_list.first;
        loop
         if sel_list(ii).scode='DELAYCODE' then
          col_b := gen_state.alias||'.'||sel_list(ii).col;
          exit;
         end if;
         ii := sel_list.next(ii);
         exit when ii is null;
        end loop;
        tmp := tmp||' and code='||col_b;
       end if;
       DB_DIFF.SET_LIMIT(tmp, 1);
       tmp := tmp||')';
       if qry_attrs(j).grp_id IS NOT NULL and is_real_group>0 then
        tmp := db_diff.get_nvl||'('||tmp||',upper('||db_diff.get_substr||'('||col_a||',6)))';
       end if;
       sel_str := sel_str||crlf||tmp;
      ELSE
       sel_str := sel_str||col_a;
      END IF;
     ELSE
      sel_str := sel_str||col_a;
      col_code := c.colname;
     END IF;
     sel_str := sel_str||' '||c.rs_name;
     add_sel := add_sel||case when add_sel is not null then ', ' end||c.rs_name;
    END LOOP;
   ELSE
    sel_str := sel_str||' '||sel_list(i).COL;
   END IF;
  END IF;
 END;
----------------------------------------------------------------------------------
 PROCEDURE add_rownum_cols(qry IN OUT NOCOPY VARCHAR2) IS
 /*
  i PLS_INTEGER := sel_list.FIRST;
  j PLS_INTEGER;
  tmp VARCHAR2(255);
  cols_low VARCHAR2(255);
  cols_mid VARCHAR2(255);
  skiptbl numtab;
 BEGIN
  WHILE i IS NOT NULL LOOP
 j := sel_list(i).attr_ind;
    IF sel_list(i).func_grp_id IS NOT NULL THEN
  IF qry_attrs(j).rng=top_rng THEN qry_head.is_fun_top := 1; END IF;
  IF qry_attrs(j).rng=mid_rng THEN qry_head.is_fun_mid := 1; END IF;
     skiptbl(j):=1;
 END IF;
    i := sel_list.NEXT(i);
  END LOOP;
  j := qry_attrs.first;
  WHILE j IS NOT NULL LOOP
    IF qry_attrs(j).grp_id IS NULL and not skiptbl.exists(j) THEN
  IF qry_attrs(j).rng IN (mid_rng, low_rng) THEN
   From_Db_Utils.concatlist(cols_mid, qry_attrs(j).COL);
  END IF;
  IF qry_attrs(j).rng=low_rng THEN
   From_Db_Utils.concatlist(cols_low, qry_attrs(j).COL);
  END IF;
 END IF;
     j := qry_attrs.next(j);
  END LOOP;
  IF qry_head.maxsrcrng<low_rng THEN --for detaled cubes we must group always
   IF qry_head.maxrng<=top_rng THEN qry_head.is_fun_top := 0; END IF;
   IF qry_head.maxrng<=mid_rng THEN qry_head.is_fun_mid := 0; END IF;
  END IF;
  IF qry_head.is_fun_top=1 THEN
   tmp :=tmp||
    ', row_number() over(partition by id1'||
  CASE WHEN cols_mid IS NOT NULL THEN ','||cols_mid END||
    ' order by 1) '||rownum_col1;
   gen_state.is_rownum1 := TRUE;
  END IF;
  IF qry_head.is_fun_mid=1 THEN
   IF tmp IS NOT NULL THEN tmp := tmp||crlf; END IF;
   tmp :=tmp||
    ', row_number() over(partition by id1, stopno_'||
  CASE WHEN cols_low IS NOT NULL THEN ','||cols_low END||
 ' order by 1) '||rownum_col2;
   gen_state.is_rownum2 := TRUE;
  END IF;
  qry := REPLACE(qry, int_rownum, tmp); */
  i PLS_INTEGER := sel_list.FIRST;
  j PLS_INTEGER;
  tmp VARCHAR2(1024);
  cols_low varchar2(1024);
  cols_mid varchar2(1024);
  col_ varchar2(30);
 BEGIN
  WHILE i IS NOT NULL LOOP
 j := sel_list(i).attr_ind;
    IF sel_list(i).func_grp_id IS NOT NULL THEN
  IF qry_attrs(j).rng=top_rng THEN qry_head.is_fun_top := 1; END IF;
  IF qry_attrs(j).rng=mid_rng THEN qry_head.is_fun_mid := 1; END IF;
    else
/*     col_ := qry_attrs(j).col;
     if is_col_nested(col_) then
      col_ := col_||'.column_value';
     end if;*/
     col_ := sel_list(i).col;
  IF qry_attrs(j).rng in (mid_rng, low_rng) or qry_attrs(j).grp_id is not null THEN
   from_db_utils.concatlist(cols_mid, col_);
  END IF;
  IF qry_attrs(j).rng=low_rng  or qry_attrs(j).grp_id is not null THEN
   from_db_utils.concatlist(cols_low, col_);
  END IF;
 END IF;
   i := sel_list.NEXT(i);
  END LOOP;
  IF qry_head.maxsrcrng<low_rng THEN --for detaled cubes we must group always
   IF qry_head.maxrng<=top_rng THEN qry_head.is_fun_top := 0; END IF;
   IF qry_head.maxrng<=mid_rng THEN qry_head.is_fun_mid := 0; END IF;
  END IF;
  IF qry_head.is_fun_top=1 THEN
   from_db_utils.concatlist(tmp,
    ' row_number() over(partition by id1'||
  case when cols_mid is not null then ','||cols_mid end||
    ' order by id1) '||rownum_col1);
   from_db_utils.concatlist(tmp,
    ' row_number() over(partition by id1 order by id1) '||rownumds_col1);
   gen_state.is_rownum1 := TRUE;
  END IF;
  IF qry_head.is_fun_mid=1 THEN
   IF tmp IS NOT NULL THEN tmp := tmp||crlf; END IF;
   from_db_utils.concatlist(tmp,
    ' row_number() over(partition by id1, stopno_'||
  case when cols_low is not null then ','||cols_low end||
 ' order by id1) '||rownum_col2);
   from_db_utils.concatlist(tmp,
    ' row_number() over(partition by id1, stopno_ order by id1) '||rownumds_col2);
   gen_state.is_rownum2 := TRUE;
  END IF;
  if tmp is not null then
   form_qry(qry, gen_state.alias||'.*,'||tmp, gen_state.alias);
--   from_db_utils.concatlist(qry, tmp);
  end if;
  IF is_only_top_rng THEN
   qry := REPLACE(qry, int_where, ' where stopno=1');
  END IF;
 END;
----------------------------------------------------------------------------------
 PROCEDURE add_nested(qry IN OUT NOCOPY VARCHAR2, nested_str varchar2) IS
  group_str VARCHAR2(16000);
  from_str VARCHAR2(4000) := gen_state.alias;
  sel_str VARCHAR2(16000);
  col_ VARCHAR2(30);
  col_a VARCHAR2(1000);
  j PLS_INTEGER;
  is_nested BOOLEAN;
  i PLS_INTEGER := sel_list.FIRST;
  hints_str varchar2(4000);
 BEGIN
  WHILE i IS NOT NULL LOOP
   j := sel_list(i).attr_ind;
   col_ := qry_attrs(j).COL;
   col_a := gen_state.alias||'.'||col_;
   is_nested := is_col_nested(col_);
   IF sel_str IS NOT NULL THEN sel_str := sel_str||','; END IF;
   IF is_nested THEN
--    from_str := from_str||','||'table('||col_a||')(+) '||col_;
    col_a := col_||'.txt';
    hints_str := hints_str||'cardinality('||COL_||' 1) ' ;
   END IF;
   IF  qry_attrs(j).expr_id IS NOT NULL THEN
    col_a := add_expr_to_qry(j, NULL);
   END IF;
   sel_str := sel_str||col_a||' '||sel_list(i).COL;
   i := sel_list.NEXT(i);
  END LOOP;
  from_str := from_str||nested_str;
  add_mandatory_cols(sel_str, 3);
  if length( hints_str)>0 then hints_str := '/*+'||hints_str||'*/'; end if;
--  add_rownum_cols(sel_str); --here is, at last, everything set, but not correct
/*  IF gen_state.is_rownum1 THEN
   From_Db_Utils.concatlist(sel_str, rownum_col1);
  END IF;
  IF gen_state.is_rownum2 THEN
   From_Db_Utils.concatlist(sel_str, rownum_col2);
  END IF;*/
  form_qry(qry, sel_str, from_str, hints_str=>hints_str);
 END;
----------------------------------------------------------------------------------
PROCEDURE reset_exprs2sel_list IS
 i PLS_INTEGER := sel_list.FIRST;
 j PLS_INTEGER;
 ii PLS_INTEGER;
 ind_attrs PLS_INTEGER;
 ij PLS_INTEGER;
 BEGIN
  WHILE i IS NOT NULL LOOP
   ii := qry_attrs(sel_list(i).attr_ind).expr_id;
   IF  ii IS NOT NULL THEN
    j := exprs_list(ii).FIRST;
 WHILE j IS NOT NULL LOOP
  IF exprs_list(ii)(j).t=tabattr THEN
   ind_attrs := TO_NUMBER(exprs_list(ii)(j).s);
   ij := sel_list.NEXT(i);
   WHILE ij IS NOT NULL LOOP
    IF sel_list(ij).ordno=sel_list(i).ordno AND
       sel_list(ij).attr_ind=ind_attrs THEN
  exprs_list(ii)(j).s := ij;
     EXIT;
    END IF;
    ij := sel_list.NEXT(ij);
   END LOOP;
  END IF;
  j := exprs_list(ii).NEXT(j);
 END LOOP;
   END IF;
   i := sel_list.NEXT(i);
  END LOOP;
 END;
----------------------------------------------------------------------------------
 procedure add_levels_to_headers(bid attrs.id%type, ord_ pls_integer, levs4nullrow OUT numtab) is
  val  varchar2(100);
  vald varchar2(100);
  n pls_integer := 0;
  cursor qq is
   select q.grp_id4val, q.val, q.rowid rid,
     d.dim_lev_id, d.dim_lev_code, l.storage_type, l.dim_id
    from qry_grp_headers q, grp_d d, dim_levels l
    where qry_id=qry_head.id and attr_id=bid and
      d.grp_id=q.grp_id4val and d.dim_lev_id=l.id
     order by l.dim_id, l.ordno desc;
  s varchar2(4000);
  sd varchar2(255);
  msk varchar2(30);
  eol constant varchar2(2) := constants.eol;
  rid rowid;
 begin
  for q in qq loop
   s := ''; vald := null; val := q.dim_lev_code;
   if q.storage_type=Constants.datetype then
    select r.display_format
     into msk from rs_codes4dims r
     where dim_lev_id=q.dim_lev_id and attr_type_code=constants.code_code;
    vald := FROM_DB_UTILS.TO_OUR_DATE(val, msk);
   end if;
   val := quote_const(Constants.chartype, val);
   vald := nvl(vald, val);
   for c in (select qs.dim_lev_id, /*decode(d.dim_id, q.dim_id, null, tc.fun_row_conv)*/ fun_row_conv
     from qrys_sel qs, types_comp tc, dim_levels d
     where qry_id=qry_head.id and attr_id=bid and qs.dim_lev_id is not null
      and qs.ordno<>ord_ and TC.TYPE_ID=q.dim_lev_id and TC.COMP_TYPE_ID=qs.dim_lev_id
      and TC.COMP_TYPE_ID=d.id
     order by qs.ordno) loop
    if levs4nullrow.exists(c.dim_lev_id) then
     n := levs4nullrow(c.dim_lev_id);
    else
     n := levs4nullrow.count+1;
    end if;
    levs4nullrow(c.dim_lev_id) := n;
    if s is null then
     s := 'update qry_grp_headers set '||eol;
    else
     s := s||','||eol;
    end if;
    s := s||' l'||n||'='||c.dim_lev_id||', d'||n||'=';
    if q.dim_lev_id=c.dim_lev_id then
     sd := val;
    elsif c.fun_row_conv is null then
    select max(d.dim_lev_code) into sd from
      (select id from grp_tree gt where parent_id<0
        connect by prior parent_id=id
        start with id=q.grp_id4val
      ) g, grp_d d
      where g.id=d.grp_id and d.dim_lev_id=c.dim_lev_id;
     sd := quote_const(Constants.chartype, sd);
    else
     sd := vald;
    end if;
    if sd is not null then
    s := s||case when c.fun_row_conv is null then sd
            else FROM_DB_UTILS.CONCAT_FUN(sd, null, c.fun_row_conv) end;
    else
     write_log.log_message('NIL '||q.grp_id4val);
    END if;
   end loop;
   if s is not null then
    s := s||eol||' where rowid=:rid';
--  WRITE_LOG.LOG_MESSAGE('QRY', s);
    execute immediate s using q.rid;
   end if;
  end loop;
 end;
----------------------------------------------------------------------------------
PROCEDURE add_null_lines(qry IN OUT NOCOPY VARCHAR2) IS
  sel_str VARCHAR2(4000);
  part_str VARCHAR2(4000):=' ';
  for_str VARCHAR2(4000);
  on_str VARCHAR2(4000) := ' ON (';
  j PLS_INTEGER;
  i PLS_INTEGER := sel_list.FIRST;
  tmp VARCHAR2(1000);
  nt pls_integer := 0;
  ntc varchar2(30);
  ntv varchar2(30);
  wrk pls_integer;
  qry_grp_str constant varchar2(100):= 'val v%1%, d1 d1_%1%, d2 d2_%1%, d3 d3_%1%, d4 d4_%1%';
  levs4nullrow  numtab;
  levs4nullrows numtab2;
  bid attrs.id%type;
  bids numtab;
  sel_str_tab chartab;
  nvl_lev pls_integer;
  dli dim_levels.id%type;
 BEGIN --!!!nulls
  WHILE i IS NOT NULL LOOP
   j := sel_list(i).attr_ind;
   bid := nvl(qry_attrs(j).bid, qry_attrs(j).id);
   if bitand(sel_list(i).how, constants.how_null_flag)>0 then
    nt := nt + 1;
    add_levels_to_headers(bid, sel_list(i).ordno, levs4nullrow);
    levs4nullrows(nt) := levs4nullrow;
    bids(bid) := nt;
    if nt=1 then
     for_str := for_str||' right outer join (select * from ';
    else
     for_str := for_str||','||crlf;
     on_str := on_str||' and ';
    end if;
    ntc := 't'||nt;
    ntv := 'v'||nt;
    for_str := for_str ||'(select '||replace(qry_grp_str, '%1%', nt)
     ||' from QRY_GRP_HEADERS where QRY_ID='||qry_head.id||
     ' and ATTR_ID= '||nvl(qry_attrs(sel_list(i).attr_ind).bid, sel_list(i).attr_id)||' and GRP_ID='||nvl(sel_list(i).grp_id, TREE_FNC.ROOT_NOT_D)||') '||ntc;
    on_str := on_str||sel_list(i).COL||'='||ntv;
    sel_str_tab(i) := ntv||' '||sel_list(i).COL;
   else
    sel_str_tab(i) := sel_list(i).col;
    if sel_list(i).func_grp_id is null then
     wrk := nvl(qry_attrs(j).bid, qry_attrs(j).id);
     select count(*) into wrk from qrys_sel q
      where attr_id=wrk and qry_id=qry_head.id and bitand(how, constants.how_null_flag)>0;
     if wrk=0 then
--WRITE_LOG.LOG_MESSAGE('col='||sel_list(i).col||', attr_id='||sel_list(i).attr_id||', qry_id='||qry_head.id||', attrs.bid='||qry_attrs(j).bid);
      if ltrim(part_str) is null then
       part_str := ' partition by (';
      else
       part_str := part_str||',';
      end if;
      part_str := part_str||sel_list(i).col;
     end if;
    end if;
   end if;
   i := sel_list.NEXT(i);
  END LOOP;
  i := sel_list.FIRST;
  WHILE i IS NOT NULL LOOP
   j := sel_list(i).attr_ind;
--   bid := sel_list(i).attr_id;
   bid := nvl(qry_attrs(j).bid, qry_attrs(j).id);
   if sel_str is not null then sel_str := sel_str||','; end if;
   nvl_lev := null;
   if bids.exists(bid) and bitand(sel_list(i).how, constants.how_null_flag)=0 then
    nt := bids(bid);
    if levs4nullrows(nt).count>0 then
     dli := qry_attrs(j).dim_lev_id;
    if dli is not null then
      if levs4nullrows(nt).exists(dli) then
       nvl_lev := levs4nullrows(nt)(dli);
      end if;
     end if;
    end if;
   end if;
   if nvl_lev is not null then
    sel_str := sel_str||db_diff.get_nvl||'('||sel_str_tab(i)||',d'||nvl_lev||'_'||nt||') '||sel_str_tab(i);
   else
    sel_str := sel_str||sel_str_tab(i);
   end if;
   i := sel_list.NEXT(i);
  END LOOP;
  if bids.count>0 then
   if rtrim(part_str) is not null then part_str := part_str||')'; end if;
   on_str := on_str||')';
   for_str := gen_state.alias||part_str||crlf||for_str||') a';
   for_str := for_str||crlf||on_str;
  else
   return;
  end if;
  form_qry(qry, sel_str, for_str, null);
 END;
----------------------------------------------------------------------------------
PROCEDURE add_final_grouping(qry IN OUT NOCOPY VARCHAR2, group_str IN OUT NOCOPY VARCHAR2) IS
  sel_str VARCHAR2(4000); --we do not need group_str as a parameter now
  col_a VARCHAR2(100);
  j PLS_INTEGER;
  i PLS_INTEGER := sel_list.FIRST;
  tmp VARCHAR2(1000);
  rng pls_integer;
 BEGIN
  WHILE i IS NOT NULL LOOP
   j := sel_list(i).attr_ind;
   rng := qry_attrs(j).rng;
   if curr_dataset_no=qry_head.maxrng or rng<=curr_dataset_no then
    col_a := gen_state.alias||'.'||sel_list(i).COL;
   else
    col_a := 'null';
   end if;
   IF sel_str IS NOT NULL THEN sel_str := sel_str||','; END IF;
   IF sel_list(i).func_grp_id IS NULL THEN
    if col_a<>'null' then
     IF group_str IS NOT NULL THEN group_str := group_str||','; END IF;
     group_str := group_str||col_a;
    end if;
    sel_str := sel_str||col_a;
   ELSE
    tmp := '';
    if col_a='null' then
     tmp := col_a;
    ELSIF /* qry_attrs(j).expr_id is null or */sel_list(i).grp_type=From_Db_Utils.grp_type_nomulti THEN
     tmp := From_Db_Utils.concat_fun(col_a, sel_list(i).func_grp_id);
    ELSE
     group_by_levels(tmp, reg_ind_sel, sel_list(i).COL, sel_list(i).func_grp_id, i, j);
    END IF;
    tmp := tmp||' '||sel_list(i).COL;
    sel_str := sel_str||tmp;
   END IF;
   i := sel_list.NEXT(i);
  END LOOP;
--here expression processing
  i := sel_list.FIRST;
  WHILE i IS NOT NULL LOOP
   IF From_Db_Utils.is_exprcolname(sel_list(i).COL) THEN
    sel_str := REPLACE(sel_str, ph||trim(i)||ph, sel_list(i).act_col);
   END IF;
   i := sel_list.NEXT(i);
  END LOOP;
  sel_str := sel_str||', '||case when curr_dataset_no=qry_head.maxrng then 0 else curr_dataset_no end||' dataset_no';
  form_qry(qry, sel_str, NULL, group_str);
  group_str := replace(group_str, gen_state.alias||'.', '');
 END;
----------------------------------------------------------------------------------
PROCEDURE add_final_list(qry IN OUT NOCOPY VARCHAR2, ds_list_ out gen_copy4user.vc_list) IS
  sel_str VARCHAR2(32000);
  add_sel VARCHAR2(32000);
  col_a VARCHAR2(100);
  j PLS_INTEGER;
  i PLS_INTEGER := sel_list.FIRST;
  rn1 VARCHAR2(1000);
  rn2 VARCHAR2(1000);
  rng_ pls_integer;
  maxrngv pls_integer := -1;
  skip_ds boolean := false;
 procedure add_rn(rn varchar2, rnum pls_integer) is
 begin
  sel_str := sel_str||','||constants.eol||case when rn is null then ' 0 ' else ' dense_rank() over(order by '||rn||')' end ||' rn'||rnum;
 end;
 BEGIN
  if qry_head.maxrng!=qry_head.minrng then
   WHILE i IS NOT NULL LOOP
    j := sel_list(i).attr_ind;
    if qry_attrs(j).show=CONSTANTS.show_val then
     rng_ := qry_attrs(j).rng;
     if rng_ is not null then
      if not ds_list_.exists(rng_) then
       ds_list_(rng_) := '';
       maxrngv := greatest(maxrngv, rng_);
      end if;
     else
app_log.log_messageex('OPAL', 'Null range of attr '||qry_attrs(j).id);
     end if;
    end if;
    i := sel_list.NEXT(i);
   end loop;
  end if;
  i := sel_list.FIRST;
  WHILE i IS NOT NULL LOOP
   j := sel_list(i).attr_ind;
   col_a := gen_state.alias||'.'||sel_list(i).COL;
   IF sel_str IS NOT NULL THEN sel_str := sel_str||','; END IF;
   add_rs_cols(sel_str, i, col_a, TRUE, add_sel);
   rng_ := qry_attrs(j).rng;
   if qry_attrs(j).show=CONSTANTS.show_key then
    if rng_=1 then
     rn1 := rn1||case when rn1 is not null then ',' end ||col_a;
     rn2 := rn2||case when rn2 is not null then ',' end ||col_a;
    end if;
    if rng_=2 then
     rn2 := rn2||case when rn2 is not null then ',' end ||col_a;
    end if;
   end if;
   if rng_ is not null then
    for ii in 1..3 loop
     continue when rng_>ii or rng_<ii and qry_attrs(j).show=CONSTANTS.show_val or not ds_list_.exists(ii);
     ds_list_(ii) := ds_list_(ii)||','||add_sel;
    end loop;
   end if;
   i := sel_list.NEXT(i);
  END LOOP;
  if ds_list_.count=0 or ds_list_.count=1 and maxrngv=qry_head.maxrng then
   ds_list.delete;
   rn1 := null; rn2 := null;
  end if;
  add_rn(rn1, 1);
  add_rn(rn2, 2);
  form_qry(qry, sel_str);
 END;
 -----------------------------------------------------------------------------------------
PROCEDURE set_qry_globals(qry_id_ QRYS.ID%TYPE) IS
 i PLS_INTEGER;
 attrtab numtab;
 CURSOR mainattrs IS
  SELECT attr_id, MIN(ordno) ordno, MAX(in_cond) in_cond
  FROM (
  SELECT NVL(a.ID, attr_id) attr_id, ordno, 'N' in_cond FROM QRYS_SEL q, ATTRS a
   WHERE qry_id=qry_id_ AND q.attr_id=a.parent_id(+) AND q.dim_lev_id=a.dim_lev_id(+)
   UNION
  SELECT attr_id, maxordno-1 ordno, 'E' in_cond FROM (
   SELECT attr_id FROM EXPRS e, LEAFS4EXPRS l
   WHERE e.ID=l.leaf_id(+) AND e.is_leaf=1
   START WITH ID IN (SELECT expr_id FROM ATTRS a, QRYS_SEL q WHERE
    qry_id=qry_id_ AND (a.ID=q.attr_id OR a.parent_id=q.attr_id))
   CONNECT BY PRIOR ID=parent_id
  ) WHERE attr_id IS NOT NULL
   UNION
  SELECT attr_id, maxordno ordno, 'Y' in_cond FROM (
  SELECT --+index(l)
   DECODE(n, 1, left_attr_id, right_attr_id) attr_id
  FROM (
  SELECT ID
   FROM CONDS c
   WHERE is_leaf=1
   START WITH ID IN (qry_head.where_, qry_head.having_)
   CONNECT BY PRIOR ID=parent_id
  ) c, LEAFS4CONDS l, MULTIPLIER m
   WHERE c.ID= l.leaf_id AND m.n<=2
  ) WHERE attr_id IS NOT NULL
  ) t
  GROUP BY t.attr_id
  ORDER BY 2;
  CURSOR ee(expr_ PLS_INTEGER) IS
   SELECT attr_id FROM EXPRS e, LEAFS4EXPRS l
    WHERE e.ID=l.leaf_id(+) AND e.is_leaf=1 AND attr_id IS NOT NULL
    START WITH ID=expr_
    CONNECT BY PRIOR ID=parent_id;
 more_exprs BOOLEAN := TRUE;
 qry_head_null qry_head_type;
BEGIN
 qry_attrs := attrs_type_tab(); qry_head := qry_head_null;
 SELECT q.ID, q.WHERE_ID, q.HAVING_ID, q.CUBE_ID, q.QRY_TYPE, q.abbr, c.TAB
  INTO qry_head.ID, qry_head.WHERE_, qry_head.HAVING_,
    qry_head.CUBE_, qry_head.QRY_TYPE_, qry_head.abbr, qry_head.TAB
  FROM QRYS q, CUBES c WHERE q.ID=qry_id_ AND q.cube_id=c.ID;
 --after specifying of the source with more details, it must be changed
 SELECT MAX(rng) INTO qry_head.maxsrcrng FROM recs_tree WHERE cube_id=qry_head.CUBE_;
 FOR t1 IN mainattrs LOOP
  set_qry_attr1(t1.attr_id, attrtab, t1.ordno, t1.in_cond);
 END LOOP;
 WHILE more_exprs LOOP
  more_exprs := FALSE;
  i := qry_attrs.FIRST;
  WHILE (i IS NOT NULL) LOOP
   IF qry_attrs(i).expr_id IS NOT NULL THEN
    FOR e IN ee(qry_attrs(i).expr_id) LOOP
     IF NOT attrtab.EXISTS(e.attr_id) THEN
      set_qry_attr1(e.attr_id, attrtab);
   more_exprs := TRUE;
  END IF;
 END LOOP;
   END IF;
   i := qry_attrs.NEXT(i);
  END LOOP;
 END LOOP;
 i := qry_attrs.FIRST;
 WHILE (i IS NOT NULL) LOOP
  IF qry_attrs(i).COL IS NULL THEN
   set_addcol(i);
  END IF;
  i := qry_attrs.NEXT(i);
 END LOOP;
 SELECT NVL(a.ID, q.ATTR_ID) attr_id, q.FUNC_GRP_ID,
   case when not (q.how>0 and q.dim_lev_id is not null) then case when q.grp_id>999999 then get_ph_group(q.grp_id) else q.GRP_ID end end grp_id,
   q.GRP_LEV_ORDNO, q.ORDNO,
   f.grp_type, 0 attr_ind, 'F'||q.ordno COL, '' act_col, q.how
   , nvl((select scode from attrs where id=NVL(a.ID, q.ATTR_ID)), (select a2.scode from attrs a1 join attrs a2 on a2.id=a1.parent_id where a1.id=NVL(a.ID, q.ATTR_ID))) scode
  BULK COLLECT INTO sel_list
  FROM QRYS_SEL q, FUNC_GRP f, ATTRS a
  WHERE q.qry_id=qry_id_ AND q.func_grp_id = f.ID(+) AND noshow IS NULL
   AND q.attr_id=a.parent_id(+) AND q.dim_lev_id=a.dim_lev_id(+)
  ORDER BY q.ordno;
 set_grp_time_attr;
 add_atrrs4dimgroups;
 add_atrrs4contgroups;
 exprs_list.DELETE;
END;
----------------------------------------------------------------------------------
PROCEDURE TEST_QRY(qry_id_ PLS_INTEGER, qry VARCHAR2) IS
 PRAGMA autonomous_transaction;
BEGIN
  DELETE TEST_QRY;
  INSERT INTO TEST_QRY(ID, qry) VALUES(qry_id_, qry);
  COMMIT;
END;
-----------------------------------------------------------------------------------------
 PROCEDURE setlvl(lvl PLS_INTEGER) IS
 BEGIN
  gen_state.lvl := lvl; gen_state.alias:='lvl'||gen_state.lvl;
 END;
----------------------------------------------------------------------------------
procedure preprocess_flags is
 cursor cc is
  select case when grp_id>999999 then get_ph_group(grp_id) else grp_id end grp_id, attr_id, dim_lev_id from qrys_sel
    where qry_id=qry_head.id and bitand(how, CONSTANTS.HOW_NULL_FLAG)>0
     and dim_lev_id is not null and grp_id is not null
    for update;
begin
 for c in cc loop
-- write_log.log_message(qry_head.id||':'||c.grp_id||':'||c.dim_lev_id);
  insert into qry_grp_headers(QRY_ID, ATTR_ID, GRP_ID, VAL, GRP_ID4VAL)
   SELECT DISTINCT qry_head.id, c.attr_id, tree_fnc.root_not_d, g.dim_lev_code, g.grp_id
    FROM (
     SELECT --+index(t I_GRP_TREE_P)
      t.*  FROM GRP_TREE t
     START WITH parent_id=c.grp_id
     CONNECT BY PRIOR ID=parent_id
    ) gt, GRP_D g
    WHERE gt.ID=g.grp_id AND g.dim_lev_id=c.dim_lev_id;
  update qrys_sel set grp_id=null where current of cc;
 end loop;
end;
-----------------------------------------------------------------------------------------
 procedure adjust_ds_list(ds_list_ in out nocopy gen_copy4user.vc_list, qry_tab varchar2) is
  s varchar2(1000);
  tbl tstrings32;
begin
 if ds_list_.count>1 then
  for i in 1..3 loop
   if ds_list_.exists(i) then
    s := ltrim(ds_list_(i), ', ');
    if s is not null then
     tbl := str4user.parlist2tbl(s);
     s := null;
     for ii in 1..tbl.count loop
      for c in (select column_name, data_type, data_length, data_precision from user_tab_columns where table_name=qry_tab and column_name=tbl(ii)) loop
       adjust_column(s, c.column_name, c.data_type, c.data_length, c.data_precision);
      end loop;
     end loop;
     ds_list_(i) := rtrim(s, ', ');
    end if;
   end if;
  end loop;
 end if;
end;
-----------------------------------------------------------------------------------------
 procedure add_ds_list(ds_list_ gen_copy4user.vc_list, qry_tab varchar2) is
  s varchar2(1000);
begin
 delete datasets where qry_id=qry_head.ID;
 if ds_list_.count>1 then
  for i in 1..3 loop
   if ds_list_.exists(i) then
    s := ltrim(ds_list_(i), ', ');
    if s is not null then
     s := 'select '||case when i<3 then 'distinct 'end||s||', rn1'||case when i>1 then ',rn2' end||' from '||qry_tab||
      ' t where dataset_no='||case when i>=qry_head.maxrng then 0 else i end;
     insert into datasets(QRY_ID, RNG, QRY, LVL_NAME, TABNAME)
      values(qry_head.ID, i, s, analyzer.get_level_name(qry_head.cube_, i), qry_tab/*||'_'||i*/);
    end if;
   end if;
  end loop;
  insert into datasets(QRY_ID, RNG, QRY, LVL_NAME, TABNAME)
   values(qry_head.ID, 0, get_main_qry(qry_tab, 0), 'Multilevel', qry_tab);
 else
  insert into datasets(QRY_ID, RNG, QRY, LVL_NAME, TABNAME)
   values(qry_head.ID, 0, get_main_qry(qry_tab), analyzer.get_level_name(qry_head.cube_, qry_head.maxrng), qry_tab);
 end if;
end;
-----------------------------------------------------------------------------------------
 PROCEDURE gen_qry(qry_id_ QRYS.ID%TYPE, qry IN OUT NOCOPY VARCHAR2,
   do_create PLS_INTEGER := 1) IS
  where_str VARCHAR2(32000);
  with_str VARCHAR2(32000);
  nested_str VARCHAR2(32000);
  id_ QRYS.ID%TYPE := qry_id_;
  gen_state_null gen_state_type;
  group_str varchar2(4000);
  qi pls_integer := 0;
  qry_tab varchar2(30);
  zqry varchar2(32000);
 BEGIN
  delete TMP_GROUPS where qry_id=id_;
/* select max(id) into qi from qrys where abbr like 'null1%'; --!!!nulls test purposes!!!*/
  delete QRY_GRP_HEADERS where qry_id=id_;
/* update qrys_sel set how=1 where qry_id =qi
  and grp_id is not null and how is null;*/
  if db_diff.curr_db=db_diff.oracle_db then
   select nvl(max(parvalue), '0') into qi from params
    where parid='DO_TEMP' and taskid='GEN';
  end if;
  gen_state := gen_state_null;
  setlvl(1);
  set_qry_globals(id_);
  IF qry_attrs.FIRST IS NULL THEN RETURN; END IF;
  preprocess_flags;
  add_exprs(qry);
  set_where(where_str);
  set_select_all(qry);
  setlvl(2);
  add_where_groups(qry, where_str);
  setlvl(3);
  calc_qry_rng;
  add_multilevels_obsolete(qry);
  add_dim_groups(qry, nested_str);
  setlvl(4);
  add2sel_list;
  add_nested(qry, nested_str);
  reset_exprs2sel_list;
--  setlvl(6);
--  add_multilevels(qry);
  setlvl(5);
  add_rownum_cols(qry); --here is, at last, everything set, but not correct
  with_str := 'with qry as ('||crlf||qry||')';
  setlvl(6);
  for i in dataset_nos.first..dataset_nos.last loop
   exit when i>1 and opal_ver is null;
   curr_dataset_no := dataset_nos(i);
   zqry := 'qry';
   group_str := null;
   add_final_grouping(zqry, group_str);
   if i=dataset_nos.first then
    qry := zqry;
   else
    qry := qry||crlf||'union all'||crlf||zqry;
   end if;
  end loop;
  setlvl(7);
  add_null_lines(qry);
  setlvl(8);
  add_final_list(qry, ds_list);
  qry := with_str||crlf||qry;
  qry:=REPLACE(qry, int_where, '');
  qry_tab :=  From_Db_Utils.get_qry_tab(qry_head.ID);
  IF do_create=1 THEN
   if qi=0 then
    qry := 'create table "'||qry_tab||'" nologging as '||qry;
   else
    qry := 'create global temporary table "'||qry_tab||'" on commit preserve rows as '||qry;
   end if;
  END IF;
--  add_ds_list(ds_list, qry_tab); --went to exec_qry
--only to bypass Oracle 10.2.0.4 bug, seems is extra in later versions
--  qry := qry||' where rownum<10000000000';
  TEST_QRY(id_, qry);
  commit;
 END;
 -----------------------------------------------------------------------------------------
 FUNCTION get_gen_qry(qry_id_ QRYS.ID%TYPE, do_create PLS_INTEGER := 0)
  RETURN VARCHAR2 IS
   qry VARCHAR2(32676);
 BEGIN
  gen_qry(qry_id_, qry, do_create);
  RETURN qry;
 END;
-----------------------------------------------------------------------------------------
 PROCEDURE exec_qry(qry VARCHAR2, qry_id_ QRYS.ID%TYPE:=NULL) IS
  t1 NUMBER := DBMS_UTILITY.GET_TIME;
  id_ QRYS.ID%TYPE := qry_id_; --Oracle error bypassing
 BEGIN
--  ck.set_curr_ck; --now front end takes care of security
  EXECUTE IMMEDIATE qry;
  curr_rowcount := sql%rowcount;
  From_Db_Utils.mark_qry(id_, t1);
  for c in (select org_id, reccount from qrys where id=id_ and org_id<>id_) loop
   From_Db_Utils.mark_qry(c.org_id, t1, c.reccount);
  end loop;
 --  for c in (select * from datasets where qry_id=id_ and rng>0) loop
--   execute immediate 'create table '||c.tabname||' as '||c.qry;
--  end loop;
  COMMIT;
 END;
 -----------------------------------------------------------------------------------------
 PROCEDURE gen_exec_qry(qry_id_ QRYS.ID%TYPE, res_cursor OUT ret_cursor) AS
  qry_txt VARCHAR2(32000);
  id_ QRYS.ID%TYPE := qry_id_; --Oracle error bypassing
 BEGIN
  gen_qry(id_, qry_txt);
  From_Db_Utils.drop_qry_tab(id_);
  exec_qry(qry_txt, id_);
  adjust_ds_list(ds_list, From_Db_Utils.get_qry_tab(qry_id_)); --add cast to fix a front end problem
  add_ds_list(ds_list, From_Db_Utils.get_qry_tab(qry_id_));
 END;
--------------------------------------------------------------------------
PROCEDURE get_cursor(qry_id_ NUMBER, res_cursor IN OUT ret_cursor)
IS
  id_ QRYS.ID%TYPE := qry_id_; --Oracle error bypassing
  qry_abbr VARCHAR2(30):= From_Db_Utils.get_qry_tab(id_);
  s VARCHAR2(4000);
BEGIN
 IF res_cursor%isopen THEN
  CLOSE res_cursor;
 END IF;
 gen_exec_qry(id_, res_cursor);
 s := get_main_qry(qry_abbr);
 OPEN res_cursor FOR s;
END;
-------------------------------------------------------------------------------
PROCEDURE get_dataset(qry_id_ datasets.qry_id%type, ds_lvl datasets.rng%type, is_cursor OUT pls_integer,
   res_cursor IN OUT ret_cursor, ds_name OUT datasets.lvl_name%type) IS
  s VARCHAR2(4000);
  tn datasets.tabname%type;
  rng pls_integer;
BEGIN
 IF res_cursor%isopen THEN
  CLOSE res_cursor;
 END IF;
 select max(tabname), max(lvl_name) into tn, ds_name from datasets where qry_id=qry_id_ and rng=ds_lvl and qry is not null;
 is_cursor := case when tn is not null then 1 else 0 end;
 if is_cursor=1 then
  select qry into s from datasets where qry_id=qry_id_ and rng=ds_lvl;
--  s := get_main_qry(tn, ds_lvl);
  OPEN res_cursor FOR s;
 end if;
END;
--------------------------------------------------------------------------
--obsolete procedure, only for backward compatibility (if any)
PROCEDURE get_cursor_by_abbr(qry_abbr VARCHAR2, res_cursor IN OUT ret_cursor)
IS
  qry_id_ QRYS.ID%TYPE;
BEGIN
 SELECT ID INTO qry_id_ FROM QRYS q WHERE q.abbr=qry_abbr;
 get_cursor(qry_id_, res_cursor);
END;
--------------------------------------------------------------------------
PROCEDURE get_qry(qry_id_ NUMBER, qry IN OUT NOCOPY VARCHAR2)
IS
 id_ QRYS.ID%TYPE := qry_id_; --Oracle error bypassing
 qry_abbr QRYS.abbr%TYPE := From_Db_Utils.get_qry_tab(id_);
BEGIN
  qry := 'select * ';
  qry := qry||CHR(10)||' from "'||qry_abbr||'"';
END;
-------------------------------------------------------------------------------
END;
/