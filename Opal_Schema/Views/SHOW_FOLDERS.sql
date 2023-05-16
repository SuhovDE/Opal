--
-- SHOW_FOLDERS  (View) 
--
--  Dependencies: 
--   FOLDERS (Table)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_FOLDERS
(FOLDER_ID, PID, FOLDER_NAME, FOLDER_DESCR, IS_PREDEFINED)
BEQUEATH DEFINER
AS 
with /*recursive*/ ftree(ID, PID, ABBR, DESCR, SCODE) as (
 select f.ID, f.PID, f.ABBR, f.DESCR, f.SCODE
  from folders f where f.pid is null
 union all
 select f.ID, f.PID, f.ABBR, f.DESCR, f.SCODE
  from folders f join ftree ft on ft.id=f.pid
)
select ID folder_id, PID, ABBR folder_name, DESCR folder_descr, case when scode is null then 0 else 1 end is_predefined
 from ftree;