--
-- SHOW_FOLDERS_  (View) 
--
--  Dependencies: 
--   FOLDERS (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_FOLDERS_
(FOLDER_ID, PID, FOLDER_NAME, FOLDER_DESCR, IS_PREDEFINED)
BEQUEATH DEFINER
AS 
with ftree(folder_id, pid, folder_name, folder_descr, is_predefined) as (
 select f.id folder_id, f.pid, f.abbr folder_name, f.descr folder_descr, case when f.scode is null then 0 else 1 end is_predefined
  from folders f where f.pid is null
 union all
 select f.id folder_id, f.pid, f.abbr folder_name, f.descr folder_descr, case when f.scode is null then 0 else 1 end is_predefined
  from folders f join ftree ft on ft.folder_id=f.pid  
) 
select "FOLDER_ID","PID","FOLDER_NAME","FOLDER_DESCR","IS_PREDEFINED"
 from ftree;