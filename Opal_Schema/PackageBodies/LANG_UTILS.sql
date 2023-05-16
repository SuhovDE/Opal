--
-- LANG_UTILS  (Package Body) 
--
--  Dependencies: 
--   LANG_UTILS (Package)
--   ATTRS (Table)
--   ATTR_TYPES (Table)
--   CONSTANTS (Package)
--   DATA_SERVICE (Package)
--   DIMS (Table)
--   DIM_LEVELS (Table)
--   GROUPS (Table)
--   LANGUAGES (Table)
--   OBJ_COL_IDS (Table)
--   OBJ_COL_NAMES (Table)
--   OBJ_IDS (Table)
--   PARAMS (Table)
--   DUAL (Synonym)
--   STANDARD (Package)
--
CREATE OR REPLACE package body OPAL_FRA.lang_utils as
  namename constant varchar2(30) := 'NAME';
  namecode constant varchar2(30) := 'CODE';
  mu constant varchar2(1024) :=
   'a.%1%=nvl((select nvl(max(case when lang_id=:1 then %2% end), max(case when lang_id=:2 then %2% end)) from obj_col_names o where col_id=:3 and row_id=a.scode), a.%1%)';
  muu varchar2(1024);
function get_lang return languages.id%type deterministic is
begin
 return lang;
end;
function set_col(scol varchar2, dcol varchar2 := null) return varchar2 is
begin
 return replace(replace(muu, '%1%', nvl(dcol, scol)), '%2%', scol)||constants.eol;
end;
 procedure set_obj_lang  IS
  s varchar2(1024);
  sn varchar2(1024);
  nameshort constant varchar2(30) := 'DESCR';
BEGIN
 for o in (select * from obj_ids where obj_type='T') loop
  for c in (select * from obj_col_ids where obj_id=o.id) loop
    muu := replace(replace(replace(mu, ':1', lang), ':2', lang_def), ':3', c.col_id);
    if c.col_name=namename then
     sn := set_col('SUF')||','||set_col('ABBR')||','||set_col('SHORT')||','||set_col('FULL');
    elsif c.col_name=nameshort then
     sn := set_col('nvl(short, abbr)', c.col_name);
    else
     sn := set_col('ABBR', c.col_name);
    end if;
    s := 'update '||o.obj_name||' a set '||sn||' where a.scode is not null';
--app_log.Log_Messageex('LAN', s||chr(10)||'with '||c.col_id||' '||lang||' '||lang_def);
    execute immediate s --using lang, lang_def, c.col_id
;
	commit;
  end loop;
 end loop;
END;
 procedure set_child_attrs is
 begin
  update attrs a set (suf, abbr) = (select descr, descr from attr_types where id=a.attr_type)
   where scode is null;
  commit;
 end;
 procedure set_groups is
 begin
  DATA_SERVICE.AFTER_REF_LOAD;
  for c in (select dl.id, dl.suf, dl.abbr, tab_name, col_name from dim_levels dl join dims d on d.id=dl.dim_id and d. add_dim='Y') loop
   update (select id, type_id, abbr, suf, instr(abbr, ' ') iab, instr(suf, ' ') isu
            from groups a  where id<0 and type_id=c.id and instr(abbr, ' ')>0 and id<-100)
     set (suf, abbr) = (select substr(suf, 1, isu)||c.suf, substr(abbr, 1, iab)||c.abbr from dual);
   update (select id, type_id, abbr, short, instr(abbr, ' ') iab, instr(short, ' ') isu
            from groups a  where id<0 and type_id=c.id and instr(abbr, ' ')>0 and id>-100)
     set (short, abbr) = (select all_value||c.suf, all_value||c.abbr from dual);
--   if c.col_name=namecode then
--    execute immediate 'update groups a set short=(select name from '||c.tab_name||' t join grp_d gd on gd.dim_lev_code=t.code where gd.GRP_ID=a.ID)
--     where  id<0 and id<-100 and type_id='||c.id;
--   end if;
  end loop;
  commit;
 end;
 procedure set_all is
 begin
  set_obj_lang;
  set_child_attrs;
  set_groups;
 end;
begin
 select nvl(max(parvalue), lang_def) into lang from params
  where taskid='GEN' and parid='LANGUAGE';
 select abbr into all_value
  from obj_col_names where row_id='ALL' and col_id=dict_col_id and lang_id=lang;
end;
/