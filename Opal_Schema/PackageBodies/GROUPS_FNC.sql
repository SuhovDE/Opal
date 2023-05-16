--
-- GROUPS_FNC  (Package Body) 
--
--  Dependencies: 
--   GROUPS_FNC (Package)
--   SYS_UTILS_BASIC (Package)
--   ANALYZER (Package)
--   APP_LOG (Synonym)
--   ATTRS (Table)
--   ATTRS_ (View)
--   ATTR_TYPES (Table)
--   CONDS (Table)
--   COND_NODE (Type)
--   COND_NODES (Type)
--   CONSTANTS (Package)
--   DIMS (Table)
--   DIM_GRP_OBJ (Type)
--   DIM_LEVELS (Table)
--   ERRORS (Synonym)
--   GET_DOMAIN_NAME (Function)
--   GROUPS (Table)
--   GROUPS_GL (Table)
--   GRP_C (Table)
--   GRP_D (Table)
--   GRP_MEMBER (Type)
--   GRP_MEMBERS (Type)
--   GRP_TREE (Table)
--   INT_GRP_OBJ (Type)
--   LEAFS4CONDS (Table)
--   QRYS (Table)
--   QRYS_SEL (Table)
--   SAVEGRPOBJ (Procedure)
--   SAVEINTOBJ (Procedure)
--   SHOW_GROUPS4TYPES_ (View)
--   SQLERRM4USER (Synonym)
--   SYS_UTILS (Synonym)
--   TN (Type)
--   TOOLS4USER (Synonym)
--   TREE_FNC (Package)
--   TREE_NODE (Type)
--   TREE_NODES (Type)
--   TYPES_ (View)
--   TYPES_COMP (Table)
--   WRITE_LOG (Synonym)
--   DUAL (Synonym)
--   PLITBLM (Synonym)
--   XMLTYPE (Synonym)
--   STANDARD (Package)
--   XMLTYPE (Type)
--
CREATE OR REPLACE PACKAGE BODY OPAL_FRA.GROUPS_FNC as
 err_no_grp constant pls_integer := 3;
 err_bad_dim constant pls_integer := 4;
 err_is_tree constant pls_integer := 5;
 err_bad_group constant pls_integer := 9;
 err_is_group constant pls_integer := 12;
 err_is_in_tree constant pls_integer := 13;
 err_not_same_dim constant pls_integer := 16;
 empty_frontend constant pls_integer := -1;
 del_force_not constant pls_integer := 0;
 del_force_tree constant pls_integer := 1;
 del_force_qrys constant pls_integer := 2;
--------------------------------------------------------------------------------------
function get_dummy_grp return groups.id%type is
begin
 return dummy_grp;
end;
--------------------------------------------------------------------------------------
function get_grp_name(id_ groups.id%type) return varchar2 is
 nm varchar2(100);
begin
 select max(g.abbr) into nm from groups g where id=id_;
 return nm;
end;
--------------------------------------------------------------------------------------
function get_grp_subtype(int_type pls_integer, ubcond leafs4conds.op_sign%type)
  return groups.grp_subtype%type is
 ret groups.grp_subtype%type := bitand(int_type, 1);
begin
 ret := ret + 2 * (case when ubcond=ubcond_lt then 0 else 1 end);
 return ret;
end;
--------------------------------------------------------------------------------------
function get_lbcond(ubcond leafs4conds.op_sign%type)
  return leafs4conds.op_sign%type is
begin
 return (case when ubcond=ubcond_lt then lbcond_ge else lbcond_gt end);
end;
--------------------------------------------------------------------------------------
function get_int_type(grp_subtype groups.grp_subtype%type)
  return pls_integer deterministic is
begin
 return 2 - bitand(grp_subtype, 1);
end;
--------------------------------------------------------------------------------------
function root_grp(grp_id grp_tree.parent_id%type, id_ grp_tree.id%type) return boolean is
 isid grp_tree.id%type;
begin
 if grp_id=tree_fnc.root_not_d then
  select max(id) into isid from grp_tree where parent_id=grp_id and id=id_;
  if id_ is not null then return true; end if;
 end if;
 return false;
end;
--------------------------------------------------------------------------------------
procedure get_from_grp_subtype(grp_subtype groups.grp_subtype%type,
  int_type in out pls_integer,
  ubcond in out leafs4conds.op_sign%type, lbcond in out leafs4conds.op_sign%type) is
 bit2 pls_integer;
begin
 int_type := get_int_type(grp_subtype);
 bit2 := bitand(grp_subtype, 2);
 if bit2=0 then
  ubcond := ubcond_lt;
 else
  ubcond := ubcond_le;
 end if;
 lbcond := get_lbcond(ubcond);
end;
--------------------------------------------------------------------------------------
function ins_case2conds(name_ conds.descr%type, grp_id_ groups.id%type)
  return conds.id%type is
 id_ conds.id%type;
begin
 insert into conds(OP_SIGN, DESCR) values('CASE', name_)
  returning id into id_;
 insert into grp_c(GRP_ID, IS_LEAF, COND_ID) values(grp_id_, null, id_);
 return id_;
end;
--------------------------------------------------------------------------------------
procedure del_grp_with_cond(grp_id_ groups.id%TYPE) is
 cond_id_ conds.id%type;
begin
 select max(c.cond_id) into cond_id_ from grp_c c
  where c.grp_id=grp_id_;
 savepoint del_grp;
 if cond_id_ is not null then
  delete grp_c where grp_id=grp_id_;
  delete conds where id=cond_id_;
 end if;
 delete grp_tree where id=grp_id_ or parent_id=grp_id_;
 delete groups where id=grp_id_;
exception
when others then
  rollback to savepoint del_grp;
  write_log.log_message('DEL_GRP '||grp_id_, sqlerrm4user, 4);
end;
--------------------------------------------------------------------------------------
procedure del_grp_from_qrys(grp_id groups.id%TYPE) is
 qrys4grp SYS_REFCURSOR;
 id_ qrys.id%type;
 abbr_ qrys.abbr%type;
 descr_ qrys.short%type;
 ut char(1);
 isfound boolean := true;
begin
 qrys4grp := get_qrys4grp(grp_id);
 while (isfound) loop
  fetch qrys4grp into id_, abbr_, descr_, ut;
  isfound := qrys4grp%found;
  exit when not isfound;
  del_grp_from_qry(grp_id, id_);
 end loop;
 close qrys4grp;
exception
when others then
 if qrys4grp%isopen then close qrys4grp; end if;
 raise;
end;
--------------------------------------------------------------------------------------
--deleting a group with ID=grp_id
--del_force=0 - delete, only if the group is not present in queries and other groups
--del_force=1 - delete, only if the group is not present in queries
--del_force=2 - delete in any case, the group is deleted from queries
procedure delete_group(grp_id groups.id%TYPE, del_force pls_integer := 0) is
 cursor tt is
 select --+index(t)
   t.id, level lvl, (select predefined from groups where id=t.id) predefined
  from grp_tree t
  where t.id>0
  connect by prior t.id=t.parent_id
  start with t.parent_id=delete_group.grp_id;
 curr_lvl pls_integer := 0;
 skip_grp boolean := false;
 our_predefined groups.predefined%type;
 parid groups.id%type;
 grps nums;
 id_ groups.id%type;
 grp_type_ groups.grp_type%type;
