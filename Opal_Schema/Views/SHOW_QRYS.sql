--
-- SHOW_QRYS  (View) 
--
--  Dependencies: 
--   FOLDERS (Table)
--   GET_CONST (Function)
--   GRANTS4USER (Synonym)
--   QRYS (Table)
--   QRYS2FOLDERS (Table)
--   SHOW_CUBES_ (View)
--
CREATE OR REPLACE FORCE VIEW OPAL_FRA.SHOW_QRYS
(FOLDER_ID, ID, QRY_TYPE, CUBE_ID, WHERE_ID, 
 HAVING_ID, ABBR, SHORT, PREDEFINED, SETTINGS, 
 CR_USER, UP_USER, EX_USER, CR_TERM, UP_TERM, 
 EX_TERM, CR_TIME, UP_TIME, EX_TIME, DURATION, 
 RECCOUNT, CR_HOST, UP_HOST, EX_HOST, TMP, 
 IS_PRIVATE, LAYOUT)
BEQUEATH DEFINER
AS 
select FOLDER_ID,ID,QRY_TYPE,CUBE_ID,WHERE_ID,HAVING_ID,ABBR,SHORT,PREDEFINED,
 SETTINGS, CR_USER,UP_USER,EX_USER,CR_TERM,UP_TERM,EX_TERM,CR_TIME,UP_TIME,EX_TIME,
 DURATION,RECCOUNT,CR_HOST,UP_HOST,EX_HOST,TMP, is_private, LAYOUT
from (
select f.folder_id, q.*
from qrys2folders f, qrys q
 where f.qry_id=q.id
union all
select (select id from folders where scode=get_const('root_folder')), q.*
from qrys q
 where not exists(select 1 from qrys2folders where qry_id=q.id)
)
where tmp is null and cube_id in (select id from show_cubes_);