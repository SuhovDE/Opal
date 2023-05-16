--
-- ANALYZER  (Package Body) 
--
--  Dependencies: 
--   ANALYZER (Package)
--   TSTRINGS250 (Type)
--   ATTRS (Table)
--   ATTRS2CUBES (Table)
--   CONDELEMLIST (Type)
--   CONDELEMOBJ (Type)
--   CONDEXPRLIST (Type)
--   CONDEXPROBJ (Type)
--   CONDS (Table)
--   CONSTANTS (Package)
--   CUBES (Table)
--   DATA_SERVICE (Package)
--   DIMFILTERLIST (Type)
--   DIMFILTEROBJ (Type)
--   DIMLEVELLIST (Type)
--   DIMLEVELOBJ (Type)
--   DIM_GRP_OBJ (Type)
--   DIM_LEVELS (Table)
--   ERRORS (Synonym)
--   FOLDERS (Table)
--   FROM_DB_UTILS (Package)
--   FR_STATUS_UTILS (Package)
--   GROUPS (Table)
--   GROUPS_FNC (Package)
--   GRP_D (Table)
--   GRP_TREE (Table)
--   IS_QRYS_ADMIN (Function)
--   LANGUAGES (Table)
--   LEAFS4CONDS (Table)
--   QRYS (Table)
--   QRYS2FOLDERS (Table)
--   QRYSELLIST (Type)
--   QRYSELOBJ (Type)
--   QRYS_SEL (Table)
--   QRYS_SEL_RS4DIMS (Table)
--   QUERYOBJ (Type)
--   RECS2CUBES (Table)
--   RECS_TREE (View)
--   RS4DIM_OBJ (Type)
--   RS4DIM_OBJLIST (Type)
--   RS_CODES4DIMS (Table)
--   RS_CODES4DIMS_ (View)
--   SAVEOBJ (Procedure)
--   SHOW_FUNC_GRP4ATTRS (View)
--   SHOW_GRP_DIMS4ATTRS (View)
--   SQLERRM4USER (Synonym)
--   TREE_FNC (Package)
--   TREE_NODE (Type)
--   TREE_NODES (Type)
--   TSTRINGS250 (Synonym)
--   TYPES_COMP (Table)
--   VALFUNCTIONLIST (Type)
--   VALFUNCTIONOBJ (Type)
--   VALS (Type)
--   COLLECT (Synonym)
--   DBMS_XMLGEN (Synonym)
--   DUAL (Synonym)
--   PLITBLM (Synonym)
--   XMLAGG (Synonym)
--   XMLTYPE (Synonym)
--   XQSEQUENCE (Synonym)
--   DBMS_STANDARD (Package)
--   STANDARD (Package)
--   SYS_IXMLAGG (Function)
--   SYS_NT_COLLECT (Function)
--   XMLTYPE (Type)
--   XQSEQUENCE (Operator)
--
CREATE OR REPLACE PACKAGE BODY OPAL_FRA.Analyzer
AS
  -- PKG_BODY_VERSION: For developers: Please each time when you
  -- increase package number in definition update this constant
  -- to the sane value.
  PKG_BODY_VERSION CONSTANT NUMBER := 2.7; --1st version - the simplest interface:
--                    conditions only of the kind "attr IN group" +
--           list of simple conditions
  language_id LANGUAGES.ID%TYPE := 1;
  default_qry_type CONSTANT PLS_INTEGER := 3;
  default_grp_lev_ordno  CONSTANT PLS_INTEGER := 1;
  del_force CONSTANT PLS_INTEGER := 1;
  err_del_pred CONSTANT PLS_INTEGER := 0;
  err_no_elem CONSTANT PLS_INTEGER := 2;
  err_dup_qry CONSTANT PLS_INTEGER := 10;
  err_notempty_folder CONSTANT PLS_INTEGER := 14;
  err_access_no CONSTANT PLS_INTEGER := 21;
  err_access_ro CONSTANT PLS_INTEGER := 22;
  err_not_yours CONSTANT PLS_INTEGER := 23;
  -- Return = 0 if package version is the same as package body version.
  --        > 0 if package definition is newer then package body
  --        < 0 if package definition is older then package body
  unique_qry_abbr CONSTANT VARCHAR2(30) := 'U_QRYS_ABBR';
  org_id_ qrys.org_id%type; --a grobal variable, only for interface compatibility with Opal 2.

  FUNCTION RtmCheck RETURN NUMBER
  IS
  BEGIN
      RETURN PKG_VERSION - PKG_BODY_VERSION;
  END;

  -- Language support...
  PROCEDURE Lang_ListLanguages(Languages OUT SYS_REFCURSOR)
  IS
  BEGIN
      OPEN Languages FOR
          SELECT   ID, NAME
          FROM     LANGUAGES
          ORDER BY ID;
  END;

  FUNCTION Lang_GetCurrent RETURN LANGUAGES.ID%TYPE
  IS
  BEGIN
      RETURN language_id;
  END;

  PROCEDURE Lang_SetCurrent(Language IN LANGUAGES.ID%TYPE)
  IS
      nId LANGUAGES.ID%TYPE;
  BEGIN
      SELECT ID into nId
      FROM  LANGUAGES
      WHERE ID = Language;

      language_id := Language;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20000, 'Language ID not available: ' || Language);
  END;

  --returns root folder name
  FUNCTION get_root_folder RETURN FOLDERS.scode%TYPE IS
  BEGIN
   RETURN root_folder;
  END;
  --returns root folder ID
  FUNCTION get_root_folder_id RETURN FOLDERS.id%TYPE IS
   folder_id FOLDERS.id%TYPE;
  BEGIN
   SELECT id INTO folder_id FROM FOLDERS WHERE scode=root_folder;
   RETURN folder_id;
  END;
  -- Creates an empty query object.
  FUNCTION CreateEmptyQuery RETURN QueryOBJ
  IS
  BEGIN
      RETURN QueryOBJ(NULL);
  END;

  function is_group_temp(grp_id groups.id%type) return boolean is
   predef groups.predefined%type;
  begin
    select predefined into predef from groups
     where id=grp_id;
    return (predef=tree_fnc.is_temporary);
  end;

  function qry_has_attr(id_ qrys.id%type, ai attrs.id%type) return boolean is
   wrk pls_integer;
  begin
   select count(*) into wrk from qrys_sel where qry_id=id_ and attr_id=ai;
   if wrk is null then
    select count(*) into wrk from (
     select left_attr_id, right_attr_id
      FROM CONDS c, LEAFS4CONDS l
      WHERE c.ID=l.leaf_id(+)
      START WITH c.ID=(select where_id from qrys where id=id_)
      CONNECT BY parent_id=PRIOR ID
     ) where left_attr_id=ai or right_attr_id=ai;
   end if;
   return (wrk>0);
  end;

  procedure ins_fr_status_leaf(pid conds.parent_id%type, id_ qrys.id%type) is
   cid conds.id%type;
  begin
   insert into conds(PARENT_ID, IS_LEAF, ORDNO, DESCR)
    values(pid, 1, 0, 'QF'||id_||'_0') returning id into cid;
   insert into LEAFS4CONDS(LEAF_ID, LEFT_ATTR_ID, OP_SIGN, CONST)
    select cid, id, '=', 'A' from attrs where scode=FR_STATUS_UTILS.FR_STATUS_CODE ;
  end;

  function ins_where4fr_status(pid_ conds.parent_id%type, id_ qrys.id%type) return conds.id%type is
   cid_ conds.id%type;
  begin
   insert into conds(op_sign, DESCR)
    values(constants.ANDOP, 'QM'||id_||'_0') returning id into cid_;
   update conds set parent_id=cid_ where id=pid_;
   update qrys set where_id=cid_ where id=id_;
   return cid_;
  end;

  procedure add_fr_status(id_ qrys.id%type) is
   ai attrs.id%type;
   cid_ conds.id%type;
  begin
   if fr_status_utils.is_fr_status_active=0 then return; end if;
   select id into ai from attrs where scode=FR_STATUS_UTILS.FR_STATUS_CODE;
   if qry_has_attr(id_, ai) then return; end if;
   for c in (select q.where_id, c.op_sign, q.cube_id from qrys q left outer join conds c on (q.where_id=c.id) where q.id=id_) loop
