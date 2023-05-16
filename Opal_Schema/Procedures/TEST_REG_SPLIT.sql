--
-- TEST_REG_SPLIT  (Procedure) 
--
--  Dependencies: 
--   PARAMS (Table)
--   GROUP_DIM_TREE_TAB (Table)
--   REF_PROCESS (Synonym)
--   UTILS (Synonym)
--   PLITBLM (Synonym)
--   STANDARD (Package)
--   SYS_STUB_FOR_PURITY_ANALYSIS (Package)
--
CREATE OR REPLACE procedure OPAL_FRA.test_reg_split as
type codtree is record(code varchar2(30), id binary_integer, pid binary_integer);
type codtreetab is table of codtree;
 maxtreelen pls_integer := utils.get_par('MAXTREELEN', 'GEN', 300);
 minsubno pls_integer := utils.get_par('MINSUBNO', 'GEN', 2);
 cursor ll is
  select parent_id, dim_id, dim_lev_id, count(*) oldtreelen, ordno,
   (select code from group_dim_tree_tab where grp_id=g.parent_id) code
  from group_dim_tree_tab g
  where parent_id is not null and dim_lev_id=109
  group by parent_id, dim_id, dim_lev_id, ordno
  having count(*)>maxtreelen
  order by dim_id, dim_lev_id, parent_id;
 to_split codtreetab;
 new_codes codtreetab;
procedure putsublevels(to_split in out codtreetab,
  new_codes in out codtreetab, parent_id pls_integer,
  treelen pls_integer) is
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
 dev_up constant number := 0.2;
 dev_up1 constant number := 0.3;
 put_new_codes boolean;
 is_moved_forward boolean;
 nci pls_integer;
 new_key_not_found boolean;
 last_code varchar2(30);
 cdev number;
 min_grp_id pls_integer;
 l1 pls_integer;
 l2 pls_integer;
begin
 if to_split.first is null then return; end if;
 new_codes := codtreetab();
 while indb is not null loop
  codb := to_split(indb).code;
  keyb := substr(codb, 1, clen);
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
    cdev := (inde-indb+1) * case when clen=1 then dev_up1 else dev_up end;
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
    cdev := (inde_old-indb+1) * case when clen-1=1 then dev_up1 else dev_up end/2;
    if cdev<=to_split.last-inde_old then exit; end if;
    l2 := to_split.last;
    for l in inde_old..l2 loop
	 l1 := l;
     if keye_old<>substr(to_split(l).code, 1, length(keye_old)) then
      inde := l-1;
      clen := clen-1;
 	 exit;
     elsif cdev<l-inde_old+1 then
      is_moved_forward := true;
 	 exit;
     end if;
    end loop;
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
 dim_ pls_integer, ordno_ pls_integer) is
begin
 if new_codes.first is null then return; end if;
 for i in new_codes.first..new_codes.last loop
  insert into group_dim_tree_tab(CODE, descr, GRP_ID, ordno,
    PARENT_ID, DIM_ID)
  values(new_codes(i).code, new_codes(i).code, new_codes(i).id, ordno_,
   new_codes(i).pid, dim_);
 end loop;
 for i in to_split.first..to_split.last loop
  update group_dim_tree_tab set parent_id=to_split(i).pid
   where grp_id=to_split(i).id;
 end loop;
end;
-----------------------------------------------------------------------------
begin
 for l in ll loop
  select code, grp_id, parent_id bulk collect into to_split
   from group_dim_tree_tab where parent_id=l.parent_id
   order by code;
  putsublevels(to_split, new_codes, l.parent_id,
   least(trunc(l.oldtreelen/minsubno)+1, maxtreelen));
  inssublevels(to_split, new_codes, l.parent_id, l.dim_id, l.ordno);
  commit;
 end loop;
end;

 
 
/