begin
 select predefined into our_predefined from groups where id=grp_id;
 if our_predefined not in (tree_fnc.is_temporary, tree_fnc.is_persistant) then
  errors.raise_err(0, constants.qry_task, do_raise=>true);
 end if;
 if del_force=del_force_not then
  select max(parent_id) into parid from grp_tree where
    id=delete_group.grp_id and nullif(parent_id, tree_fnc.root_not_d) is not null
	and rownum=1;
  if parid is not null then
   errors.raise_err(err_is_tree, constants.qry_task, get_grp_name(grp_id),
    get_grp_name(parid), do_raise=>true);
  end if;
 end if;
 if del_force=del_force_qrys then
  del_grp_from_qrys(grp_id);
 end if;
--if we have multilevel group, this is not true
 select grp_type into grp_type_ from groups where id=grp_id;
 grps(1) := grp_id;
 for t in tt loop --with a goupp deleted all members - temporary groups and intervals
   skip_grp := not (t.predefined=tree_fnc.is_temporary or
	grp_type_=tree_fnc.cont_group);
   if skip_grp then curr_lvl := t.lvl; end if;
  if not skip_grp then
   grps(nvl(grps.last, 0)+1) := t.id;
  end if;
 end loop;
 if grps.last is not null then
  for i in reverse grps.first..grps.last loop
   id_ := grps(i);
   delete leafs4conds where grp_id=id_;
   del_grp_with_cond(id_);
  end loop;
 end if;
exception
when no_data_found then
 errors.raise_err(err_no_grp, constants.qry_task, grp_id, do_raise=>true);
end;
--------------------------------------------------------------------------------------
procedure check_dim_grp(curr_id groups.id%type, dim_id_ in out dims.id%type,
   type_id_ in out attr_types.id%type, parent_id_ grp_tree.parent_id%type) is
 curr_dim_id dims.id%type;
 curr_type_id attr_types.id%type;
 grp_name groups.abbr%type;
 dim_name dims.abbr%type;
 wrk pls_integer;
 real_type_id attr_types.id%type;
 real_dim_id dims.id%type;
begin
 if parent_id_ is null or parent_id_=tree_fnc.get_root_not_d then return; end if;
 select dim_id, type_id, g.abbr
  into curr_dim_id, curr_type_id, grp_name from groups g
  where id=curr_id;
 if curr_dim_id<>dim_id_ then
   select max(d2.dim_id), max(tc.comp_type_id) into real_dim_id, real_type_id
    from dim_levels d1, types_comp tc, dim_levels d2, types_comp tc1
    where d1.id=tc1.type_id and tc1.comp_type_id=type_id_ and d1.dim_id=dim_id_
     and tc1.TYPE_ID=tc.TYPE_ID
	 and d2.id=tc.comp_type_id and d2.id=curr_type_id;
   if real_dim_id is null then goto aerr; end if;
 else
  select max(type_id) into real_type_id
  from (
   select type_id
    from (
     select g.type_id
      from grp_tree gt, groups g, dim_levels d
      where gt.parent_id=parent_id_ and gt.id=g.id and g.type_id=d.id
 	 order by d.ordno desc
 	) where rownum=1
   );
  if type_id_<>real_type_id then type_id_ := real_type_id; end if;
 end if;
 return;
<<aerr>>
 select nvl(max(d.abbr), 'id='||dim_id_)
  into dim_name from dims d where id=dim_id_;
 errors.raise_err(err_bad_dim, constants.qry_task, grp_name, dim_name, do_raise=>true);
exception
when no_data_found then
 errors.raise_err(err_no_grp, constants.qry_task, curr_id, do_raise=>true);
end;
--------------------------------------------------------------------------------------
function ins_grp_tree(node tree_node,
  grp_id_ groups.id%type, dim_id_ in out dims.id%type, type_id_ in out attr_types.id%type)
 return grp_tree.parent_id%type is
 ordno_ grp_tree.ORDNO_IN_ROOT%type := nullif(node.ordno, empty_frontend);
 parent_id_ grp_tree.parent_id%type :=
  nullif(nvl(nullif(node.PARENT_ID, dummy_grp), nullif(grp_id_, dummy_grp)), empty_frontend);
begin
 if parent_id_ is null and node.id>0 then parent_id_ := tree_fnc.root_not_d; end if;
 check_dim_grp(node.ID, dim_id_, type_id_, parent_id_);
 if ordno_ is null then
   select nvl(max(ORDNO_IN_ROOT), 0)+1 into ordno_ from grp_tree where parent_id=parent_id_;
 end if;
 insert into grp_tree(ID, PARENT_ID, ORDNO_IN_ROOT, ALLREST, DATE_FROM, DATE_TO)
  values(node.ID, parent_id_, ORDNO_, node.REST, node.date_from, node.date_to);
 return parent_id_;
exception
when dup_val_on_index then
 errors.raise_err(err_is_in_tree, constants.qry_task,
  get_grp_name(node.ID), get_grp_name(parent_id_), do_raise=>true);
end;
--------------------------------------------------------------------------------------
procedure ins_grp_tree(node tree_node,
  grp_id_ groups.id%type, dim_id_ in out dims.id%type, type_id_ in out attr_types.id%type) is
 parent_id_ grp_tree.parent_id%type := ins_grp_tree(node,
  grp_id_, dim_id_, type_id_ );
begin
 null;
end;
--------------------------------------------------------------------------------------
procedure insleafs(cond_id_ conds.id%type, int_ordno conds.ordno%type, name_ varchar2,
   cond_op leafs4conds.op_sign%type, val leafs4conds.CONST%type,
   ph groups.id%type default null) is
 leaf_id_ conds.id%type;
begin
 if val is null and ph is null then return; end if;
 insert into conds(PARENT_ID, IS_LEAF, ORDNO, DESCR)
  values(cond_id_, 1, int_ordno, cond_id_||':'||name_||' '||cond_op)
  returning id into leaf_id_;
 if ph is null then
  insert into leafs4conds(LEAF_ID, LEFT_ATTR_ID, OP_SIGN, CONST)
   values(leaf_id_, placeholder, cond_op, val);
 else
  insert into leafs4conds(LEAF_ID, LEFT_ATTR_ID, OP_SIGN, GRP_ID)
   values(leaf_id_, placeholder, cond_op, PH);
 end if;
end;
--------------------------------------------------------------------------------------
function ins2group(predefined_ groups.predefined%type, grp_type_ groups.grp_type%type,
  int_type pls_integer,  name varchar2, description varchar2, type_id_ groups.type_id%type,
  dim_id_ groups.id%type, is_leaf_ groups.dim_id%type, is_grp_priv_ groups.is_grp_priv%type := null,
  cr_user_ groups.cr_user%type := null, full_ groups.full%type := null) return groups.id%type is
 id_ groups.id%type;
 dom_id_ groups.dom_id%type;
begin
SELECT max(dom_id) INTO dom_id_ FROM attr_types where id=type_id_;
select max(id) into id_ from groups where id<=999999;
select id+1 into id_ from groups where id=id_ for update nowait;
insert into groups(id, PREDEFINED, GRP_TYPE, grp_subtype, abbr, short,
  TYPE_ID, DIM_ID, dom_id, is_leaf, is_grp_priv, cr_user, full)
 values(id_, predefined_, grp_type_, int_type,
   name, description, type_id_, dim_id_, dom_id_, is_leaf_,
   nvl(is_grp_priv_, ANALYZER.is_private_pu), nvl(cr_user_, sys_utils.curr_osuser), full_)
 returning id into id_;
 return id_;
exception
when dup_val_on_index then
 errors.raise_err(err_is_group, constants.qry_task, name,
  get_domain_name(type_id_), do_raise=>true);
end;
--------------------------------------------------------------------------------------
procedure insleafs_all(cond_id_ conds.id%type, nodes in out nocopy cond_node,
  int_grp int_grp_obj) is