--temporary, till Front End update
    exit when fr_status_utils.is_fr_status_active(c.cube_id)=0;
    if nvl(c.op_sign, ' ')<>constants.ANDOP then
     cid_ := ins_where4fr_status(c.where_id, id_);
    else
     cid_ := c.where_id;
    end if;
    ins_fr_status_leaf(cid_, id_);
   end loop;
  end;


  FUNCTION  GetQueryXml(queryid IN INTEGER) RETURN XMLType
  is
  begin
    return XMLType(GetQuery(queryid));
  end;


  FUNCTION  GetQuery(queryid IN INTEGER) RETURN QueryOBJ
  IS
   ret queryobj := QueryObj('');
   CURSOR get_qry IS
  SELECT qa.basic_id, qa.FUNC_GRP_ID, qa.GRP_ID, qa.dim_lev_id,
           b.abbr basic_attr_code, qa.rsobj,
    Tree_Fnc.get_show(qa.grp_id, qa.dim_lev_id, qa.basic_id, qa.cube_id, qa.noshow)
    attrtype, how
      FROM (
       SELECT NVL(a.parent_id, q.attr_id) basic_id,
      q.ATTR_ID, NULLIF(q.FUNC_GRP_ID, 'GRP') FUNC_GRP_ID,
      q.GRP_ID, q.dim_lev_id,
      q.ordno, q.cube_id, qry_sel_id, q.noshow, max(q.how) over(partition by q.attr_id) how,
             cast(multiset(select rs4dim_obj(q.dim_lev_id, rs.val) from QRYS_SEL_RS4DIMS rs where qry_id=q.qry_id and ordno=q.ordno)
              as rs4dim_objlist) rsobj
        FROM QRYS_SEL q, ATTRS a
     WHERE q.qry_id=queryid AND q.attr_id=a.ID
   ) qa, ATTRS b
   WHERE b.ID=qa.basic_id
   ORDER BY qry_sel_id, attrtype, qa.ordno;
   prev_attr ATTRS.ID%TYPE;
   prev_attrtype CHAR(1) := ' ';
   where_ QRYS.where_id%TYPE;
   isl PLS_INTEGER;
   show_ CHAR(1);
   CURSOR cc IS
 SELECT ID, OP_SIGN, PARENT_ID, GH, ORDNO, is_leaf,
   LEFT_ATTR_ID, COND_OP, RIGHT_ATTR_ID, CONST, GRP_ID,
   LEFT_FUNC_GRP_ID, RIGHT_FUNC_GRP_ID,
   LEFT_FUNC_ROW_ID, RIGHT_FUNC_ROW_ID, lvl,
   CASE WHEN mrk=1 AND bador IS NULL AND parent_op IN (';AND;OR;', ';AND;',';OR;',';') THEN 1 ELSE 0 END mrk
    FROM (
 SELECT c.ID, c.OP_SIGN, c.PARENT_ID, c.GH, c.ORDNO, NVL(c.is_leaf, 0) is_leaf,
   l.LEFT_ATTR_ID, l.OP_SIGN cond_op, l.RIGHT_ATTR_ID, l.CONST, l.GRP_ID,
   l.LEFT_FUNC_GRP_ID, l.RIGHT_FUNC_GRP_ID,
   l.LEFT_FUNC_ROW_ID, l.RIGHT_FUNC_ROW_ID, LEVEL lvl,
   CASE WHEN (l.grp_id IS NULL OR l.left_attr_id IS NULL) OR LEVEL>3 THEN 0 ELSE 1 END mrk,
   SYS_CONNECT_BY_PATH(c.op_sign, ';') parent_op,
   (SELECT MAX(1) FROM CONDS cc, LEAFS4CONDS ll WHERE cc.ID=ll.leaf_id(+) AND ID<>c.ID AND
     Constants.OROP=(SELECT MAX(op_sign) FROM CONDS WHERE ID=c.parent_id) AND
     parent_id=c.parent_id AND (left_attr_id IS NULL OR left_attr_id<>l.left_attr_id)) bador -- and
  FROM CONDS c, LEAFS4CONDS l
  WHERE c.ID=l.leaf_id(+)
     START WITH c.ID=where_
           CONNECT BY parent_id=PRIOR ID
           ORDER SIBLINGS BY ordno
      );
   TYPE condtype IS RECORD( ID CONDS.ID%TYPE, OP_SIGN CONDS.OP_SIGN%TYPE,
   PARENT_ID CONDS.PARENT_ID%TYPE, GH CONDS.GH%TYPE, ORDNO CONDS.ORDNO%TYPE, is_leaf CONDS.is_leaf%TYPE,
   LEFT_ATTR_ID LEAFS4CONDS.LEFT_ATTR_ID%TYPE, comp_op LEAFS4CONDS.OP_SIGN%TYPE,
   RIGHT_ATTR_ID LEAFS4CONDS.RIGHT_ATTR_ID%TYPE, CONST LEAFS4CONDS.CONST%TYPE,
   GRP_ID LEAFS4CONDS.GRP_ID%TYPE, LEFT_FUNC_GRP_ID LEAFS4CONDS.LEFT_FUNC_GRP_ID%TYPE,
   RIGHT_FUNC_GRP_ID LEAFS4CONDS.RIGHT_FUNC_GRP_ID%TYPE,
   LEFT_FUNC_ROW_ID LEAFS4CONDS.LEFT_FUNC_ROW_ID%TYPE,
   RIGHT_FUNC_ROW_ID LEAFS4CONDS.RIGHT_FUNC_ROW_ID%TYPE, lvl PLS_INTEGER, mrk PLS_INTEGER);
 TYPE condstype IS TABLE OF condtype;
 condstab condstype;
    TYPE numtab IS TABLE OF PLS_INTEGER INDEX BY BINARY_INTEGER;
 paridsno numtab;
 idsrows numtab;
 n PLS_INTEGER;
 nn PLS_INTEGER;
 pid CONDS.parent_id%TYPE;
 pin PLS_INTEGER;
 is_marked BOOLEAN := TRUE;
 pid_changed BOOLEAN;
 pil PLS_INTEGER;
 mrk_is_found BOOLEAN;
 cru qrys.cr_term%type;

  FUNCTION add2sel(basic_id ATTRS.ID%TYPE, basic_attr_code VARCHAR2,
    attrtype ATTRS2CUBES.show%TYPE, flags pls_integer := 0) --call withowt flags is for attrs, got only from a filter
   RETURN PLS_INTEGER IS
  BEGIN
   ret.selection.EXTEND;
   isl := ret.selection.LAST;
   ret.selection(isl) := qryselobj;
   ret.selection(isl).attrid := basic_id;
   ret.selection(isl).attrcode := basic_attr_code;
   ret.selection(isl).attrtype := attrtype;
   ret.selection(isl).flags := flags;
   RETURN isl;
  END;

  FUNCTION is_dimfilter(nc PLS_INTEGER, condstab IN OUT NOCOPY condstype,
   ret IN OUT NOCOPY queryobj) RETURN BOOLEAN IS
   aid ATTRS.ID%TYPE;
   nr PLS_INTEGER;
   not_added BOOLEAN := TRUE;

    PROCEDURE add2dimfilter(nr PLS_INTEGER, grp_id PLS_INTEGER) IS
    BEGIN
     IF grp_id IS NULL THEN RETURN; END IF;
      ret.selection(nr).dimfilter.EXTEND;
      ret.selection(nr).dimfilter(ret.selection(nr).dimfilter.LAST)
       := dimfilterobj(grp_id);
    END;

    FUNCTION add2sel_from_filt(nc PLS_INTEGER) RETURN PLS_INTEGER IS
     nr PLS_INTEGER;
     basic_id ATTRS.ID%TYPE;
     basic_attr_code VARCHAR2(100);
     BEGIN
      SELECT NVL(parent_id, ID), a.abbr
       INTO basic_id, basic_attr_code
       FROM ATTRS a
       WHERE ID=condstab(nc).left_attr_id;
       nr := add2sel(basic_id, basic_attr_code, Constants.show_key);
       add2dimfilter(nr,condstab(nc).grp_id);
       RETURN nr;
      EXCEPTION
      WHEN NO_DATA_FOUND THEN RETURN NULL;
     END;

  BEGIN
   IF ret.selection IS NULL THEN RETURN FALSE; END IF;
   IF condstab IS NULL THEN RETURN FALSE; END IF;
   IF NOT condstab.EXISTS(nc) THEN RETURN FALSE; END IF;
   IF condstab(nc).mrk<>1 THEN RETURN FALSE; END IF;
   IF condstab(nc).grp_id IS NOT NULL THEN
    nr := ret.selection.FIRST;
    WHILE (nr IS NOT NULL) LOOP
     IF ret.selection(nr).attrid=condstab(nc).left_attr_id
       AND ret.selection(nr).attrtype = Constants.show_key THEN
      IF condstab(nc).grp_id IS NOT NULL THEN
       if ret.selection(nr).flags>0 and is_group_temp(condstab(nc).grp_id) then
        for h in (select id from grp_tree where parent_id=condstab(nc).grp_id) loop
         add2dimfilter(nr, h.id);
        end loop;
       else
        add2dimfilter(nr, condstab(nc).grp_id);
       end if;
      END IF;
      not_added:= FALSE;
     END IF;
     nr := ret.selection.NEXT(nr);
    END LOOP;
   ELSE
    RETURN FALSE;
   END IF;
   IF not_added THEN
    nr := add2sel_from_filt(nc);
   END IF;
   IF condstab(nc).grp_id IS NOT NULL THEN condstab.DELETE(nc); END IF;
   RETURN TRUE;
  END;

  BEGIN
  BEGIN
   SELECT abbr, short, CUBE_ID, where_id, is_private, cr_term
    INTO ret.NAME, ret.description, ret.cubeid, where_, ret.is_private, cru
    FROM QRYS WHERE ID=queryid;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
   RETURN ret;
  END;
  if cru<>cos and ret.is_private=is_private_no and is_qrys_admin=0 then
   errors.raise_err(err_access_no, Constants.qry_task, cos, '', '', TRUE, TRUE);
  end if;
  FOR g IN get_qry LOOP
   IF prev_attr IS NULL OR NOT (g.basic_id=prev_attr AND g.attrtype=prev_attrtype) THEN
    prev_attr := g.basic_id;
    prev_attrtype := g.attrtype;
    isl := add2sel(g.basic_id, g.basic_attr_code, g.attrtype, g.how);
   END IF;
   IF g.grp_id IS NULL THEN
    IF g.dim_lev_id IS NOT NULL THEN
     ret.selection(isl).dimlevels.EXTEND;
     ret.selection(isl).dimlevels(ret.selection(isl).dimlevels.LAST)
      := dimlevelobj(g.dim_lev_id);
     if g.rsobj.last is not null then
      for jj in 1..g.rsobj.last loop
       ret.selection(isl).rs4dimlevels.EXTEND;
       ret.selection(isl).rs4dimlevels(ret.selection(isl).rs4dimlevels.LAST) := g.rsobj(jj);
      end loop;
     end if;
    END IF;
   ELSE
    if not is_group_temp(g.grp_id) then
     ret.selection(isl).grplevels.EXTEND;
     ret.selection(isl).grplevels(ret.selection(isl).grplevels.LAST)
      := dimlevelobj(g.grp_id);
    end if;
   END IF;
   IF g.func_grp_id IS NOT NULL THEN
    ret.selection(isl).vallevels.EXTEND;
    ret.selection(isl).vallevels(ret.selection(isl).vallevels.LAST)
     := valfunctionobj(g.func_grp_id);
   END IF;
  END LOOP;
  IF where_ IS NOT NULL THEN
   OPEN cc;
   FETCH cc BULK COLLECT INTO condstab;
   CLOSE cc;
   IF condstab IS NOT NULL THEN
    WHILE is_marked LOOP
     n := condstab.FIRST;
     is_marked := FALSE;
     pid_changed := FALSE;
     pin := NULL;
     mrk_is_found := FALSE;
     paridsno.DELETE;
     LOOP
      IF n IS NOT NULL THEN
       idsrows(condstab(n).ID) := n;
       IF NOT mrk_is_found THEN
        IF condstab(n).mrk=1 THEN
         mrk_is_found := TRUE;
         pid_changed := FALSE;
         pil := condstab(n).lvl;
         pin := condstab.PRIOR(n);
        END IF;
        pid := condstab(n).parent_id;
        IF pid IS NOT NULL THEN
         IF paridsno.EXISTS(pid) THEN
          mrk_is_found := (paridsno(pid)=1);
         END IF;
         paridsno(pid):=CASE WHEN condstab(n).mrk=1 AND mrk_is_found THEN 1 ELSE -1 END;
        END IF;
        GOTO ANEXT;
       END IF;
     IF mrk_is_found THEN
      IF condstab(n).lvl>pil THEN GOTO ANEXT; END IF;
      IF condstab(n).lvl=pil THEN
       IF NVL(condstab(n).mrk,0)<>1 THEN
        mrk_is_found := FALSE;
       END IF;
       GOTO ANEXT;
      END IF;
      pid_changed := TRUE;
     END IF;
    ELSE
     pid_changed := TRUE;
    END IF;
    IF pid_changed THEN
     IF pin IS NOT NULL AND mrk_is_found AND condstab(pin).mrk<>1 THEN
      IF condstab(pin).is_leaf<>1 OR condstab(pin).grp_id IS NOT NULL THEN --!!!Don't mark leaf nodes, if they are not dimfilter nodes!
       condstab(pin).mrk := 1;
       is_marked := TRUE;
      END IF;
     END IF;
     EXIT WHEN n IS NULL;
     mrk_is_found := FALSE;
     GOTO AEND;
    END IF;
