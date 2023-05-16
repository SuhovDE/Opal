--
-- QRY_HIST  (View) 
--
--  Dependencies: 
--   HIST_ALL (Synonym)
--   QRYS (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.QRY_HIST
(QUERYID, OP_TERM, OP_TIME, ABBR, USER_OP, 
 COL_NAME, OLD_V, NEW_V, ID_HIST)
BEQUEATH DEFINER
AS 
select q.id queryid, op_term, op_time, pkc abbr, 'EXECUTE' user_op,
    null col_name, to_clob(null) old_v,
    to_clob(max(case when col_name='DURATION' then 'DURATION: '||new_v end)||chr(13)||chr(10)||
    max(case when col_name='RECCOUNT' then 'RECCOUNT: '||new_v end)) new_v, max(h.id) id_hist
   from hist_all h join qrys q on h.ppk=q.org_id
   where table_name='QRYS' and col_name in ('DURATION', 'RECCOUNT')
   and not (h.ppk=h.pk and exists(select 1 from hist_all where ppk=h.ppk and pk<>h.pk and abs(op_time-h.op_time)<=1/86400))
   group by h.id, op_term, op_time, q.id, pkc
union all
  select q.id queryid, op_term, op_time, pkc abbr, nvl(user_op, 'CHANGE') user_op,
    col_name, to_clob(old_v) old_v, to_clob(new_v) new_v, h.id id_hist
   from hist_all h join qrys q on h.ppk=q.org_id
   where table_name='QRYS' and nvl(col_name, '-') not in ('DURATION', 'RECCOUNT') and new_lob is null
union all
  select q.id queryid, op_term, op_time, pkc abbr,
    case when length(old_lob)>0 then replace(nvl(user_op, 'UPDATED'), 'SAVE', 'UPDATED') else 'CREATE' end || case when pk<>ppk then ' UNSAVED' end user_op,
    col_name, old_lob old_v, new_lob new_v, h.id id_hist
   from hist_all h join qrys q on h.ppk=q.org_id and q.tmp is null
   where table_name='QRYS' and new_lob is not  null
    and exists(select 1 from qrys where id=h.pk);