begin
 insleafs(cond_id_, 1, nodes.name, int_grp.lbcond,
  nodes.lbound, nodes.lph);
 insleafs(cond_id_, 2, nodes.name, int_grp.ubcond,
  nodes.ubound, nodes.uph);
end;
--------------------------------------------------------------------------------------
function get_default_node_name(nodes cond_node, int_grp int_grp_obj)
 return varchar2 is
  s varchar2(256);
begin
 s  := int_grp.name||' '||nodes.ordno;
 return substr(s, greatest(-length(s), -tree_fnc.abbr_len));
end;
--------------------------------------------------------------------------------------
procedure add_cond2int_group(nodes in out nocopy cond_node,
  main_cond_id_ conds.id%type, grp_id_ groups.id%type, dim_id_ dims.id%type,
  int_grp_ int_grp_obj := null, ordno_val pls_integer := null, date_from_ date, date_to_ date) is
 id_ groups.id%type;
 cond_id_ conds.id%type;
 int_grp int_grp_obj := int_grp_;
 real_dim_id dims.id%type; --next 2 parameters only for compatibility
 real_type_id dim_levels.id%type;
 subtype_ groups.grp_subtype%type;
 ordno_val_ pls_integer := ordno_val;
begin
 id_ := nullif(nodes.id, 0);
 if int_grp.type_id is null then
  select predefined, grp_subtype, type_id, is_grp_priv, cr_user
   into int_grp.predefined, subtype_, int_grp.type_id, int_grp.is_grp_priv, int_grp.cr_user
   from groups where id=grp_id_;
  get_from_grp_subtype(subtype_, int_grp.int_type, int_grp.ubcond, int_grp.lbcond);
 end if;
 if ordno_val_ is null then
  select nvl(max(ordno), 0)+1 into ordno_val_ from conds
   where parent_id=main_cond_id_;
 end if;
 if id_ is null then
  if nodes.name is null then
   nodes.name := get_default_node_name(nodes, int_grp);
  end if;
  id_ := ins2group(int_grp.predefined,
    tree_fnc.cont_group, int_grp.int_type,
    nodes.name, nodes.description, int_grp.type_id, dim_id_, 1, int_grp.is_grp_priv, int_grp.cr_user);
  nodes.id := id_;
  real_dim_id := dim_id_; real_type_id := int_grp.type_id;
--m.b., analyzing must be, if a condition really has 1 or 2 sides!!!!!!!!!
  insert into conds(OP_SIGN, PARENT_ID, ORDNO, DESCR)
   values('AND', main_cond_id_, ordno_val_, nodes.name)
   returning id into cond_id_;
  insert into grp_c(GRP_ID, COND_ID) values(id_, cond_id_);
  insleafs_all(cond_id_, nodes, int_grp);
  ins_grp_tree(tree_node(id_, grp_id_, nodes.ordno, null, date_from_, date_to_),
   id_, real_dim_id, real_type_id);
 else --here updating of an existing interval
  null;
 end if;
end;
--------------------------------------------------------------------------------------
procedure add_cond2int_group(main_cond_id_ conds.id%type, grp_id_ groups.id%type,
   dim_id_ dims.id%type, int_grp in out nocopy int_grp_obj, ordno_val pls_integer, date_from_ date, date_to_ date) is
 nodes cond_node := int_grp.nodes(ordno_val);
begin
 add_cond2int_group(nodes, main_cond_id_, grp_id_ , dim_id_,
   int_grp, ordno_val, date_from_, date_to_);
 int_grp.nodes(ordno_val) := nodes;
end;
--------------------------------------------------------------------------------------
function get_dim_id(attr_id_ attrs.id%type, type_id_ attr_types.id%type)
  return dims.id%type is
 dim_id_ dims.id%type;
begin
 if type_id_ is not null then
  select dim_id into dim_id_ from types_ where id=type_id_;
 elsif attr_id_ is not null then
  select dim_id into dim_id_ from attrs_ where id=attr_id_;
 end if;
 return dim_id_;
exception
when no_data_found then
return null;
end;
--------------------------------------------------------------------------------------
procedure set_real_dim(id_ groups.id%type, dim_id_ dims.id%type,
 real_dim_id dims.id%type, real_type_id dim_levels.id%type) is
begin
 if real_dim_id<>dim_id_ then
  update groups set dim_id=real_dim_id, type_id=real_type_id
   where id=id_;
 end if;
end;
--------------------------------------------------------------------------------------
function add_dim_group(dim_grp dim_grp_obj) return groups.id%TYPE is
 id_ groups.id%type;
 i pls_integer;
 dim_id_ constant dims.id%type := get_dim_id(dim_grp.attr_id, dim_grp.type_id);
 real_dim_id dims.id%type := dim_id_;
 real_type_id attr_types.id%type := dim_grp.type_id;
begin
 savegrpobj(dim_grp);
 id_ := ins2group(dim_grp.predefined,
  tree_fnc.dim_group, null,
  dim_grp.name, dim_grp.description, dim_grp.type_id, dim_id_, null, dim_grp.is_grp_priv, dim_grp.cr_user);
 if dim_grp.nodes is not null then
  i := dim_grp.nodes.first;
  while i is not null loop
   ins_grp_tree(dim_grp.nodes(i), id_, real_dim_id, real_type_id);
   i := dim_grp.nodes.next(i);
  end loop;
  set_real_dim(id_, dim_id_, real_dim_id, real_type_id);
 end if;
 return id_;
end;
--------------------------------------------------------------------------------------
function add_dim_group_xml(dim_grp XMLType) return groups.id%TYPE is
dim_grp_ dim_grp_obj;
begin
 dim_grp.toObject(dim_grp_);
 return add_dim_group(dim_grp_);
end;
--------------------------------------------------------------------------------------
procedure trim_int_grp(int_grp in out nocopy int_grp_obj) is
 i pls_integer;
 i1 pls_integer;
begin
 if int_grp.nodes is null then return; end if;
 i := int_grp.nodes.first;
 while i is not null loop
  int_grp.nodes(i).id := null;
  i1 := int_grp.nodes.next(i);
  if i1 is not null and int_grp.int_type=1 then
   int_grp.nodes(i).ubound := int_grp.nodes(i1).lbound;
   int_grp.nodes(i).uph := int_grp.nodes(i1).lph;
  end if;
  i := i1;
 end loop;
end;
--------------------------------------------------------------------------------------
function add_int_group(int_grp in out nocopy int_grp_obj) return groups.id%TYPE is
 id_ groups.id%type;
 i pls_integer;
 dim_id_ constant dims.id%type := get_dim_id(int_grp.attr_id, int_grp.type_id);
 main_cond_id_ conds.id%type;
begin
 saveintobj(int_grp);
 id_ := ins2group(int_grp.predefined,
   tree_fnc.cont_group, get_grp_subtype(int_grp.int_type, int_grp.ubcond),
   int_grp.name, int_grp.description, int_grp.type_id, dim_id_, null, int_grp.is_grp_priv, int_grp.cr_user);
 main_cond_id_ := ins_case2conds(int_grp.name, id_);
 if int_grp.nodes is not null then
  trim_int_grp(int_grp);
  i := int_grp.nodes.first;
  while i is not null loop
   add_cond2int_group(main_cond_id_, id_, dim_id_, int_grp, i,
    date_from_=>int_grp.nodes(i).date_from, date_to_=>int_grp.nodes(i).date_to);
   i := int_grp.nodes.next(i);
  end loop;
 end if;
 return id_;
end;
--------------------------------------------------------------------------------------
function add_int_group_xml(int_grp in out nocopy XMLType) return groups.id%TYPE is
int_grp_ int_grp_obj;
begin
 int_grp.toObject(int_grp_);
 return add_int_group(int_grp_);