<<ANEXT>>
    n := condstab.NEXT(n);
<<AEND>> NULL;
   END LOOP;
  END LOOP;
  n := condstab.FIRST;
  paridsno.DELETE;
  WHILE n IS NOT NULL LOOP
   nn := condstab.NEXT(n);
   IF condstab(n).mrk = 1 THEN
    mrk_is_found := is_dimfilter(n, condstab, ret);
   ELSE
    pid := condstab(n).parent_id;
    idsrows(condstab(n).ID) := n;
    IF pid IS NOT NULL THEN
     IF NOT paridsno.EXISTS(pid) THEN paridsno(pid) := 0; END IF;
        paridsno(pid) := paridsno(pid) + 1;
    END IF;
   END IF;
   n := nn;
  END LOOP;
  n := condstab.FIRST;
  WHILE n IS NOT NULL LOOP
   nn := condstab.NEXT(n);
   pid := condstab(n).parent_id;
   IF condstab(n).is_leaf<>1 THEN
    IF NOT paridsno.EXISTS(condstab(n).ID) THEN
      condstab.DELETE(idsrows(condstab(n).ID));
    ELSIF pid IS NOT NULL AND paridsno(pid)<=1 THEN
     pin := idsrows(pid);
     condstab(n).parent_id := condstab(pin).parent_id;
     condstab.DELETE(pin);
   END IF;
   END IF;
   n := nn;
  END LOOP;
  n := condstab.FIRST;
  nn := 0;
  if n is not null then pid := condstab(n).ID; end if;
  WHILE n IS NOT NULL LOOP
   IF condstab(n).parent_id=pid THEN
    pin := n; nn := nn + 1;
   END IF;
   n := condstab.NEXT(n);
  END LOOP;
  if nn<2 and condstab.first is not null then
   if pin is not null then condstab(pin).parent_id := null; end if;
   condstab.delete(condstab.first);
  end if;
  n := condstab.FIRST;
  IF n IS NOT NULL THEN condstab(n).parent_id := NULL; END IF;
  WHILE n IS NOT NULL LOOP
   ret.filterconds.EXTEND;
   ret.filterconds(ret.filterconds.LAST)
      := condexprobj(condstab(n).ID, condstab(n).op_sign, condstab(n).parent_id,
           CASE WHEN condstab(n).is_leaf=1 THEN condstab(n).ID END);
   IF condstab(n).is_leaf=1 THEN
    ret.filterelems.EXTEND;
    SELECT MAX(show) --searching show from cube, where not basic attribute can be missing
     INTO show_ FROM ATTRS2CUBES, ATTRS
     WHERE condstab(n).left_attr_id IN (ID, parent_id) AND
      (attr_id=ID OR attr_id=parent_id) AND cube_id=ret.cubeid;
    ret.filterelems(ret.filterelems.LAST) :=
      condelemobj(condstab(n).ID, condstab(n).left_attr_id, condstab(n).comp_op,
    condstab(n).const, show_);
   END IF;
   n := condstab.NEXT(n);
  END LOOP;
 END IF;
