--
-- DO_GRP_FLAT  (Package Body) 
--
--  Dependencies: 
--   DO_GRP_FLAT (Package)
--   CONSTANTS (Package)
--   DIM_LEVELS (Table)
--   GROUPS (Table)
--   GROUPS_FNC (Package)
--   GROUPS_GL (Table)
--   GRP_D (Table)
--   GRP_TAB_FLAT (Table)
--   GRP_TREE (Table)
--   S_GRP_TREE (Sequence)
--   TREE_FNC (Package)
--   PLITBLM (Synonym)
--   STANDARD (Package)
--
CREATE OR REPLACE PACKAGE BODY OPAL_FRA."DO_GRP_FLAT" as
 gl_ids groups_fnc.nums;
--------------------------------------------------------------------------------
procedure on_delete(id_ grp_tree.id%type, pid_ grp_tree.parent_id%type) is
begin
 delete groups_gl where pid=pid_ and id=id_;
end;
--------------------------------------------------------------------------------
procedure on_insert(id_ grp_tree.id%type, pid_ grp_tree.parent_id%type,
  ord_ grp_tree.ordno_in_root%type, date_from_ grp_tree.date_from%type, date_to_ grp_tree.date_to%type) is
 gl_id_ groups_gl.GL_ID%type;
 procedure to_gl(id_ grp_tree.id%type, pid_ grp_tree.parent_id%type,
   ord_ grp_tree.ordno_in_root%type, date_from_ grp_tree.date_from%type, date_to_ grp_tree.date_to%type) is
  gl_pid_ groups_gl.gl_pid%type;
  fid_ groups_gl.fid%type;
 begin
  if pid_ is not null then
   gl_pid_ := gl_ids(pid_);
   if pid_ <> tree_fnc.root_not_d then
    select nullif(max(id), tree_fnc.root_not_d) into fid_ from (
     select pid, id from  groups_gl
      start with gl_id=gl_pid_
      connect by gl_id=prior gl_pid
     ) where pid=tree_fnc.root_not_d;
   end if;
  end if;
  for cc in (select * from grp_tree where id=id_ and parent_id=pid_ and nvl(date_from, constants.doomsday)=nvl(date_from_, constants.doomsday)) loop
   insert into groups_gl(ID, PID, GL_ID, GL_PID, ORDNO_IN_ROOT, fid, allrest, date_from, date_to)
    values(id_, pid_, s_grp_tree.nextval,
      gl_pid_, ord_, nvl(fid_, id_), cc.allrest, cc.date_from, cc.date_to)
    returning gl_id into gl_id_;
   exit;
  end loop;
  gl_ids(id_) := gl_id_;
 end;
begin
 if pid_ is null then
  to_gl(id_, pid_, ord_, date_from_, date_to_);
  return;
 end if;
 if pid_<0 then return; end if;
 for c in (select * from groups_gl where id=pid_) loop
  gl_ids.delete;
  gl_ids(c.id) := c.gl_id;
  to_gl(id_, pid_, ord_, date_from_, date_to_);
  if id_>0 then
   for d in (select id, parent_id, ordno_in_root, date_from, date_to from grp_tree
              start with parent_id=id_
			  connect by prior id=parent_id and parent_id>=0
			  order siblings by ordno_in_root) loop
	   to_gl(d.id, d.parent_id, d.ordno_in_root, d.date_from, d.date_to);
   end loop;
  end if;
 end loop;
end;
------------------------------------------------------------------------------------
procedure fill_grp_tab(grp_id_ groups.id%type) is
 longcode varchar2(50);
begin
--write_log.log_message('start');
 delete grp_tab_flat where grp_id=grp_id_;
 FOR l IN (SELECT --+index(t) index(g)
             t.ID grp_id, g.abbr code, t.ordno_in_root ordno
            FROM GRP_TREE t, GROUPS g WHERE
 	       parent_id=grp_id_ AND t.ID=g.ID ORDER BY t.ordno_in_root) LOOP
  longcode := l.code;
  groups_fnc.prefix_group_code(longcode, l.ordno);
--write_log.log_message(l.grp_id||' '||longcode);
  if l.grp_id between -1 and -99 then --if inside, do at the moment nothing
   insert into grp_tab_flat(CODE, GRP_ID, VAL) values('%', l.grp_id, longcode);
  else
  for gg in (
    SELECT DISTINCT gt.ID, g.dim_lev_id, g.dim_lev_code, gr.dim_id, d.storage_type
     FROM (
      SELECT --+index(t I_GRP_TREE_P)
	       t.*, LEVEL lvl
       FROM GRP_TREE t
       START WITH ID=l.grp_id
       CONNECT BY PRIOR ID=parent_id AND NVL(parent_id, 0)>=-99
    ) gt, GRP_D g, GROUPS gr, DIM_LEVELS d
    WHERE gt.ID=g.grp_id AND gt.ID=gr.ID AND g.dim_lev_id=d.ID(+)) loop
--write_log.log_message(gg.id||' '||gg.dim_lev_code);
   insert into grp_tab_flat(CODE, GRP_ID, VAL)
    with qry as
    (SELECT --+index(t I_GRP_TREE_P)
	     id, parent_id
     FROM GRP_TREE t
     START WITH ID=gg.id
     CONNECT BY PRIOR ID=parent_id)
     select distinct p.dim_lev_code, grp_id_, longcode from (
    select id from qry
    minus
    select parent_id from qry) a, grp_d p
     where grp_id=id
   ;
  end loop;
  end if;
 end loop;
--write_log.log_message('end');
end;
end;
/