end;

--------------------------------------------------------------------------------------
procedure set_dim_group(grp_id groups.id%type, dim_grp dim_grp_obj,
  del_tree boolean := false) is
 i pls_integer;
 curr_id pls_integer;
 dim_id_org constant dims.id%type := get_dim_id(dim_grp.attr_id, dim_grp.type_id);
 dim_id_ dims.id%type := dim_id_org;
 real_type_id groups.type_id%type := dim_grp.type_id;
 do_del_tree boolean := (dim_grp.nodes is not null or del_tree);
 tmp rowid;
begin
 savegrpobj(dim_grp);
 update groups set PREDEFINED = dim_grp.predefined,
   abbr = dim_grp.name, short=dim_grp.description,
   TYPE_ID = dim_grp.type_id, DIM_ID = dim_id_, is_grp_priv = dim_grp.is_grp_priv, cr_user = dim_grp.cr_user
  where id=set_dim_group.grp_id;
 if do_del_tree then
  delete grp_tree where parent_id=set_dim_group.grp_id/* or id=set_dim_group.grp_id*/
   and id not in (select id from table(dim_grp.nodes));
 end if;
 delete grp_tree where parent_id=set_dim_group.grp_id; --always full replacement now
 if dim_grp.nodes is not null and not del_tree then
  i := dim_grp.nodes.first;
  while i is not null loop
   if /*dim_grp.nodes(i).parent_id is null or*/
      dim_grp.nodes(i).parent_id = set_dim_group.grp_id then
--    select max(rowid) into tmp from grp_tree gt where parent_id=set_dim_group.grp_id
 --    and id=dim_grp.nodes(i).id and date_from is null;
--    if tmp is null then
     ins_grp_tree(dim_grp.nodes(i), grp_id, dim_id_, real_type_id);
--app_log.log_messageex('GRP', 'pid='||grp_id||', id='||dim_grp.nodes(i).id||', date='||dim_grp.nodes(i).date_from);
--    else
--     update grp_tree set date_from=dim_grp.nodes(i).date_from, date_to=dim_grp.nodes(i).date_to,
--       ordno_in_root=dim_grp.nodes(i).ordno, allrest=dim_grp.nodes(i).rest
--      where rowid=tmp;
--    end if;
   end if;
   i := dim_grp.nodes.next(i);
  end loop;
  set_real_dim(grp_id, dim_id_org, dim_id_, real_type_id);
 end if;
end;
--------------------------------------------------------------------------------------
procedure set_dim_group_xml(grp_id groups.id%type, dim_grp XMLType) is
 dim_grp_ dim_grp_obj;
begin
app_log.log_messageex('GRP', grp_id, dim_grp.getclobval());
 dim_grp.toObject(dim_grp_);
 set_dim_group(grp_id, dim_grp_);
end;
--------------------------------------------------------------------------------------
procedure fill_ids(grp_id groups.id%type, int_grp in out nocopy int_grp_obj) is
 i pls_integer;
begin
 if int_grp.nodes is null then return; end if;
 i := int_grp.nodes.first;
 while i is not null loop
  select max(g.id) into int_grp.nodes(i).id
   from groups g, grp_tree gt
   where g.abbr=int_grp.nodes(i).name and
    g.id=gt.id and gt.parent_id=grp_id and
	nvl(g.type_id, 0)=nvl(int_grp.type_id,0);
  i := int_grp.nodes.next(i);
 end loop;
end;
--------------------------------------------------------------------------------------
procedure set_int_group(grp_id groups.id%type, int_grp in out nocopy int_grp_obj) is
 i pls_integer;
 curr_id pls_integer;
 dim_id_ dims.id%type;
 cond_id_ conds.id%type;
 main_cond_id_ conds.id%type;
 new_nodes nums;
 id_ groups.id%type;
 nodes_ cond_node;
begin
 saveintobj(int_grp);
 update groups set PREDEFINED = int_grp.predefined,
   grp_subtype = get_grp_subtype(int_grp.int_type, int_grp.ubcond),
   abbr = int_grp.name, short=int_grp.description,
   TYPE_ID = int_grp.type_id , is_grp_priv = int_grp.is_grp_priv, cr_user = int_grp.cr_user
  where id=set_int_group.grp_id
  returning dim_id into dim_id_;
 select cond_id into main_cond_id_
  from grp_c where grp_id=set_int_group.grp_id;
 if int_grp.nodes is not null then
  trim_int_grp(int_grp);
  fill_ids(grp_id, int_grp);
  i := int_grp.nodes.first;
  while i is not null loop
   id_ := int_grp.nodes(i).id;
   if  id_ is null then
    add_cond2int_group(main_cond_id_, grp_id, dim_id_, int_grp, i,
     date_from_=>int_grp.nodes(i).date_from, date_to_=>int_grp.nodes(i).date_to);
    id_ := int_grp.nodes(i).id;
   else
    select cond_id into cond_id_
   	 from grp_c where grp_id=id_;
    update groups g set predefined=int_grp.predefined,  --do not change IS_GRP_PRIV/CR_USER of children int groups
      g.abbr = int_grp.nodes(i).name, short=int_grp.nodes(i).description
	    where id=id_;
    update grp_tree set ordno_in_root=int_grp.nodes(i).ordno, date_from=int_grp.nodes(i).date_from, date_to=int_grp.nodes(i).date_to
	    where id=id_ and parent_id=set_int_group.grp_id;
	   delete conds where parent_id=cond_id_;
    update conds set ordno=i where id=cond_id_;
    insleafs_all(cond_id_, int_grp.nodes(i), int_grp);
   end if;
   new_nodes(id_) := 1;
   i := int_grp.nodes.next(i);
  end loop;
 end if;
 for c in (select id from grp_tree where parent_id=set_int_group.grp_id) loop
  if not new_nodes.exists(c.id) then
   del_int_from_grp(c.id, grp_id);
  end if;
 end loop;
end;
--------------------------------------------------------------------------------------
procedure set_int_group_xml(grp_id groups.id%type, int_grp in out nocopy XMLType) is
 int_grp_ int_grp_obj;
begin
 int_grp.toObject(int_grp_);
 set_int_group(grp_id, int_grp_);
end;
--------------------------------------------------------------------------------------
function get_dim_group(grp_id groups.id%TYPE) return dim_grp_obj is
 dim_grp dim_grp_obj := dim_grp_obj('');
begin
 select PREDEFINED, g.abbr, g.short, TYPE_ID, DIM_ID, is_grp_priv, cr_user
  into dim_grp.PREDEFINED, dim_grp.NAME,
    dim_grp.description, dim_grp.TYPE_ID, dim_grp.DIM_ID, dim_grp.is_grp_priv, dim_grp.cr_user
  from groups g where id=grp_id;
 select  --selecting only the first level of the group without root line!!!
   tree_node(t.id, t.parent_id, t.ORDNO_IN_ROOT, t.ALLREST, date_from, date_to)
  bulk collect into dim_grp.nodes
  from grp_tree t
  where get_dim_group.grp_id=parent_id --nvl(t.parent_id, 1)>0
  connect by prior t.id=t.parent_id
  start with t.id=grp_id and nullif(parent_id, tree_fnc.root_not_d) is null;
 return dim_grp;
exception
when no_data_found then
 errors.raise_err(err_no_grp, constants.qry_task, grp_id, do_raise=>true);
end;
--------------------------------------------------------------------------------------
function get_dim_group_xml(grp_id groups.id%TYPE) return XMLType is
begin
 return XMLType(get_dim_group(grp_id));