END IF;
 SELECT SETTINGS, LAYOUT INTO ret.SETTINGS, ret.layout FROM QRYS WHERE ID=queryid;
 RETURN ret;
END;

  PROCEDURE delqrydetails(qry_id_ QRYS.ID%TYPE) IS
  BEGIN
--   DELETE QRYS_ORD WHERE qry_id=qry_id_;
   DELETE QRYS_SEL WHERE qry_id=qry_id_;
END;

  PROCEDURE delleafs4conds(cond_id_ CONDS.ID%TYPE, qry_id_ QRYS.ID%TYPE) IS
  BEGIN
   DELETE LEAFS4CONDS l WHERE leaf_id IN
    (SELECT ID FROM CONDS START WITH ID=cond_id_ CONNECT BY PRIOR ID=parent_id)
      AND NOT EXISTS(SELECT ID FROM CONDS WHERE ID=l.leaf_id START WITH ID<>cond_id_
      AND parent_id IS NULL CONNECT BY PRIOR ID=parent_id);
  END;

  PROCEDURE delconds(cond_id_ CONDS.ID%TYPE, qry_id_ QRYS.ID%TYPE) IS
  BEGIN
   DELETE CONDS WHERE ID=cond_id_ AND NOT EXISTS(SELECT 1 FROM QRYS WHERE
    ID<>qry_id_ AND cond_id_ IN (where_id, having_id));
  END;

  FUNCTION DelQuery_int(queryid IN QRYS.id%TYPE, is_full BOOLEAN := TRUE)
    RETURN PLS_INTEGER IS
   id_ QRYS.ID%TYPE := queryid;
   where_id_ QRYS.where_id%TYPE;
   hav_id_ QRYS.having_id%TYPE;
   pd QRYS.predefined%TYPE;
   grps Groups_Fnc.nums;
   CURSOR gg IS
    SELECT q.grp_id FROM QRYS_SEL q, GROUPS g WHERE q.qry_id=id_
      AND q.grp_id=g.ID AND g.predefined = Tree_Fnc.is_temporary
   AND grp_id>=0
  FOR UPDATE OF q.grp_id, g.ID NOWAIT;
   n PLS_INTEGER;
  BEGIN
  BEGIN
   SELECT where_id, having_id, predefined INTO where_id_, hav_id_, pd
    FROM QRYS WHERE ID=id_ FOR UPDATE NOWAIT;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
   RETURN 1;
  END;
  IF pd=Tree_Fnc.is_predefined THEN
   errors.RAISE_ERR(err_del_pred, Constants.qry_task);
  END IF;
 -- IF is_full THEN
   FOR g IN gg LOOP --now temp groups are in only one qry
    grps(NVL(grps.LAST, 0)+1) := g.grp_id;
   END LOOP;
--  END IF;
  delqrydetails(id_);
  delleafs4conds(where_id_, id_);
  delleafs4conds(hav_id_, id_);
  IF is_full THEN
   DELETE QRYS WHERE ID=id_;
   IF grps.FIRST IS NOT NULL THEN
    FOR i IN 1..grps.count LOOP --this must be replaced by call to groups_fnc
     BEGIN
     SELECT 1 INTO n FROM GROUPS g --the most simple case, supported at this version
      WHERE ID=grps(i) AND NOT EXISTS(SELECT 1 FROM QRYS_SEL WHERE
        grp_id=g.ID) AND NOT EXISTS(SELECT 1 FROM LEAFS4CONDS WHERE grps(i)=grp_id)
      AND NOT EXISTS(SELECT 1 FROM GRP_TREE WHERE ID=grps(i)
        AND nullif(parent_id, tree_fnc.root_not_d) IS NOT NULL);
     EXCEPTION
     WHEN NO_DATA_FOUND THEN grps.DELETE(i);
     END;
    END LOOP;
   END IF;
  END IF;
  IF grps.FIRST IS NOT NULL THEN
   FOR i IN grps.FIRST..grps.LAST LOOP
   Groups_Fnc.delete_group(grps(i));
   END LOOP;
  END IF;
  UPDATE QRYS SET where_id=NULL, having_id=NULL
   WHERE ID=id_;
  delconds(where_id_, id_);
  delconds(hav_id_, id_);
  RETURN 0;
 END;
----------------------------------------------------------------------------------------------
function create_temp_filter_group(qry_id qrys.id%type, sel qryselobj) return groups.id%type is
 dgo DIM_GRP_OBJ := dim_grp_obj('');
 grp_id_ groups.id%type;
begin
 dgo.nodes := tree_nodes();
 dgo.predefined := TREE_FNC.IS_TEMPORARY;
 select a.abbr, ATTR_TYPE into dgo.name, dgo.type_id --name for this group must be recalculated
  from attrs a where id=sel.attrid;
 dgo.description := dgo.name||' flagged filter selection';
 dgo.name := dgo.name||'!'||qry_id;
 for i in 1..sel.dimfilter.count loop
  dgo.nodes.extend;
  dgo.nodes(dgo.nodes.last) := tree_node(sel.dimfilter(i).groupid, null, i, null, null, null);
 end loop;
 grp_id_ := groups_fnc.add_dim_group(dgo);
 return grp_id_;
end;
----------------------------------------------------------------------------------------------
  FUNCTION  AddQuery_int(querydata IN OUT NOCOPY QueryOBJ, qry_id_ QRYS.ID%TYPE := NULL,
   tmp QRYS.tmp%TYPE := NULL, queryid IN INTEGER := null) RETURN PLS_INTEGER
  IS
   id_ QRYS.ID%TYPE := qry_id_;
   ordno_ QRYS_SEL.ordno%TYPE := 0;
   ordno_attr QRYS_SEL.ordno%TYPE;
   attr_id_ ATTRS.ID%TYPE;
   basic_attr_id ATTRS.ID%TYPE;
   cube_id_ QRYS.cube_id%TYPE;
   dim_lev_id_ ATTRS.dim_lev_id%TYPE;
   dim_lev_id_virtual ATTRS.dim_lev_id%TYPE;
   condno PLS_INTEGER;
   condno_grp PLS_INTEGER := 0;
   cond_id_ CONDS.ID%TYPE;
   newconds Groups_Fnc.nums;
   pid PLS_INTEGER;
   cid PLS_INTEGER;
   lid PLS_INTEGER;
   lid_found BOOLEAN;
   common_node_id CONDS.ID%TYPE;
   root_node_id CONDS.ID%TYPE;
   qry_name QRYS.short%TYPE;
   qry_abbr QRYS.abbr%TYPE;
   n PLS_INTEGER;
   common_or_id CONDS.ID%TYPE;
   qry_sel_id_ PLS_INTEGER := 0;
   tmp_qry_no qrys.version_no%type;
   tmp_qry_id_ qrys.tmp_qry_id%type;
   tmpvals vals := vals();
   flags qrys_sel.how%type;
   grp_id_ groups.id%type;
   wrk pls_integer;
   grp4flags boolean;
   dim_lev4flags dim_levels.id%type;
   tmpv pls_integer;
   max_qry_abbr_len constant pls_integer := 100;
   max_qry_short_len constant pls_integer := 1000;
