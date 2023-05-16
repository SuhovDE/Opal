--
-- GET_VERSION_OPAL_REPOSITORY  (Function) 
--
--  Dependencies: 
--   PARAMS (Table)
--   UTILS (Synonym)
--   VER (Table)
--   VER_DATA (Synonym)
--   STANDARD (Package)
--   SYS_STUB_FOR_PURITY_ANALYSIS (Package)
--
CREATE OR REPLACE function OPAL_FRA.get_Version_OPAL_Repository
  (rep_name varchar2 := 'META')
 return varchar2 is
 ret varchar2(256);
 verprodpar constant varchar2(30) := 'VERSION';
 verprod constant varchar2(30) := utils.get_par(verprodpar)||'.';
 pref constant varchar2(30) := 'VER_';
 tmp varchar2(30);
begin
 for p in (select parid, parvalue from params where taskid='GEN' and
        (rep_name='ALL' and parid like pref||'%' and parid<>verprodpar
		  or parid=pref||rep_name)) loop
  if ret is not null then ret := ret||'; '; end if;
  ret := ret||p.parvalue||' v.'||verprod;
  if p.parid=pref||'META' then
    select nvl(max(build||'.'||patch), '0.0') into tmp from
     (select build, patch from ver order by build desc, patch desc)
	 where rownum=1;
  elsif p.parid=pref||'DATA' then
    select nvl(max(build||'.'||patch), '0.0') into tmp from
     (select build, patch from ver_data order by build desc, patch desc)
	 where rownum=1;
  end if;
  ret:=ret||tmp;
 end loop;
 return ret;
end;
 
 
/