end;
--------------------------------------------------------------------------------------
function get_int_group(grp_id_ groups.id%TYPE) return int_grp_obj is
 int_grp int_grp_obj := int_grp_obj('');
 grp_subtype_ groups.grp_subtype%type;
 cn cond_node;
 lb leafs4conds.const%type := null;
begin
 select PREDEFINED, g.abbr, g.short, TYPE_ID, grp_subtype, is_grp_priv, cr_user
  into int_grp.PREDEFINED, int_grp.NAME,
    int_grp.description, int_grp.TYPE_ID, grp_subtype_, int_grp.is_grp_priv, int_grp.cr_user
  from groups g where id=grp_id_;
 get_from_grp_subtype(grp_subtype_, int_grp.int_type, int_grp.ubcond, int_grp.lbcond);
 for c in (select t.id, g.abbr name, g.short descr, t.ORDNO_IN_ROOT, gc.cond_id, t.date_from, t.date_to
   from grp_tree t, grp_c gc, groups g, conds c
   where t.parent_id=grp_id_ and t.id=gc.grp_id and g.id=t.id and c.id=gc.COND_ID
   order by c.ordno) loop
  cn := cond_node();
  cn.id := c.id; cn.name := c.name; cn.description := c.descr;
  cn.ordno := c.ordno_in_root; cn.date_from := c.date_from; cn.date_to := c.date_to;
  for cc in (select l.op_sign, l.grp_id, l.const from leafs4conds l,
              (select id from conds connect by prior id=parent_id
                start with id=c.cond_id) cc
			    where leaf_id=cc.id) loop
   if cc.op_sign in (ubcond_lt, ubcond_le) then
    cn.ubound := nullif(cc.const, very_big); cn.uph := cc.grp_id;
   elsif cc.op_sign in (lbcond_gt, lbcond_ge) then
    cn.lbound := nullif(cc.const, very_low); cn.lph := cc.grp_id;
   end if;
  end loop;
  if cn.lbound is null then cn.lbound := lb; end if;
  int_grp.nodes.extend;
  int_grp.nodes(int_grp.nodes.last) := cn;
  lb := cn.ubound;
 end loop;
 return int_grp;
exception
when no_data_found then
 errors.raise_err(err_no_grp, constants.qry_task, grp_id_, do_raise=>true);
end;
--------------------------------------------------------------------------------------
function get_int_group_xml(grp_id_ groups.id%TYPE) return XMLType is
 xml XMLType;
begin
   Select DELETEXML(XMLType(get_int_group(grp_id_)), '//*[not(text())][not(*)]' ) into xml from dual;
 return xml;
end;
--------------------------------------------------------------------------------------
function add_to_grp_tree(node tree_node, grp_id groups.id%type := null,
  type_id attr_types.id%type := null)
 return pls_integer is
 grp_id_ constant groups.id%type := nvl(node.parent_id, grp_id);
 dim_id_ dims.id%type;
 dim_id_org dims.id%type;
 type_id_ attr_types.id%type;
 node_ tree_node := node;
 real_parent_id grp_tree.parent_id%type;
 ukey_ pls_integer;
 id_ grp_tree.id%type;
begin
 begin
  select dim_id, type_id into dim_id_, type_id_ from groups where id=nvl(grp_id_, node.id);
 exception
 when no_data_found then null;
 end;
 dim_id_org := dim_id_;
 if root_grp(grp_id_, node.id) then goto getukey; end if;
 real_parent_id := ins_grp_tree(node, grp_id_, dim_id_, type_id_);
 set_real_dim(grp_id, dim_id_org, dim_id_, type_id_);
<<getukey>>
 select nvl(max(ukey), 0) into ukey_ from show_groups4types_
  where grp_id=node.id and parent_id=nvl(real_parent_id, dummy_grp)
   and type_id=nvl(add_to_grp_tree.type_id, type_id_) /*and show_in_full=0*/;
 return ukey_;
exception
when no_data_found then
 return 0;
end;
--------------------------------------------------------------------------------------
function add_to_grp_tree_xml(node_xml XMLType, grp_id groups.id%type := null,
  type_id attr_types.id%type := null)
 return pls_integer is
 node tree_node;
begin
 node_xml.toObject(node);
 return add_to_grp_tree(node, grp_id, type_id);
end;
--------------------------------------------------------------------------------------
function add_int_to_grp(node in out nocopy cond_node, grp_id_ groups.id%type)
  return pls_integer is
 dim_id_ dims.id%type;
 type_id_ attr_types.id%type;
 ukey_ pls_integer;
 main_cond_id_ conds.id%type;
 name_ conds.descr%type;
 id_ grp_tree.id%type;
begin
 begin
  select g.dim_id, g.type_id, g.abbr, c.cond_id
   into dim_id_, type_id_, name_, main_cond_id_
   from groups g, grp_c c where g.id=grp_id_ and c.grp_id=g.id;
 exception
 when no_data_found then null;
 end;
 if root_grp(grp_id_, node.id) then goto getukey; end if;
 add_cond2int_group(node, main_cond_id_, grp_id_, dim_id_, date_from_=>node.date_from, date_to_=>node.date_to);
<<getukey>>
 select nvl(max(ukey), 0) into ukey_ from show_groups4types_
  where grp_id=node.id and parent_id=grp_id_
   and type_id=type_id_ and show_in_full=0;
 return ukey_;
exception
when no_data_found then
 return 0;
end;
--------------------------------------------------------------------------------------
procedure del_from_grp_tree(id_ groups.id%type, grp_id groups.id%type, from_root boolean := false,
 date_from_ grp_tree.date_from%type := null) is
begin
if from_root or grp_id<>tree_fnc.root_not_d then
 delete grp_tree where id=id_ and parent_id=grp_id and nvl(date_from, constants.doomsday)=nvl(date_from_, constants.doomsday);
end if;
end;
--------------------------------------------------------------------------------------
procedure del_int_from_grp(id_ groups.id%type, grp_id groups.id%type) is
begin
 del_from_grp_tree(id_, grp_id);
 delete_group(id_);
end;
-----------------------------------------------------------------------------------------
 procedure check_group(grp_id_ groups.id%type, grp_type groups.grp_type%type := null) is
  n pls_integer;
  grp_type_ groups.grp_type%type :=grp_type;
 begin
  if grp_id_<0 then return; end if;
  if grp_type_ is null then
   select grp_type into grp_type_ from groups where id=grp_id_;
  end if;
if grp_type_=tree_fnc.dim_group then
select --+index(gt i_grp_tree_p)
    id into n
   from grp_tree gt
   where id>0 and rownum=1 and not exists(
     select 1 from grp_tree gt1 where parent_id=gt.id
   )
   start with gt.id=grp_id_
  connect by prior gt.id=gt.parent_id;
elsif grp_type_=tree_fnc.cont_group then
select --+index(gt i_grp_tree_p)
    id into n
   from grp_tree gt
   where id>0 and rownum=1 and  not exists(
	 select 1 from grp_c c, conds l
		        where c.grp_id=gt.id and l.parent_id=c.cond_id
	  )
   start with gt.id=grp_id_
  connect by prior gt.id=gt.parent_id;
else
 return;
end if;
 errors.raise_err(err_bad_group, constants.qry_task,
   get_grp_name(grp_id_), get_grp_name(n), do_raise=>true);
 exception
 when no_data_found then
  null;
 end;
--------------------------------------------------------------------------------------
procedure exchange_ordno(parent_id_ grp_tree.parent_id%type, id1 grp_tree.id%type,
  id2 grp_tree.id%type) is
 ordno grp_tree.ordno_in_root%type;