----------------------------------------------------------------------------------------------------
  PROCEDURE ins_qrys_sel(attr_id_ QRYS_SEL.grp_id%TYPE,
   func_grp_id_ QRYS_SEL.func_grp_id%TYPE, grp_id_ QRYS_SEL.grp_id%TYPE,
   dim_lev_id_ QRYS_SEL.dim_lev_id%TYPE := NULL,
   noshow_ QRYS_SEL.noshow%TYPE := NULL,
   grp_lev_ordno_ QRYS_SEL.grp_lev_ordno%TYPE := NULL, rs4dim_ vals:= vals(), flags_ qrys_sel.how%type:=0) IS
  BEGIN
   ordno_ := ordno_+1;
   ordno_attr := ordno_attr + 1;
   INSERT INTO QRYS_SEL(QRY_ID,
     ATTR_ID, FUNC_GRP_ID, GRP_ID,
     GRP_LEV_ORDNO, ORDNO, CUBE_ID, dim_lev_id, qry_sel_id, noshow, how)
    VALUES(id_, attr_id_, func_grp_id_, grp_id_,
      grp_lev_ordno_, ordno_, cube_id_, dim_lev_id_, qry_sel_id_, noshow_, flags_); /*!!!!*/
    INSERT INTO QRYS_SEL_RS4DIMS(QRY_ID, ORDNO, VAL)
      select id_, ordno_, column_value from table(rs4dim_);
  EXCEPTION
  WHEN DUP_VAL_ON_INDEX THEN
   RAISE_APPLICATION_ERROR(-20100, 'Qry='||id_||', ordno='||ordno_||', attr_id='||
     attr_id_||':'||SQLERRM, TRUE);
  END;
----------------------------------------------------------------------------------------------------
  procedure process_flags(qry_id qrys.id%type, sel in out nocopy qryselobj, grp_id_ IN OUT groups.id%type,
    cn in out pls_integer, dim_lev4flags OUT dim_levels.id%type) is
   n pls_integer := 0;
  begin
   if nvl(sel.flags, 0)=0 then return; end if;
   if bitand(sel.flags, constants.how_repo_flag)=0 then
    raise_application_error(-20103, 'Invalid selection for flagged group: '||sel.flags, true); --raise_err!!!
    errors.raise_err(19, CONSTANTS.QRY_TASK, sel.flags);
   end if;
   cn := 0;
   if sel.dimfilter is not null then
    cn := sel.dimfilter.count;
   end if;
   if cn=0 then
    errors.raise_err(18, CONSTANTS.QRY_TASK);
   end if;
   if cn=1 then
    if bitand(sel.flags, constants.how_rest_flag)>0 then
     errors.raise_err(16, Constants.qry_task, sel.attrcode, '', '', TRUE, TRUE);
    end if;
    grp_id_ := sel.dimfilter(cn).groupid;
    if grp_id_<0 then
     if sel.dimlevels is not null then
      for j in reverse 1..sel.dimlevels.count loop
       select count(*) into n from dim_levels d1, dim_levels d2, groups g
        where g.id=grp_id_ and g.dim_id=d2.dim_id and G.TYPE_ID = d2.id and d2.dim_id=d1.dim_id and
          d1.id=sel.dimlevels(j).attrid and d1.ordno>d2.ordno;
       if n>0 then
        dim_lev4flags := sel.dimlevels(j).attrid;
        exit;
       end if;
      end loop;
     end if;
     if n=0 then
      if bitand(sel.flags, constants.how_rest_flag)>0 then
       errors.raise_err(17, CONSTANTS.QRY_TASK);
      else
       select dim_lev_id into dim_lev4flags from grp_d where grp_id=grp_id_;
      end if;
     end if;
--     grp_id_ := null; --do not use this group for a level anymore, use dimension level
    end if;
   else
    grp_id_ := create_temp_filter_group(qry_id, sel);
    sel.dimfilter.delete(2, cn);
    sel.dimfilter(1).groupid := grp_id_;
   end if;
   select count(*) into cn from table(sel.grplevels) where attrid=grp_id_;
/*   if cn=0 then
    if sel.grplevels is null then
     sel.grplevels := dimlevellist();
 --  select dimlevelobj(t.attrid) bulk collect into sel.grplevels from table(sel.grplevels) t;
    end if;
  end if;*/
 end;
----------------------------------------------------------------------------------------------------

  BEGIN
--  WRITE_LOG.LOG_MESSAGE(qry_abbr||'='||id_);
   Saveobj(querydata);
   cube_id_ := querydata.cubeid;
   qry_name := SUBSTR(querydata.NAME, 1, max_qry_short_len); --whe now can't more
   qry_abbr := RTRIM(SUBSTR(qry_name, 1, max_qry_abbr_len));
   n := LENGTH(querydata.NAME);
   IF n>max_qry_abbr_len THEN
    n := INSTR(qry_abbr, ' ', -1);
    IF n>5 THEN --magic value
     qry_abbr := SUBSTR(qry_abbr, 1, n-1);
    END IF;
   END IF;
   IF tmp IS NOT NULL THEN
    for c in (SELECT version_no, id, org_id FROM QRYS WHERE abbr=qry_abbr and queryid is null
               union
              SELECT version_no, id, org_id FROM QRYS WHERE org_id=queryid or id=queryid
      order by 1 desc nulls last, id desc) loop
     tmp_qry_no := nvl(c.version_no, 0)+1;
     tmp_qry_id_ := c.id;
     org_id_ := nvl(org_id_, c.org_id);
     exit;
    end loop;
   ELSE --cleaning measure
    delquery_tmp(qry_id_);
    if qry_id_ is null then
     for c in (select tmp, tmp_qry_id, id, count(*) over() co from QRYS WHERE abbr=qry_abbr) loop
      if c.tmp is not null and c.tmp_qry_id is null and c.co=1 then --not saved, but executed query
       delquery(c.id);
      end if;
     end loop;
    end if;
   END IF;
--app_log.log_messageex('DEL', tmp||':'||qry_id_||':'||id_||':'||queryid||':'||tmp_qry_id_||':'||org_id_ ||':'||tmp_qry_no||':'||qry_abbr||'!');
   n := 0;
   BEGIN
   IF id_ IS NOT NULL THEN --in all cases new query is written, if qry_id doesn't exist
    UPDATE QRYS SET
      cube_id = cube_id_, abbr=querydata.NAME, short=querydata.description,
      SETTINGS = querydata.SETTINGS, layout = querydata.layout,
      tmp = CASE WHEN tmp IS NOT NULL THEN addquery_int.tmp END,
      version_no=tmp_qry_no, is_private=querydata.is_private
     WHERE ID=id_;
    n := SQL%rowcount;
   END IF;
   IF n=0 THEN
    INSERT INTO QRYS(ID, QRY_TYPE, CUBE_ID, abbr, SHORT, SETTINGS, layout, tmp, version_no, is_private, tmp_qry_id, org_id)
     VALUES(id_, default_qry_type, cube_id_, qry_abbr, querydata.description,
    querydata.SETTINGS, querydata.layout, addquery_int.tmp, tmp_qry_no, nvl(querydata.is_private, is_private_pu), tmp_qry_id_, org_id_)
    returning ID INTO id_;
--    if tmp is null then
--     update qrys set abbr=id_ where id=id_;
--    end if;
   END IF;
   EXCEPTION
   WHEN DUP_VAL_ON_INDEX THEN
     errors.raise_err(err_dup_qry, Constants.qry_task, qry_abbr, '', '', TRUE, FALSE);
   END;
   IF querydata.selection IS NOT NULL THEN
    FOR i IN 1..querydata.selection.count LOOP
     IF querydata.selection(i).dimfilter IS NOT NULL THEN
      IF querydata.selection(i).dimfilter.COUNT>0 THEN
       condno_grp := condno_grp+1;
      END IF;
     END IF;
    END LOOP;
    IF querydata.filterconds IS NOT NULL THEN
     condno := querydata.filterconds.COUNT;
    ELSE
     condno := 0;
    END IF;
    IF condno_grp>1 OR condno_grp>0 AND condno>0 THEN
     INSERT INTO CONDS(OP_SIGN, DESCR) VALUES (Constants.ANDOP, 'QM'||id_)
      RETURNING ID INTO common_node_id;
    END IF;
    FOR i IN 1..querydata.selection.count LOOP
     IF querydata.selection.EXISTS(i) THEN
      ordno_attr := 0;
      basic_attr_id := querydata.selection(i).attrid;
      attr_id_ := basic_attr_id;
      dim_lev_id_ := NULL;
      qry_sel_id_ := qry_sel_id_ + 1;
      flags := nvl(querydata.selection(i).flags, 0);
      process_flags(id_, querydata.selection(i), grp_id_, wrk, dim_lev4flags);
      if flags>0 and wrk=0 and grp_id_ is not null and dim_lev4flags is null then --something strange with parameters transfer
       if querydata.selection(i).grplevels is null then
        querydata.selection(i).grplevels := dimlevellist(dimlevelobj(1));
       else
 --    if not querydata.selection(i).grplevels.count=1 and querydata.selection(i).grplevels(1) is null then
        querydata.selection(i).grplevels.extend;
        tmpv := querydata.selection(i).grplevels.last;
        querydata.selection(i).grplevels(tmpv) := DimLevelObj(1);
       end if;
       tmpv := querydata.selection(i).grplevels.last;
       querydata.selection(i).grplevels(tmpv).attrid := grp_id_;
      end if;
