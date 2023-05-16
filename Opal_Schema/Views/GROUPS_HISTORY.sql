--
-- GROUPS_HISTORY  (View) 
--
--  Dependencies: 
--   GROUPS (Table)
--   HIST_ALL (Synonym)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.GROUPS_HISTORY
(MEMBER_ID, GRP_ID, OP, OP_TERM, OP_TIME, 
 COL_NAME, OLD_V, NEW_V, GRP_CODE, MEMBER_CODE, 
 ID_HISTORY)
BEQUEATH DEFINER
AS 
select pk member_id, ppk grp_id,
  case
   when h.op='I' then case when h.user_op is null then 'created'  else concat(lower(h.user_op), ' added') end
   when h.op='U' then concat(h.col_name, ' updated')
   when h.op='D' then case when h.user_op is null then 'deleted' else concat(lower(h.user_op), ' deleted') end
  end op,
  op_term, op_time, col_name, old_v, new_v, gm.abbr grp_code,
  case when h.pk<>h.ppk then coalesce(g.abbr, (select old_v from hist_all where ppk=h.pk and op='D' and col_name='CODE')) end member_code,
  h.id id_history
 from hist_all h join groups gm on h.ppk=gm.id left outer join groups g on h.pk=g.id  and h.ppk<>h.pk
 where table_name='GROUPS'
 order by h.id;