begin
 select ordno_in_root into ordno from grp_tree
  where parent_id=parent_id_ and id=id1;
 update grp_tree set ordno_in_root=(select ordno_in_root from grp_tree where
    parent_id=parent_id_ and id=id2)
  where parent_id=parent_id_ and id=id1;
 update grp_tree set ordno_in_root=ordno
  where parent_id=parent_id_ and id=id2;
exception
when no_data_found then null;
end;
--------------------------------------------------------------------------------------
procedure set_ordNo(grp_id_ grp_tree.id%type, parent_id_ grp_tree.id%type,
 ordno grp_tree.ordno_in_root%type) is
begin
 update grp_tree set ordno_in_root=ordno
  where id=grp_id_ and
   parent_id=nvl(nullif(parent_id_, empty_frontend), tree_fnc.root_not_d);
end;
--------------------------------------------------------------------------------------
procedure is_double_int_name(pid grp_tree.parent_id%type) is
 n pls_integer;
begin
 for c in (select /*+index(t) index(g)*/ count(*), g.abbr abbr, g1.abbr pabbr
             from grp_tree t, groups g, groups g1
  	   	  	where t.parent_id=pid and t.ID=g.id and g1.id=pid
			group by g.abbr, g1.abbr having count(*)>1) loop
  errors.raise_err(err_is_group, constants.qry_task, c.abbr,
   c.pabbr, do_raise=>true);
 end loop;
end;
--------------------------------------------------------------------------------------
procedure del1(id_ conds.id%type, qry_id_ qrys.id%type) is
 pid conds.id%type;
 n pls_integer;
begin
  select parent_id into pid from conds where id=id_;
  if pid is null then
   update qrys set where_id=null where where_id=id_ and id=qry_id_;
   update qrys set having_id=null where having_id=id_ and id=qry_id_;
  end if;
  delete conds where id=id_;
  select count(*) into n from conds where parent_id=pid and rownum<2;
  if n=0 then
   del1(pid, qry_id_);
  end if;
end;
--------------------------------------------------------------------------------------
procedure del_grp_from_qry(grp_id_ groups.id%type, qry_id_ qrys.id%type) is
 wid conds.id%type;
 hid conds.id%type;
begin
 select where_id, having_id into wid, hid from qrys where id=qry_id_;
 delete qrys_sel where grp_id=grp_id_ and qry_id=qry_id_;
 for i in (select c.id from
   (select id from conds connect by parent_id=prior id
      start with id in (wid, hid)) c, leafs4conds l
    where l.grp_id=grp_id_ and c.id=l.leaf_id) loop
  del1(i.id, qry_id_);
 end loop;
exception
when no_data_found then null;
end;
--------------------------------------------------------------------------------------
function get_qrys4grp(grp_id_ groups.id%type) return SYS_REFCURSOR is
 grp_cur_out SYS_REFCURSOR;
begin
 open grp_cur_out for --don't change names in cursors!!!
   select qry_id, q.abbr qry_abbr, q.short qry_descr, 'S' usage_type from qrys_sel a, qrys q
     where grp_id=grp_id_ and a.qry_id=q.id
   union all
   select q.id, q.abbr name, q.short, 'C' usage_type from
    (select id from conds connect by prior parent_id=id start with id in
	   (select leaf_id from leafs4conds where grp_id=grp_id_)
     ) c, qrys q
    where c.id in (q.where_id, q.having_id);
 return grp_cur_out;
end;
--------------------------------------------------------------------------------------
function get_parents4grp(grp_id_ groups.id%type) return SYS_REFCURSOR is
 grp_cur_out SYS_REFCURSOR;
begin
 open grp_cur_out for
   select t.parent_id, g.abbr parent_abbr, g.short parent_descr
     from grp_tree t, groups g
     where t.id=grp_id_ and t.parent_id=g.id and t.parent_id<>tree_fnc.root_not_d;
 return grp_cur_out;
end;
----------------------------------------------------------------------------------
PROCEDURE prefix_group_code(code IN OUT NOCOPY VARCHAR2, ordno PLS_INTEGER) IS
BEGIN
 code := LPAD(LTRIM(TO_CHAR(ordno)), 5, '0')||'@'||code;
END;
--------------------------------------------------------------------------------------
function get_Groups_ROOT_ID return GROUPS.ID%type	deterministic is
begin
 return tree_fnc.root_not_d;
end;
--------------------------------------------------------------------------------------
function get_Nodes_ROOT_ID return GROUPS_GL.GL_ID%type		deterministic is
 uk number(38);
 gid constant groups.id%type := get_Groups_ROOT_ID;
begin
 select ukey into uk from show_groups4types_ where grp_id=gid and rownum=1;
 return uk;
end;
--------------------------------------------------------------------------------------
procedure set_all_members(parsed_group IN OUT NOCOPY parsed_group_type) is
 tmp grp_members;
begin
-- if parsed_group is null then return; end if;
 parsed_group.all_members := tn();
 for i in 1..parsed_group.struct.count loop
  tmp := parsed_group.struct(i).members;
  select * bulk collect into parsed_group.all_members from (
   select id from table(tmp)
   union
   select * from table(parsed_group.all_members)
  );
 end loop;
end;
--------------------------------------------------------------------------------------
function create_parsed_group(grp_id groups.id%type, leafs_only boolean:=true) return parsed_group_type is
 parsed_group parsed_group_type;
begin
 parsed_group.leafs_only := leafs_only;
 parsed_group.grp_id := grp_id;
 parsed_group.struct := grp_levels();
 parsed_group.all_members := tn();
 return parsed_group;
end;
--------------------------------------------------------------------------------------
procedure parse_group(grp_id groups.id%type, parsed_group IN OUT NOCOPY parsed_group_type) is
 s VARCHAR2(32000);
 CURSOR gg IS
  SELECT a.*, (select 1 from grp_tree where parent_id=a.id and rownum=1 and dim_lev_code is not null) is_leaf
   FROM (
    SELECT DISTINCT gt.ID, g.dim_lev_id dim_lev_id, g.dim_lev_code, gr.dim_id, d.ordno, gt.date_from, gt.date_to
     FROM (
      SELECT --+index(t I_GRP_TREE_P)
        t.*
       FROM GRP_TREE t
       START WITH ID=parse_group.grp_id
       CONNECT BY PRIOR ID=parent_id AND NVL(parent_id, 0)>0
     ) gt, GRP_D g, GROUPS gr, dim_levels d
     WHERE gt.ID=g.grp_id(+) AND gt.ID=gr.ID(+) AND g.dim_lev_id=d.ID(+)
   ) a WHERE dim_lev_code IS NOT NULL OR ID = -dim_id --All
   ORDER BY case when date_to is null and date_from is null then 0 else 1 end, ordno NULLS FIRST; --ordno and dim_lev_id is one-to-one, but ordno is always correct
 curr_dim_lev DIM_LEVELS.ID%TYPE := -1;
 nl pls_integer;
 ne pls_integer;
 dim_level4all constant dim_levels.id%type := 0;
BEGIN
 Groups_Fnc.check_group(grp_id, Tree_Fnc.dim_group);
 parsed_group := create_parsed_group(grp_id, true);
 FOR g IN gg LOOP
  if g.is_leaf is not null then parsed_group.leafs_only := false; end if;
  IF nvl(g.dim_lev_id, dim_level4all)<>nvl(curr_dim_lev, dim_level4all) THEN
   curr_dim_lev := g.dim_lev_id;
   parsed_group.struct.extend;
   nl := nvl(parsed_group.struct.last, 0); -- + 1;
   parsed_group.struct(nl).dim_lev_id := curr_dim_lev;
   parsed_group.struct(nl).dim_id := g.dim_id;
   parsed_group.struct(nl).ordno := g.ordno;
   parsed_group.struct(nl).members := grp_members();
  END IF;
  parsed_group.struct(nl).members.extend;
  ne := nvl(parsed_group.struct(nl).members.last, 0); -- + 1;
  parsed_group.struct(nl).members(ne) :=grp_member(g.id, g.dim_lev_code, g.date_from, g.date_to);
 END LOOP;