/*      if querydata.selection(i).grplevels is not null then
      if querydata.selection(i).grplevels.count>0 then
       WRITE_LOG.LOG_MESSAGE('after grp'||grp_id_);
       WRITE_LOG.LOG_MESSAGE('after obj'||querydata.selection(i).grplevels(1).attrid);
      end if;
      end if;*/
      IF querydata.selection(i).dimlevels IS NOT NULL THEN
       FOR ii IN 1..querydata.selection(i).dimlevels.count LOOP
        dim_lev_id_ := querydata.selection(i).dimlevels(ii).attrid;
        select rs_code bulk collect INTO tmpvals
         from (select * from table(querydata.selection(i).rs4dimlevels) where dim_lev_id=dim_lev_id_);
       ins_qrys_sel(attr_id_, NULL, case when dim_lev_id_=dim_lev4flags then grp_id_ end, dim_lev_id_, grp_lev_ordno_=>case when dim_lev_id_=dim_lev4flags then 1 end,
        rs4dim_=>tmpvals, flags_=>case when dim_lev_id_=dim_lev4flags then flags else 0 end);
       END LOOP;
      END IF;
      IF querydata.selection(i).grplevels IS NOT NULL THEN
       FOR ii IN 1..querydata.selection(i).grplevels.count LOOP
--       WRITE_LOG.LOG_MESSAGE('cycle obj'||querydata.selection(i).grplevels(ii).attrid);
        grp4flags := false;
        if flags>0 and querydata.selection(i).dimfilter.COUNT>0 then
         grp4flags := (querydata.selection(i).grplevels(ii).attrid=querydata.selection(i).dimfilter(1).groupid);
        end if;
        ins_qrys_sel(basic_attr_id, NULL,
          querydata.selection(i).grplevels(ii).attrid, NULL, NULL, default_grp_lev_ordno, flags_=>
            case when grp4flags then flags else 0 end);
       END LOOP;
      END IF;
      IF querydata.selection(i).vallevels IS NOT NULL THEN
        FOR ii IN 1..querydata.selection(i).vallevels.count LOOP
         IF querydata.selection(i).vallevels(ii).fnctid<>'GRP' THEN
             ins_qrys_sel(basic_attr_id, querydata.selection(i).vallevels(ii).fnctid, NULL/*, flags_=>flags*/);
         END IF;
        END LOOP;
      END IF;
      IF querydata.selection(i).dimfilter IS NOT NULL THEN
       IF querydata.selection(i).dimfilter.COUNT>0 THEN
        common_or_id := common_node_id;
        IF querydata.selection(i).dimfilter.COUNT>1 THEN
         INSERT INTO CONDS(ORDNO, OP_SIGN, DESCR, parent_id)
          VALUES(i, Constants.OROP, 'QF'||id_||'_'||i, common_node_id)
          RETURNING ID INTO common_or_id;
        END IF;
        FOR ii IN 1..querydata.selection(i).dimfilter.count LOOP
         IF querydata.selection(i).dimfilter.EXISTS(ii) THEN
          INSERT INTO CONDS(IS_LEAF, ORDNO, DESCR, parent_id)
           VALUES(1, ii, 'QF'||id_||'_'||i||'_'||ii, common_or_id)
           RETURNING ID INTO cond_id_;
          INSERT INTO LEAFS4CONDS(LEAF_ID, LEFT_ATTR_ID, OP_SIGN, GRP_ID)
           VALUES(cond_id_, basic_attr_id, Constants.INOP,
            querydata.selection(i).dimfilter(ii).groupid);
            root_node_id := NVL(common_or_id, cond_id_);
         END IF;
        END LOOP;
       END IF;
      END IF;
      IF ordno_attr=0 THEN --keys without dim_level not included to select list
       ins_qrys_sel(attr_id_, NULL, NULL, NULL,
         CASE WHEN querydata.selection(i).attrtype=Constants.show_key THEN 1 END, flags_=>flags);
      END IF;
     END IF;
    END LOOP;
    IF condno>0 THEN
     FOR ii IN 1..querydata.filterconds.count LOOP
      IF querydata.filterconds.EXISTS(ii) THEN
       cid := querydata.filterconds(ii).ID;
       lid := NULLIF(querydata.filterconds(ii).elemid, -1);
       pid := NULLIF(querydata.filterconds(ii).parentid, -1);
       INSERT INTO CONDS(IS_LEAF, ORDNO, DESCR, OP_SIGN, parent_id)
        VALUES(nvl2(lid, 1, TO_NUMBER(NULL)), ii, 'QC'||id_||'_'||ii, querydata.filterconds(ii).optype,
          nvl2(pid, NULL, common_node_id))
        RETURNING ID INTO cond_id_;
       IF pid IS NULL THEN root_node_id := cond_id_; END IF;
          newconds(cid) := cond_id_;
       IF lid IS NOT NULL THEN
        lid_found := FALSE;
        IF querydata.filterelems.FIRST IS NOT NULL THEN
         FOR jj IN querydata.filterelems.FIRST..querydata.filterelems.LAST LOOP
          IF querydata.filterelems(jj).ID = lid THEN
           lid_found := TRUE;
           INSERT INTO LEAFS4CONDS(LEAF_ID, LEFT_ATTR_ID, OP_SIGN, const)
            VALUES(cond_id_, querydata.filterelems(jj).attr_id,
              querydata.filterelems(jj).oper, querydata.filterelems(jj).VALUE);
           EXIT;
          END IF;
         END LOOP;
        END IF;
        IF NOT lid_found THEN
         errors.raise_err(err_no_elem, Constants.qry_task, lid, cid, '', TRUE, FALSE);
        END IF;
       END IF;
      END IF;
     END LOOP;
     FOR ii IN 1..querydata.filterconds.count LOOP
      IF querydata.filterconds.EXISTS(ii) THEN
       pid := querydata.filterconds(ii).parentid;
       IF pid IS NOT NULL THEN
        IF newconds.EXISTS(pid) THEN
         UPDATE CONDS SET parent_id=newconds(pid)
          WHERE ID=newconds(querydata.filterconds(ii).ID);
     -- else
        --     errors.raise_err(1, constants.qry_task, pid, querydata.filterconds(ii).id, '', true, false);
        END IF;
       END IF;
      END IF;
     END LOOP;
    END IF;
    UPDATE QRYS SET where_id=NVL(common_node_id, root_node_id) WHERE ID=id_;
   END IF;
--   add_fr_status(id_); --Now it is Front End responsibility!!!!!!!!
   COMMIT;
   data_service.qry2hist(querydata, id_);
   RETURN id_;
  END;

  FUNCTION  AddQuery(querydata IN QueryOBJ, tmp QRYS.tmp%TYPE := NULL, queryid IN INTEGER := null) RETURN INTEGER IS
   qry_id QRYS.id%TYPE;
   querydata_ QueryOBJ := querydata;
  BEGIN
   IF querydata IS NULL THEN
       RAISE_APPLICATION_ERROR(-20000, 'Query data cannot be null');
   END IF;
   org_id_ := null;
   qry_id := addquery_int(querydata_, NULL, tmp, queryid);
   add_qry2folder(qry_id);
   RETURN qry_id;
  END;
  function XML2QueryOBJ(querydata XMLType) return QueryOBJ is
    querydata_ QueryOBJ;
    x xmltype;
  BEGIN
--app_log.log_messageex2('QRY', 'querydata', userdata=>querydata.getclobval());
   querydata.toObject(querydata_);
   select extract(querydata, 'QUERYOBJ/LAYOUT/text()') into x from dual;
  if x is not null then
