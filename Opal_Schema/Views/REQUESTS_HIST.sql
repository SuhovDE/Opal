--
-- REQUESTS_HIST  (View) 
--
--  Dependencies: 
--   DATAHEADER (Synonym)
--   DB$MONITOR_TASKS (Synonym)
--   DB$MONITOR_TASKS_REQ (Synonym)
--   MONITOR_TASKS_INFO (Synonym)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.REQUESTS_HIST
(REQUEST_DATE, PARAM_LIST, ID, EXECDATE, DURATION, 
 EXITCODE, OSUSER, LOAD_END_DATE, START_TYPE, RECNO)
BEQUEATH DEFINER
AS 
select request_date, param_list, id, execdate, duration, exitcode, osuser, load_end_date, monitor_tasks_info.get_start_type_descr(start_type) start_type, recno
from (
select r.REQDATE request_date, r.REQPRMS param_list, t.id, t.EXECDATE, t.DURATION, t.exitcode, nvl(r.DBG$OSUSR, t.DBG$OSUSR) osuser,
  d.load_end_date, nvl2(r.id, 2, 1) start_type, recno
 from DB$MONITOR_TASKS t left outer join DB$MONITOR_TASKS_REQ r on t.id=r.taskid join dataheader d on t.ID=d.taskid
 where t.name='OPAL_EXPIMP'
union all
select export_date, params, taskid, export_date, round(to_number(cast(load_end_date as date)-export_date)*86400*1000), to_number(rc), osuser, load_end_date, 0, recno
 from dataheader where taskid is null
);