set_all_members(parsed_group);
end;
--------------------------------------------------------------------------------------
procedure get_parse_group_ext(grp_id groups.id%type, parsed_group_ext IN OUT NOCOPY parsed_group_type) is
 parsed_group parsed_group_type;
begin
 parse_group(grp_id, parsed_group);
 get_parse_group_ext(parsed_group, parsed_group_ext);
end;
--------------------------------------------------------------------------------------
function is_ext_group_in_members(curr_grp groups.id%type, totgrp tn) return pls_integer is
 wrk pls_integer;
begin
 select count(*) into wrk from (
  SELECT t.parent_id
    FROM GRP_TREE t--, grp_d d
    where t.id<0  AND NVL(parent_id, 0)<0
    START WITH ID=curr_grp
    CONNECT BY ID=PRIOR parent_id
   ) where parent_id in (select * from table(totgrp)) and rownum<2;
 return wrk;
end;
--------------------------------------------------------------------------------------
function normalize(parsed_group_ parsed_group_type) return parsed_group_type is
  parsed_group parsed_group_type := parsed_group_;
  wrk pls_integer;
  totgrp tn := tn();
  curr_grp groups.id%type;
begin
 for i in 1..parsed_group.struct.count-1 loop
  select id bulk collect into totgrp
   from table(parsed_group.struct(i).members)
  union all
  select * from table(totgrp);
 end loop;
 for i in reverse 2..parsed_group.struct.count loop
  for ii in reverse 1..parsed_group.struct(i).members.count loop
   curr_grp := parsed_group.struct(i).members(ii).id;
   wrk := is_ext_group_in_members(curr_grp, totgrp);
   if wrk>0 then
    parsed_group.struct(i).members.delete(ii);
   end if;
  end loop;
 end loop;
 for i in reverse 2..parsed_group.struct.count loop
  if parsed_group.struct(i).members.count=0 then
   parsed_group.struct.delete(i);
  end if;
 end loop;
 set_all_members(parsed_group);
 return parsed_group;
end;
--------------------------------------------------------------------------------------
procedure get_parse_group_ext(parsed_group_ parsed_group_type,
  parsed_group_ext IN OUT NOCOPY parsed_group_type) is
 dim_id_ dim_levels.dim_id%type;
 nl pls_integer;
 cl pls_integer:=0;
 last_ordno dim_levels.ordno%type;
 wrk grp_members;
 parsed_group constant parsed_group_type := normalize(parsed_group_);
begin
-- parsed_group_ext := null;
-- parsed_group_ext.struct := grp_levels();
 if parsed_group.grp_id is null then return; end if;
 if parsed_group.struct.count=0 then return; end if;
 if parsed_group.struct(parsed_group.struct.first).dim_lev_id is null then
  parsed_group_ext := parsed_group; --group with All...
  return;
 end if;
 nl := parsed_group.struct.first;
 dim_id_ := parsed_group.struct(nl).dim_id;
 last_ordno := parsed_group.struct(parsed_group.struct.last).ordno;
 parsed_group_ext := create_parsed_group(parsed_group.grp_id, parsed_group.leafs_only);
 for d in (select id, ordno from dim_levels where dim_id=dim_id_ and ordno<=last_ordno order by ordno) loop
  parsed_group_ext.struct.extend;
  cl := parsed_group_ext.struct.last;
  if parsed_group.struct.exists(nl) and parsed_group.struct(nl).ordno=d.ordno then
   parsed_group_ext.struct(cl) := parsed_group.struct(nl);
   nl := nl+1;
  else
   parsed_group_ext.struct(cl).dim_lev_id := d.id;
   parsed_group_ext.struct(cl).dim_id := dim_id_;
   parsed_group_ext.struct(cl).ordno := d.ordno;
   parsed_group_ext.struct(cl).members := grp_members();
  end if;
 end loop;
 parsed_group_ext.struct(parsed_group_ext.struct.last) := parsed_group.struct(parsed_group.struct.last);
 for g in reverse 1..parsed_group_ext.struct.count-1 loop
  --insert into table(cast(parsed_group_ext.struct(g).members as grp_members))
   select grp_member(id, code, date_to, date_from) bulk collect into wrk from (
    select d.grp_id id, d.dim_lev_code code, t.date_to, t.date_from
     from table(parsed_group_ext.struct(g+1).members) m, grp_tree t, grp_d d
     where m.id=t.id and d.grp_id=t.parent_id and t.parent_id<0
    union
    select * from table(parsed_group_ext.struct(g).members)
   );
   parsed_group_ext.struct(g).members := wrk;
 end loop;
 set_all_members(parsed_group_ext);
end;
--------------------------------------------------------------------------------------
function print_parsed_group(p parsed_group_type) return varchar2 is
 s varchar2(32766);
 eol char(2):= chr(13)||chr(10);
 shift varchar2(30);
begin
 s := p.grp_id||': leafs '||case when p.leafs_only then 'true' else 'false' end||': levels '||p.struct.count||eol;
 for i in 1..p.struct.count loop
  shift := '  ';
  s :=  s||shift||'lev='||p.struct(i).dim_lev_id||', dim='||p.struct(i).dim_id||', ordno='||p.struct(i).ordno
   ||', members='||p.struct(i).members.count||eol;
  shift := '    ';
  for j in 1..p.struct(i).members.count loop
   if j<>1 then s := s||','; end if;
   s := s||shift||p.struct(i).members(j).code;
  end loop;
  s := s||eol;
 end loop;
 if p.all_members is not null then
  s := s||eol||'all_members:';
  for i in 1..p.all_members.count loop
  for j in 1..p.struct(i).members.count loop
   if i<>1 then s := s||', '; end if;
   s := s||p.all_members(i);
  end loop;
  end loop;
 end if;
 return s;
end;
--------------------------------------------------------------------------------------
function levels_intersect(l1 grp_members, l2 grp_members) return pls_integer is
 nm pls_integer;
begin
 select count(*) into nm from (
  select * from table(l1)
  intersect
  select * from table(l2)
 );
 return case when nm=0 then groups_not_intersect else groups_intersect end;
end;
--------------------------------------------------------------------------------------
function levels_enclosed(l1 grp_members, l2 grp_members) return pls_integer is
 nm pls_integer;
 wrk pls_integer := groups_not_intersect;
begin
 select count(*) into nm from (
  select * from table(l1)
  minus
  select * from table(l2)
 );
 if nm=0 then wrk := wrk + groups_enclosed_2to1; end if;
 select count(*) into nm from (
  select * from table(l2)
  minus
  select * from table(l1)
 );
 if nm=0 then wrk := wrk + groups_enclosed_1to2; end if;
 return wrk;
end;
--------------------------------------------------------------------------------------
function can_groups_intersect(pg_org parsed_group_type, pg_ext1 parsed_group_type,
  pg_org1 parsed_group_type) return pls_integer is
 rc pls_integer := groups_not_intersect;
 wrk pls_integer := groups_not_intersect;
 j pls_integer := pg_org.struct.first;
 diff_grp tn;