--app_log.log_messageex2('QRY', 'layout', userdata=>x.getclobval());
    querydata_.layout := dbms_xmlgen.convert(x.getclobval(), dbms_xmlgen.ENTITY_DECODE);
--app_log.log_messageex2('QRY', 'querydata_.layout', userdata=>querydata_.layout);
   end if;
   return querydata_;
  end;
  FUNCTION  AddQueryXml(querydata IN XMLType, tmp QRYS.tmp%TYPE := NULL, queryid IN INTEGER := null) RETURN INTEGER IS
  querydata_ QueryOBJ := XML2QueryOBJ(querydata);
  BEGIN
--        querydata.toObject(querydata_);
        return AddQuery(querydata_, tmp, queryid);
  END;

 PROCEDURE DelQuery(queryid IN INTEGER)
  IS
  n PLS_INTEGER;
  cursor cc is
  select id from qrys q where org_id=queryid
    union
  select queryid from dual
   order by id desc;
 BEGIN
   for c in cc loop
begin
    n := delquery_int(c.id, TRUE);
    From_Db_Utils.drop_qry_tab(c.id);
exception when others then raise_application_error(-20110, queryid||':'||c.id||':'||sqlerrm4user);
end;
   end loop;
   COMMIT;
 END;

 PROCEDURE delquery_tmp(qry_id_ QRYS.id%TYPE := NULL) IS
 BEGIN
  FOR i IN (SELECT id FROM QRYS q  WHERE tmp IS NOT NULL AND
   (cr_time<SYSDATE-1 or sysdate-cr_time>12/24 and trunc(cr_time)<>trunc(sysdate))
              AND (qry_id_ IS NULL OR id<>qry_id_) and org_id<>id
              and not exists(select 1 from qrys where org_id=q.org_id and id>q.id)
              order by id desc) LOOP
   begin
   delQuery(i.id);
   exception
    when others then
    raise_application_error(-20000, qry_id_||':'||i.id||':'||sqlerrm4user, true);
   end;
  END LOOP;
 END;

 PROCEDURE SetQueryXml(queryid IN INTEGER, querydata IN XMLType, tmp QRYS.tmp%TYPE := NULL) IS
  querydata_ QueryOBJ := XML2QueryOBJ(querydata);
 BEGIN
 --   querydata.toObject(querydata_);
    SetQuery(queryid, querydata_, tmp);
 END;

 PROCEDURE SetQuery(queryid IN INTEGER, querydata IN QueryOBJ, tmp QRYS.tmp%TYPE := NULL)
  IS
  n PLS_INTEGER;
  querydata_ QueryOBJ := querydata;
  cru qrys.cr_term%type;
  cp qrys.is_private%type;
  BEGIN
   IF querydata IS NULL THEN
       RAISE_APPLICATION_ERROR(-20000, 'Query data cannot be null');
   END IF;
   if queryid is not null and nvl(querydata_.is_private, ' ')<>is_private_pu then
    begin
    select cr_term, is_private into cru, cp from qrys where id=queryid;
    exception
    when no_data_found then
      RAISE_APPLICATION_ERROR(-20001, 'Query '||queryid||' does not exists');
    end;
    querydata_.is_private := nvl(querydata_.is_private, cp);
    if cru<>cos and cp<>is_private_pu then
     if tmp is null then
      errors.raise_err(err_access_ro, Constants.qry_task, cos, '', '', TRUE, TRUE);
     end if;
    end if;
   end if;
   if queryid is not null then
    select org_id into org_id_ from qrys where id=queryid;
   else
    org_id_ := null;
   end if;
   n := delquery_int(queryid, FALSE);
   n := addquery_int(querydata_, queryid, tmp);
  END;

  PROCEDURE is_attr(attr_id_ ATTRS.ID%TYPE) IS
   n BINARY_INTEGER;
  BEGIN
   SELECT 1 INTO n FROM ATTRS WHERE ID=attr_id_;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
   RAISE_APPLICATION_ERROR(-20000, 'Attribute doesn"t exists, id='||attr_id_, TRUE);
  END;

  PROCEDURE ListDimLevels(b_attr_id IN INTEGER, levelsinfo OUT TblLevelInfos)
  IS
  cr SYS_REFCURSOR;
  BEGIN

   ListDimLevels(b_attr_id, cr);
   BEGIN
    FETCH cr BULK COLLECT INTO levelsinfo;
    CLOSE cr;
   EXCEPTION
   WHEN OTHERS THEN
    CLOSE cr;
    RAISE;
   END;
  END;

  PROCEDURE ListDimLevels(b_attr_id IN INTEGER, levelsinfo OUT SYS_REFCURSOR)
  IS
   cr SYS_REFCURSOR;
  BEGIN
   is_attr(b_attr_id);
   OPEN levelsinfo FOR
/*  select d.id attr_id, d.abbr name
     from dim_levels d, attrs a, dim_levels d1
   where a.id=b_attr_id and a.dim_lev_id=d1.id and d1.dim_id=d.dim_id
         and d.ordno<=d1.ordno
   order by d.ordno desc; */
    SELECT * FROM (
    SELECT d.ID attr_id, d.abbr NAME
     FROM DIM_LEVELS d, ATTRS a, TYPES_COMP tc
   WHERE a.ID=b_attr_id AND NVL(a.dim_lev_id, a.attr_type)=tc.type_id AND tc.comp_type_id=d.ID
    and (tc.comp_type_id=tc.type_id or D.COL_IN_DIMS is not null or tc.FUN_ROW_CONV is not null) --pseudohierarhy
   ORDER BY d.dim_id, d.ordno DESC
    )
 UNION ALL --this is a real junk
 SELECT 0, a.abbr FROM ATTRS a WHERE ID=b_attr_id AND
 NULLIF(dim_lev_id, 0) IS NULL
  AND EXISTS(SELECT 1 FROM ATTRS2CUBES WHERE attr_id=b_attr_id AND
   show=Constants.show_key);
  END;

  PROCEDURE ListRsLevels(dim_lev_id_ IN INTEGER, levelsinfo OUT SYS_REFCURSOR)
  IS
   cr SYS_REFCURSOR;
  BEGIN
   OPEN levelsinfo FOR
    SELECT d.attr_type_code code, nvl(rtrim(ltrim(ATTR_TYPE_NAME, '('), ')'), initcap(attr_type_code)) NAME
     FROM RS_CODES4DIMS d
   WHERE d.DIM_LEV_ID=dim_lev_id_ AND noshow is null
   ORDER BY dim_lev_id, name;
  END;
PROCEDURE ListGrpLevels(b_attr_id IN INTEGER, show_all IN INTEGER, levelsinfo OUT SYS_REFCURSOR)
  IS
    show_all_ CONSTANT PLS_INTEGER := show_all;
  BEGIN
   is_attr(b_attr_id);
   OPEN levelsinfo FOR
   SELECT * FROM (
    SELECT grp_id attr_id, code NAME, MAX(show_in_full) show_in_full
  FROM SHOW_GRP_DIMS4ATTRS s
  WHERE attr_id=b_attr_id AND grp_id>0 AND
  (grp_type<>Tree_Fnc.cont_group OR
    NOT EXISTS(SELECT 1 FROM GROUPS c WHERE ID=s.grp_id AND is_leaf=1))
  GROUP BY grp_id, code
  ) WHERE show_in_full <= show_all_
   order by name
  ;
  END;
  PROCEDURE ListGrpLevels(b_attr_id IN INTEGER, levelsinfo OUT TblLevelInfos, show_all BOOLEAN := TRUE)
  IS
   cr SYS_REFCURSOR;
  BEGIN
   ListGrpLevels(b_attr_id, cr, show_all);
   BEGIN
    FETCH cr BULK COLLECT INTO levelsinfo;
    CLOSE cr;
   EXCEPTION
   WHEN OTHERS THEN
    CLOSE cr;
    RAISE;
   END;
  END;

  PROCEDURE ListGrpLevels(b_attr_id IN INTEGER, levelsinfo OUT SYS_REFCURSOR, show_all BOOLEAN := TRUE)
  IS
  show_all_ CONSTANT PLS_INTEGER := CASE WHEN show_all THEN 1 ELSE 0 END;
  BEGIN
   is_attr(b_attr_id);
   OPEN levelsinfo FOR
   SELECT * FROM (
    SELECT grp_id attr_id, code NAME, MAX(show_in_full) show_in_full
  FROM SHOW_GRP_DIMS4ATTRS s
  WHERE attr_id=b_attr_id AND grp_id>0 AND
  (grp_type<>Tree_Fnc.cont_group OR
    NOT EXISTS(SELECT 1 FROM GROUPS c WHERE ID=s.grp_id AND is_leaf=1))
  GROUP BY grp_id, code
  ) WHERE show_in_full <= show_all_
   order by name
  ;
  END;

  PROCEDURE ListLevelTypes(attr_id IN INTEGER, levelsinfo OUT TblLevelTypes)
  IS
   cr SYS_REFCURSOR;
  BEGIN
   ListLevelTypes(attr_id, cr);
   BEGIN
    FETCH cr BULK COLLECT INTO levelsinfo;
 CLOSE cr;
   EXCEPTION
   WHEN OTHERS THEN
    CLOSE cr;
    RAISE;
   END;
