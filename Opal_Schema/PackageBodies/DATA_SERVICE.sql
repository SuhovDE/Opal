--
-- DATA_SERVICE  (Package Body) 
--
--  Dependencies: 
--   DATA_SERVICE (Package)
--   PARAMS (Table)
--   DIMS (Table)
--   DIM_LEVELS (Table)
--   ERROR_CODES (Package)
--   GROUPS (Table)
--   GROUPS_NOT_FROM_D (View)
--   GROUP_DIM_TREE (View)
--   GROUP_DIM_TREE_TAB (Table)
--   GRP_D (Table)
--   GRP_TREE (Table)
--   HIST4USER (Synonym)
--   HIST_ALL (Synonym)
--   LANG_UTILS (Package)
--   QRYS (Table)
--   QUERYOBJ (Type)
--   REF_PROCESS (Synonym)
--   RS_CODES4DIMS (Table)
--   TREE_FNC (Package)
--   UTILS (Synonym)
--   WRITE_LOG (Synonym)
--   ALL_TAB_COLS (Synonym)
--   DUAL (Synonym)
--   PLITBLM (Synonym)
--   XMLTYPE (Synonym)
--   DBMS_STANDARD (Package)
--   STANDARD (Package)
--
CREATE OR REPLACE PACKAGE BODY OPAL_FRA.DATA_SERVICE as
type codtree is record(code varchar2(30), id binary_integer, pid binary_integer);
type codtreetab is table of codtree;
dummy_dim_tab constant varchar2(30) := 'DUAL';
split_by_size constant dim_levels.SPLIT_MODE%type := '1';
split_by_char constant dim_levels.SPLIT_MODE%type := '2';
-----------------------------------------------------------------------------
function get_qry_lob(querydata XMLType) return clob is
 res clob;
begin
 select xmlserialize(content deletexml(deletexml(querydata, 'QUERYOBJ/SETTINGS'), 'QUERYOBJ/LAYOUT') indent) into res from dual;
 return res;
end;
-----------------------------------------------------------------------------
procedure qry2hist(querydata QUERYOBJ, queryid qrys.id%type) is
begin
 qry2hist(XMLType(querydata), queryid);
end;
-----------------------------------------------------------------------------
 procedure mark_qry_op(queryid qrys.id%type, op_ hist_all.user_op%type) is
  org_id_ qrys.org_id%type;
  abbr_ qrys.abbr%type;
begin
 select org_id, abbr into org_id_, abbr_ from qrys where id=queryid;
 hist4user.save_user_op('QRYS', queryid, org_id_, op_, abbr_);
end;
-----------------------------------------------------------------------------
 procedure mark_qry_exp(queryid qrys.id%type) is
 begin
  mark_qry_op(queryid, 'EXPORT');
 end;
-----------------------------------------------------------------------------
 procedure mark_qry_imp(queryid qrys.id%type) is
 begin
  mark_qry_op(queryid, 'IMPORT');
 end;
-----------------------------------------------------------------------------
procedure qry2hist(querydata XMLType, queryid qrys.id%type) is
 org_id_ qrys.org_id%type;
 abbr_ qrys.abbr%type;
begin
 select org_id, abbr into org_id_, abbr_ from qrys where id=queryid;
 for c in (select id, new_lob from hist_all where table_name='QRYS' and ppk=org_id_ and new_lob is not null
            union all
           select null, null from dual
           order by 1 desc nulls last
          ) loop
   hist4user.save_lob('QRYS', queryid, org_id_, c.new_lob, get_qry_lob(querydata), abbr_);
  exit;
 end loop;
end;
-----------------------------------------------------------------------------
procedure ins_dummy_groups is
begin
 insert into groups(ID, PREDEFINED, GRP_TYPE, abbr, short, TYPE_ID)
  select tree_fnc.root_not_d, tree_fnc.is_predefined, tree_fnc.attr_group,
   'ROOT', 'Root for all groups',  0 --Dummy type, used only here
  from dual where not exists(select 1 from groups where id=tree_fnc.root_not_d);
 update (select parent_id from grp_tree t, groups_not_from_d  g where t.id=g.id)
  set parent_id=tree_fnc.root_not_d
  where parent_id is null;
end;
-----------------------------------------------------------------------------
procedure ins_dims2groups is
 s varchar2(4000) := 'ins_dummy';
 s1 varchar2(4000);
 sf varchar2(4000);
 storage_kind pls_integer; --1 - all the dim in the only table, where columns for down levels are null
 levno pls_integer;
 name_all constant varchar2(15) := lang_utils.all_value;
 grp_name varchar2(200);
 name_all_res varchar2(30);
 dim_lev_id_ dim_levels.id%type;
 is_dim pls_integer;
 spid varchar2(30);
 tmp pls_integer;
 name_local constant varchar2(30) := 'NAME_LOCAL';