begin --no checks, already made in CAN_EXT_GROUPS_INTERSECT
 if pg_ext1.grp_id is null then return rc; end if;
 for i in 1..pg_ext1.struct.count loop
  if pg_ext1.struct(i).ordno=pg_org.struct(j).ordno then
   wrk := levels_intersect(pg_org.struct(j).members, pg_ext1.struct(i).members);
   j := i;
   exit;
  end if;
 end loop;
 if j is null then raise dup_val_on_index; end if; --this is impossible;
 if wrk = groups_not_intersect then
  return rc;
 end if;
 select * bulk collect into diff_grp
  from table(pg_org1.all_members)
 minus
 select *
  from table(pg_org.all_members);
 if diff_grp.count=0 then
  rc := groups_enclosed_1to2;
  select * bulk collect into diff_grp
   from table(pg_org.all_members)
  minus
  select *
   from table(pg_org1.all_members);
  if diff_grp.count=0 then
   rc := groups_equivalent;
  end if;
  return rc;
 end if;
 rc := groups_enclosed_1to2;
 for i in 1..diff_grp.count loop
  wrk := is_ext_group_in_members(diff_grp(i), pg_org.all_members);
  if wrk=0 then
   rc := groups_intersect;
   exit;
  end if;
 end loop;
 return rc;
end;
--------------------------------------------------------------------------------------
function if_all_groups(pg_ext parsed_group_type, pg_ext1 parsed_group_type) return pls_integer is
 rc pls_integer := groups_not_intersect;
begin
 if pg_ext.grp_id is null then return rc; end if;
 for i in 1..pg_ext.struct.count loop
  if i=1 then
   if pg_ext.struct(i).dim_lev_id is null then rc := rc + groups_enclosed_2to1; end if;
   if pg_ext1.struct(i).dim_lev_id is null then rc := rc + groups_enclosed_1to2; end if;
  end if;
  exit;
 end loop;
 return rc;
end;
--------------------------------------------------------------------------------------
function get_greater_grp_no(pg_org parsed_group_type, pg_org1 parsed_group_type) return pls_integer is
 greater_grp_no pls_integer;
 i0 pls_integer := pg_org.struct.first;
 i1 pls_integer := pg_org1.struct.first;
begin
 while (i0 is not null) loop
  if i1 is null then
   greater_grp_no := 1;
  end if;
  if pg_org.struct(i0).ordno<pg_org1.struct(i1).ordno then
   greater_grp_no := 1;
  elsif pg_org.struct(i0).ordno>pg_org1.struct(i1).ordno then
   greater_grp_no := 2;
  else
   if pg_org.struct(i0).members.count>pg_org1.struct(i1).members.count then
    greater_grp_no := 1;
   elsif pg_org.struct(i0).members.count<pg_org1.struct(i1).members.count then
    greater_grp_no := 2;
   end if;
  end if;
  exit when greater_grp_no is not null;
  i0 := pg_org.struct.next(i0);
  i1 := pg_org1.struct.next(i0);
 end loop;
 if greater_grp_no is null then
   greater_grp_no := 2;
 end if;
 return greater_grp_no;
end;
--------------------------------------------------------------------------------------
function are_groups_intersect(pg_org parsed_group_type,
  pg_ext parsed_group_type, pg_org1 parsed_group_type, pg_ext1 parsed_group_type) return pls_integer is
 rc pls_integer;
 greater_grp_no pls_integer;
begin
-- if nvl(pg_org.dim_id, -1)<>nvl(pg_org1.dim_id, -1) then --invalid!!! A cycle after check on not-empty group!
--   errors.raise_err(err_not_same_dim, constants.qry_task, pg_org.dim_id, pg_org1.dim_id);
-- end if;
 rc := if_all_groups(pg_ext, pg_ext1); --now check only 'All' groups
 if rc in (groups_not_intersect) then
  greater_grp_no := get_greater_grp_no(pg_org, pg_org1);
  if greater_grp_no=1 then
   rc := can_groups_intersect(pg_org, pg_ext1, pg_org1);
  elsif greater_grp_no=2 then
   rc := can_groups_intersect(pg_org1, pg_ext, pg_org);
   if rc=groups_enclosed_1to2 then rc := groups_enclosed_2to1;
   elsif rc=groups_enclosed_2to1 then rc := groups_enclosed_1to2;
   end if;
  end if;
 end if;
 return rc;
end;
--------------------------------------------------------------------------------------
function are_groups_intersect(grp_id1 groups.id%type, grp_id2 groups.id%type) return pls_integer is
 pg_org1 parsed_group_type;
 pg_org2 parsed_group_type;
 pg_ext1 parsed_group_type;
 pg_ext2 parsed_group_type;
begin
 parse_group(grp_id1, pg_org1);
 parse_group(grp_id2, pg_org2);
 get_parse_group_ext(pg_org1, pg_ext1);
 get_parse_group_ext(pg_org2, pg_ext2);
 return are_groups_intersect(pg_org1, pg_ext1, pg_org2, pg_ext2);
end;
--------------------------------------------------------------------------------------
function is_group_intersect(id_ groups.id%type) return pls_integer is
 rc pls_integer := groups_not_intersect;
 rc_loc pls_integer;
 pgs_org parsed_group_types;
 pgs_ext parsed_group_types;
 ii pls_integer;
 jj pls_integer;
begin
 for i in (select id from grp_tree where parent_id=id_) loop
  pgs_org(i.id) := null;
  parse_group(i.id, pgs_org(i.id));
  pgs_org(i.id) := normalize(pgs_org(i.id));
--write_log.log_message(print_parsed_group(pgs_org(i.id)));
  pgs_ext(i.id) := null;
  get_parse_group_ext(pgs_org(i.id), pgs_ext(i.id));
--write_log.log_message(print_parsed_group(pgs_ext(i.id)));
 end loop;
 ii := pgs_org.first;
 while (ii is not null) loop
  jj := pgs_org.next(ii);
  while (jj is not null) loop
   if pgs_org(ii).leafs_only and pgs_org(ii).grp_id<0 --to exclude only real members, not groups with members,
      and pgs_ext(jj).leafs_only and pgs_ext(jj).grp_id<0 then -- which content can coincide
    rc_loc := groups_not_intersect;
   else
    rc_loc := are_groups_intersect(pgs_org(ii), pgs_ext(ii), pgs_org(jj), pgs_ext(jj));
   end if;
   if rc_loc<>groups_not_intersect then
    rc := groups_intersect;
    exit;
   end if;
   jj := pgs_org.next(jj);
  end loop;
  ii := pgs_org.next(ii);
 end loop;
 return rc;
end;
--------------------------------------------------------------------------------------
procedure check_grp_priv_basic(igp groups.is_grp_priv%type, rc_ pls_integer := null) is
 rc pls_integer := nvl(to_number(rc_), check_grp_priv_basic(IGP));
begin
 if rc=0 then
  errors.raise_err(24, Constants.qry_task, sys_utils.curr_osuser, '', '', TRUE, TRUE);
 end if;
end;
--------------------------------------------------------------------------------------
function check_grp_priv_basic(igp groups.is_grp_priv%type) return pls_integer is
 rc pls_integer := 1;
begin
 if igp!=sys_utils.curr_osuser and not tools4user.am_i_adm(tools4user.opal_flag) then
  rc := 0;
 end if;
 return rc;
end;
--------------------------------------------------------------------------------------
procedure check_grp_priv(id_ groups.id%type) is
 rc pls_integer := check_grp_priv(id_);
begin
 check_grp_priv_basic('', rc);
end;
--------------------------------------------------------------------------------------
function check_grp_priv(id_ groups.id%type) return pls_integer is
 rc pls_integer := 1;
begin
 for c in (select cr_user from groups where id=id_ and is_grp_priv=ANALYZER.is_private_no) loop
  rc :=  check_grp_priv_basic(c.cr_user);
  exit;
 end loop;
 return rc;
end;
end;
/