END;

  PROCEDURE ListLevelTypes(attr_id IN INTEGER, levelsinfo OUT SYS_REFCURSOR)
  IS
  BEGIN
   is_attr(attr_id);
   OPEN levelsinfo FOR
    SELECT ATTR_TYPE_CODE code, ATTR_TYPE_NAME NAME
  FROM rs_codes4dims_ r, ATTRS a WHERE a.dim_lev_id=r.dim_lev_id
   AND a.ID=listleveltypes.attr_id and r.noshow is null;
  END;



  PROCEDURE ListFunctions(b_attr_id IN INTEGER, levelsinfo OUT TblFncInfos)
  IS
   cr SYS_REFCURSOR;
  BEGIN
   ListFunctions(b_attr_id, cr);
   BEGIN
    FETCH cr BULK COLLECT INTO levelsinfo;
 CLOSE cr;
   EXCEPTION
   WHEN OTHERS THEN
    CLOSE cr;
    RAISE;
   END;
  END;

  PROCEDURE ListFunctions(b_attr_id IN INTEGER, levelsinfo OUT SYS_REFCURSOR)
  IS
  BEGIN
   is_attr(b_attr_id);
   OPEN levelsinfo FOR
    SELECT FUNC_ID FNC_ID, FUNC_NAME fnc_name, is_default
   FROM show_func_grp4attrs WHERE attr_id=b_attr_id;
  END;

  PROCEDURE add_qry2folder(qry_id_ QRYS.ID%TYPE, folder_id_ FOLDERS.ID%TYPE := NULL) IS
   folder_id FOLDERS.id%TYPE := NVL(folder_id_, get_root_folder_id);
  BEGIN
   DELETE QRYS2FOLDERS WHERE qry_id=qry_id_;
   INSERT INTO QRYS2FOLDERS(QRY_ID,FOLDER_ID)
    VALUES(qry_id_, add_qry2folder.folder_id);
  END;

  PROCEDURE del_qry_from_folder(qry_id_ QRYS.ID%TYPE, folder_id_ FOLDERS.ID%TYPE) IS
  BEGIN
   DELETE QRYS2FOLDERS WHERE qry_id=qry_id_ AND folder_id=folder_id_;
  END;

  PROCEDURE rename_qry(qry_id_ QRYS.ID%TYPE, new_abbr QRYS.abbr%TYPE,
    new_short QRYS.short%TYPE := NULL) IS
  BEGIN
   UPDATE QRYS SET abbr=new_abbr, short=new_short
    WHERE id=qry_id_;
  END;
  -- Marian (bgn): added extra methods for folder management
  FUNCTION  addFolder(FolderName   IN VARCHAR2,
                      FolderDesc   IN VARCHAR2,
                      ParentFolder IN FOLDERS.ID%TYPE) RETURN FOLDERS.ID%TYPE IS
      retval FOLDERS.ID%TYPE;
  BEGIN
      INSERT INTO FOLDERS(PID, ABBR, DESCR)
          VALUES(NVL(NULLIF(ParentFolder, -1), get_root_folder_id), FolderName, FolderDesc)
          RETURNING ID INTO retval;
      RETURN retval;
  END;

  PROCEDURE deleteFolder(Folder IN FOLDERS.ID%TYPE, FORCE PLS_INTEGER := 0) IS
  BEGIN
   FOR i IN (select id, substr(listagg(abbr, ';') within group(order by level, id) over(), 1, 950) folder_name
    from folders f
    where exists(select 1 from  qrys2folders qf where f.id=qf.folder_id)
    connect by prior id=pid
     start with id=deleteFolder.Folder) LOOP
    IF FORCE<>del_force THEN
      errors.raise_err(err_notempty_folder, Constants.qry_task, i.FOLDER_NAME, '', '', TRUE, FALSE);
    END IF;
    for ii in (select qry_id from qrys2folders qf where folder_id=i.id) loop
     DelQuery(ii.qry_id);
    end loop;
   END LOOP;
   DELETE FROM FOLDERS
       WHERE ID = Folder;
  END;

  PROCEDURE moveFolder(Folder    IN FOLDERS.ID%TYPE,
                       NewParent IN FOLDERS.ID%TYPE) IS
  BEGIN
      UPDATE FOLDERS
          SET PID = NULLIF(NewParent, -1)
          WHERE ID = Folder;
  END;

  PROCEDURE setupFolder(Folder     IN FOLDERS.ID%TYPE,
                        FolderName IN VARCHAR2,
                        FolderDesc IN VARCHAR2) IS
  BEGIN
      UPDATE FOLDERS
          SET abbr  = FolderName,
              DESCR = FolderDesc
          WHERE ID = Folder;
  END;
  -- Marian (end)

  PROCEDURE testqry IS
   n PLS_INTEGER := 28275;
   qrd queryobj;
  BEGIN
--   select queryobj(NAME, CUBEID, SELECTION, FILTERCONDS, FILTERELEMS, description, settings)
--    into qrd from test_queryobj where rownum=1;
--   qrd.name:=qrd.name||1;
--   setquery(n, qrd);
   qrd := getquery(n);
   qrd.NAME:=qrd.NAME||1;
   Saveobj(qrd);
  END;
  function get_qry_folders(id_ qrys.id%type) return tstrings250 is
   s tstrings250;
  begin
   select  cast(collect(abbr) as tstrings250) txt
    into s
    from (
    select level lvl, abbr
     from folders f
     connect by id=prior pid
     start with id=(select folder_id from qrys2folders qf join qrys q on qf.qry_id=q.org_id where q.id=id_)
     order  by lvl desc
    );
   return s;
  end;
  function get_qry_folders_xml(id_ qrys.id%type) return xmltype is
   s xmltype;
  begin
   select xmlelement("ROWSET", xmlagg(xmlelement("ROW", column_value)))
    into s
    from table(get_qry_folders(id_));
   return s;
  end;
  function put_qry_folders(folders_list tstrings250) return qrys.id%type is
   id_ qrys.id%type;
   pid_ qrys.id%type;
   n pls_integer;
  begin
   for c in (select rownum rn, column_value abbr from table(folders_list)) loop
    if c.rn=1 then
     id_ := get_root_folder_id;
    else
     select max(id) into id_ from folders where pid=pid_ and abbr=c.abbr;
     if id_ is null then
      id_ := addFolder(c.abbr, '', pid_);
     end if;
    end if;
    pid_ := id_;
   end loop;
   return id_;
  end;
  function put_qry_folders(folders_list xmltype) return qrys.id%type is
   id_ qrys.id%type;
   s tstrings250;
  begin
   select res bulk collect into s from xmltable('ROWSET/ROW' passing folders_list  columns res path 'text()');
   return put_qry_folders(s);
  end;
  procedure set_version(version_id_ pls_integer) is
  begin
   version_id := version_id_;
  end;
  function get_version return pls_integer deterministic is
  begin
   return version_id;
  end;
  function get_level_name(cube_id_ cubes.id%type, rng_ recs_tree.rng%type) return recs2cubes.lvl_name%type is
   res recs2cubes.lvl_name%type;
  begin
   select max(lvl_name) into res from recs_tree
    where rownum=1 and rng=rng_ and cube_id=cube_id_;
   return res;
  end;
END;
/