begin
 ins_dummy_groups;
 for d in (select * from dims d where exists(select 1 from dim_levels where
   dim_id=d.id and tab_name<>dummy_dim_tab) order by id) loop
  select count(*) into is_dim from groups where id=-d.id and rownum=1;
  if is_dim=0 then
   name_all_res := utils.shorten_name(name_All, d.abbr, tree_fnc.abbr_len);
   s := name_all_res;
 --dbms_output.put_line(s);
   select max(id) keep(dense_rank last order by ordno) into dim_lev_id_
    from dim_levels where dim_id=d.id;
   insert into groups(ID, PREDEFINED, GRP_TYPE, IS_LEAF, short, abbr, TYPE_ID, DIM_ID, dom_id)
    values(-d.id, tree_fnc.is_dimension, tree_fnc.dim_group, null,
     name_all_res, nvl(d.short, name_All||d.abbr),
	    dim_lev_id_, d.id, d.dom_id);
   insert into grp_tree(id) values(-d.id);
  end if;
  select count(*), count(distinct tab_name) into levno, storage_kind
    from dim_levels where dim_id=d.id;
  if not (levno>1 and storage_kind=1) then storage_kind := 0; end if;
  s := null;
  for l in (select DIM_ID, ORDNO, ID, abbr, TAB_NAME, COL_NAME, PARENT_COL_NAME, COL_IN_DIMS, scode,
	   min(ordno) over(partition by dim_id) minordno,
      (select colname from rs_codes4dims where dim_lev_id=id and attr_type_code='NAME') name_col_name
     from dim_levels where dim_id=d.id order by minordno, ordno) loop --minordno here to bypass an Oracle error in 10.2.0.3
--    if is_dim=0 then
--     delete group_levels where grp_id=-d.id and ordno=l.ordno+1;
--    end if;
    if lang_utils.lang<>lang_utils.lang_def then
     select count(*) into tmp from all_tab_cols where table_name=l.tab_name and column_name=NAME_LOCAL;
     if tmp>0 then
      l.name_col_name := name_local;
     end if;
    end if;
    s1 := null;
    sf := ' from '||l.tab_name||' tbl where '||l.col_name||' is not null and id is not null';
    if l.ordno<>l.minordno then
     sf := sf||' and pid is not null';
    end if;
    if storage_kind=1 then
     for sl in (select col_name from dim_levels where dim_id=d.id and ordno>l.ordno) loop
      s1 := s1||' and '||sl.col_name||' is null';
     end loop;
        sf := sf||s1;
    end if;
    grp_name := l.col_name;
    if l.scode='DELAYCODE_SUB' then
     grp_name := grp_name||'||''-''||code';
    end if;
   if d.add_dim is not null then
    grp_name := 'substr('||grp_name||'||'' '||l.abbr||''', 1, '||
      least(tree_fnc.abbr_len*2, 40)||')';
   end if;
   s := 'merge into groups g using (select id,'||grp_name||' grp_name,'
	  ||nvl(l.name_col_name, '''''')||' grp_descr'
	  ||sf||') s '||chr(10)||' on (g.id=s.id) when matched then '||chr(10)||
	    'update set g.suf=s.grp_name, g.abbr=s.grp_name, g.short=s.grp_descr'||
		' when not matched then '||chr(10)||
        'insert (ID, PREDEFINED, GRP_TYPE, IS_LEAF, suf, abbr, short, '||
		'TYPE_ID, DIM_ID, dom_id) values (s.id, '''||
		tree_fnc.is_dimension||''', '''||tree_fnc.dim_group||''', 1, s.grp_name, s.grp_name, s.grp_descr'||
		', '||l.id||', '||d.id||', '||d.dom_id||')';
--dbms_output.put_line(s);
--insert into test_qry values(s,l.id);
--commit;
	execute immediate s;
    s := 'merge into grp_d g using (select id,'||l.col_name||' grp_name'||chr(10)||
      sf||') s on (g.grp_id=s.id) '||chr(10)||'when matched then '||chr(10)||
	  'update set g.dim_lev_code=s.grp_name '||chr(10)||
      'when not matched then '||chr(10)||
      'insert(GRP_ID, DIM_LEV_ID, DIM_LEV_CODE) values(s.id, '||l.id||
	     ', s.grp_name)';
--insert into test_qry values(s,l.id);
--commit;
--dbms_output.put_line(s);
	execute immediate s;
	spid := 'tbl.pid';
	if l.ordno=l.minordno then spid := to_char(-d.id); end if;
 if l.ordno=2 then spid := 'nvl(tbl.pid, '||to_char(-d.id)||')'; end if; --at the moment dirty trick for AIRLINES
    delete grp_tree where (parent_id<0 or parent_id is null) and
	  exists(select 1 from grp_d where grp_id=id and dim_lev_id=l.id);
    s :='insert into grp_tree(ID, PARENT_ID) '
  ||' select id, parent_id from ('
	 ||'select id, '||spid||' parent_id'
	 ||sf/*||' and not exists(select 1 from grp_tree where id=tbl.id and '
	 ||'nvl(parent_id,0)=nvl('||spid||', 0))'*/
  ||') where parent_id is not null';
--dbms_output.put_line(s);
	execute immediate s;
  end loop;
 end loop;
 commit;
exception
when others then
s := s||':'||sqlerrm;
rollback;
raise_application_error(Error_codes.FIELD_FORMAT_IS_WRONG_N, s, true);
end;
-----------------------------------------------------------------------------
procedure dim_tree2tab is
begin
 execute immediate 'truncate table group_dim_tree_tab';
 insert into group_dim_tree_tab(CODE, DESCR, GRP_ID, ordno,
    PARENT_ID, DIM_ID, DIM_LEV_ID, predefined, grp_type, lev, RN, dom_id, date_from, date_to)
 select
    g.dim_lev_code code, g.short descr, g.id grp_id,
    g.ordno, g.parent_id, g.dim_id, g.dim_lev_id, predefined,
	grp_type, lev, rownum rn, g.dom_id, g.date_from, g.date_to
 from group_dim_tree g;
 commit;
 dim_tree2tab_split;
end;
-----------------------------------------------------------------------------
procedure putsublevels(to_split in out codtreetab,
  new_codes in out codtreetab, parent_id pls_integer,
  treelen pls_integer, split_mode dim_levels.SPLIT_MODE%type := split_by_size) is
 keyb varchar2(30);
 keye varchar2(30);
 keye_old varchar2(30);
 codb varchar2(30);
 code varchar2(30);
 code_old varchar2(30);
 clen pls_integer:=1;
 indb pls_integer := to_split.first;
 inde pls_integer;
 inde_old pls_integer;
 dev_up constant number := 0.6;
 dev_up1 constant number := 1.0;
 put_new_codes boolean;
 is_moved_forward boolean;
 nci pls_integer;
 new_key_not_found boolean;
 last_code varchar2(30);
 cdev number;
 cdevmult number;
 min_grp_id pls_integer;
begin
 if to_split.first is null then return; end if;
 new_codes := codtreetab();
 while indb is not null loop
  codb := to_split(indb).code;
  keyb := substr(codb, 1, clen);
  if split_mode=split_by_size then
   inde := least(indb + treelen-1, to_split.last);
   inde_old := inde;
   code := to_split(inde).code;
   code_old := code;
   keye := substr(code, 1, clen);
   if inde=to_split.last then
    put_new_codes := true;  --Final action
   else
    put_new_codes := false;
    new_key_not_found := true;
    for l in 1..length(code) loop
     if substr(codb, 1, l)<>substr(code, 1, l) or l>length(codb) then
      clen := l; new_key_not_found := false;
      exit;
     end if;
    end loop;
    if new_key_not_found then raise dup_val_on_index; end if; --clean the signal. The situation is impossible
   end if;
   if not put_new_codes then
    while not put_new_codes loop
     keye := substr(code, 1, clen);
	 cdevmult := case when clen=1 then dev_up1 else dev_up end/2;
     if inde=to_split.last and inde-indb<=treelen*(1+cdevmult) then exit; end if;
     cdev := (inde-indb+1) * cdevmult;
	 if inde=to_split.last and inde-indb<=treelen then exit; end if;
     for l in reverse indb+1..inde loop
      if keye<>substr(to_split(l).code, 1, clen) then
       inde := l;
 	   put_new_codes := true;
 	   exit;
      elsif cdev<inde_old-l+1 then
 	   clen := clen + 1;
 	  exit;
 	  end if;
     end loop;
     if clen>length(code) then raise PROGRAM_ERROR; end if;
    end loop;
    is_moved_forward := false;
    while not is_moved_forward and clen>1 loop
     keye_old := substr(to_split(inde_old).code, 1, clen-1);
     cdevmult := case when clen=1 then dev_up1 else dev_up end/2;
	 if inde=to_split.last and inde-indb<=treelen * (1+cdevmult) then exit; end if;
     cdev := (inde_old-indb+1) * cdevmult;
     for l in inde_old..to_split.last loop
      if keye_old<>substr(to_split(l).code, 1, length(keye_old)) then
       inde := l-1;
       clen := clen-1;
 	   exit;
      elsif cdev<l-inde_old+1 or l=to_split.last then
       is_moved_forward := true;
 	   exit;
      end if;
     end loop;
    end loop;
   end if;
  else
   inde := indb;
   while to_split.next(inde) is not null loop
    nci := to_split.next(inde);
    keye := substr(to_split(nci).code,1,1);
    exit when keye<>keyb;
	inde := nci;
   end loop;
  end if;
  new_codes.extend;
  nci := new_codes.last;
  min_grp_id := ref_process.get_dim_id;
  new_codes(nci).id := min_grp_id;
  new_codes(nci).pid := parent_id;
  for l in indb..inde loop to_split(l).pid := min_grp_id; end loop;
  indb := to_split.next(inde);
  new_codes(nci).code := keyb;
  keye:=substr(to_split(inde).code, 1, clen);
  if keyb<>keye then
   new_codes(nci).code := new_codes(nci).code ||'-';
   if indb is not null then
    if keyb>keye then keye := substr(to_split(inde).code, 1, length(keyb)); end if;
    new_codes(nci).code := new_codes(nci).code ||keye;
   end if;
  end if;
 end loop;
end;
-----------------------------------------------------------------------------
procedure inssublevels(to_split in out codtreetab,
 new_codes in out codtreetab, parent_id pls_integer,
 dim_ pls_integer, ordno_ pls_integer, dom_ pls_integer) is
 type tids is table of pls_integer;
 ids tids := tids();
 pids tids := tids();
begin
 if new_codes.first is null then return; end if;
 for i in new_codes.first..new_codes.last loop
  insert into group_dim_tree_tab(CODE, descr, GRP_ID, ordno,
    PARENT_ID, DIM_ID, dom_id)
  values(new_codes(i).code, new_codes(i).code, new_codes(i).id, ordno_,
   new_codes(i).pid, dim_, dom_);
 end loop;
 for i in to_split.first..to_split.last loop
  ids.extend;
  pids.extend;
  ids(ids.last) := to_split(i).id;
  pids(pids.last) := to_split(i).pid;
 end loop;
 forall i in ids.first..ids.last
   update group_dim_tree_tab set parent_id=pids(i)
    where grp_id=ids(i);
end;
-----------------------------------------------------------------------------
procedure dim_tree2tab_split is
 maxtreelen pls_integer := utils.get_par('MAXTREELEN', 'GEN', 300);
 minsubno pls_integer := utils.get_par('MINSUBNO', 'GEN', 2);
 cursor ll is
  select parent_id, dim_id, dom_id, dim_lev_id, count(*) oldtreelen, ordno,
   (select code from group_dim_tree_tab where grp_id=g.parent_id) code
   from group_dim_tree_tab g
  where parent_id is not null
  group by parent_id, dim_id, dom_id, dim_lev_id, ordno
  having count(*)>maxtreelen
  order by dim_id, dim_lev_id, parent_id;
 to_split codtreetab;
 new_codes codtreetab;
 split_mode_ dim_levels.SPLIT_MODE%type;
begin
 lock table group_dim_tree_tab in exclusive mode;
-- dbms_session.set_nls('NLS_SORT', '''German'''); --to simulate FRA
 for c in (select grp_id, parent_id from group_dim_tree_tab
            where rn is null order by grp_id desc) loop
  update group_dim_tree_tab set parent_id=c.parent_id where parent_id=c.grp_id;
  delete group_dim_tree_tab where grp_id=c.grp_id;
 end loop;
 commit;
 for l in ll loop
  select code, grp_id, parent_id bulk collect into to_split
   from group_dim_tree_tab where parent_id=l.parent_id
   order by nlssort(code, 'NLS_SORT=BINARY');
  select nvl(max(split_mode), split_by_size) into split_mode_
   from dim_levels where id=l.dim_lev_id;
  putsublevels(to_split, new_codes, l.parent_id,
   least(trunc(l.oldtreelen/minsubno)+1, maxtreelen), split_mode_);
  inssublevels(to_split, new_codes, l.parent_id, l.dim_id, l.ordno, l.dom_id);
  commit;
 end loop;
end;
-----------------------------------------------------------------------------
 procedure delete_stray_groups is
  cursor ff is
  select id, g.abbr code, type_id from groups g where id<-100 and
   not exists(select 1 from grp_tree where id=g.id and parent_id<0)
  for update of g.id;
  dimname varchar2(255);
 begin
  for f in ff loop
  select nvl(max(d.abbr), 'Unknown') into dimname from dim_levels d
   where id=f.type_id;
  begin
    delete grp_tree where id=f.id;
    delete groups where id=f.id;
    write_log.log_message('Deleting stray code '||f.code ||', dimension '||dimname);
  exception
   when others then
    write_log.log_message('Error deleting code '||f.code ||', dimension '||dimname , sqlerrm, 3);
   end;
  end loop;
  commit;
 end;
-----------------------------------------------------------------------------
 procedure after_ref_load is
 begin
  delete_stray_groups;
  ins_dims2groups;
  dim_tree2tab;
 end;
-----------------------------------------------------------------------------
end;
/