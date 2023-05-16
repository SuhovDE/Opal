--
-- REP_STDAUSW_ADV  (Procedure) 
--
--  Dependencies: 
--   AIRPORTS (Synonym)
--   GET_PARAM_VALUE (Function)
--   IO (Synonym)
--   MOVEMENT (Synonym)
--   T_PARAMETERS (Type)
--   T_RC_NAME (Type)
--   T_RC_NAMES (Type)
--   VALS (Type)
--   DUAL (Synonym)
--   STANDARD (Package)
--   SYS_STUB_FOR_PURITY_ANALYSIS (Package)
--
CREATE OR REPLACE PROCEDURE OPAL_FRA."REP_STDAUSW_ADV" (
            p_Params    IN  t_Parameters,
            p_RC_Names  OUT t_RC_Names,
            po_rc_1     OUT SYS_REFCURSOR
            )
AS
   v_Year    			 INTEGER := NULL;
   v_Month  			 INTEGER := NULL;

   v_Flight_Type_Group  	 VARCHAR2(50) := NULL;
   v_FT_tbl        		 t_RC_Names;

   v_Location_Group 		 VARCHAR2(50) := NULL;
   v_LC_tbl        		 t_RC_Names;

   v_B_Linie_Charter    	 NUMBER(9);
   v_B_Sonstiger_Verkehr	 NUMBER(9);
   v_B_Nicht_gewerblich		 NUMBER(9);
   v_B_Bonusliste            	 NUMBER(9);
   v_B_ChapterIII            	 NUMBER(9);
   v_P_von_nach_Deutschland  	 NUMBER(9);
   v_P_von_nach_Europa		 NUMBER(9);
   v_P_davon_EU			 NUMBER(9);
   v_P_davon_Schengen		 NUMBER(9);
   v_P_Ausland			 NUMBER(9);
   v_P_Sonstiger_Verkehr	 NUMBER(9);
   v_P_Transit			 NUMBER(9);
   v_F_Ausladung		 NUMBER(9,3);
   v_F_Einladung		 NUMBER(9,3);
   v_F_Transit			 NUMBER(9,3);
   v_M_Lokalaufkommen		 NUMBER(9,3);
   v_M_Ausladung		 NUMBER(9,3);
   v_M_Einladung		 NUMBER(9,3);
   v_M_Transit			 NUMBER(9,3);

   c_Int_Format			 VARCHAR2(50);
   c_NVL_Format			 VARCHAR2(50);

   msg      			 VARCHAR2(2048);

   c_str_DateBeg		 VARCHAR2(20);
   c_str_DateEnd		 VARCHAR2(50);

   msg      			 VARCHAR2(2048);

BEGIN
   -- Constants initialisation, specify some formats for printing
   c_Int_Format := '999G999G999';
   c_NVL_Format := '-';

   -- get the parameter from Reportgenerator
   v_Year := Get_Param_Value(p_Params, 'Jahr');
   v_Month := Get_Param_Value(p_Params, 'Monat');

   -- calculate the border for a monthly report
   SELECT '01' || TO_CHAR(v_Month, '00') || '.' || TO_CHAR(v_Year) INTO c_str_DateBeg FROM dual;
   IF v_Month = 12 THEN
      SELECT '01.01' || '.' || TO_CHAR(v_Year+1) INTO c_str_DateEnd FROM dual;
   ELSE
      SELECT '01' || TO_CHAR(v_Month + 1, '00') || '.' || TO_CHAR(v_Year) INTO c_str_DateEnd FROM dual;
   END IF;

   -- Initialise the Returncode
   p_RC_Names := t_RC_Names( t_RC_Name(1, 'HEADER'));

--
--- Movements
--
SELECT SUM(Linie_Charter) Linie_Charter, SUM(Sonst_Verkehr) Sonst_Verkehr, SUM(Nicht_Gewerbl) Nicht_Gewerbl
INTO v_B_Linie_Charter,v_B_Sonstiger_Verkehr,v_B_Nicht_gewerblich
FROM (
   SELECT ActMonth,
          CASE WHEN FTGrp = 'Linie_Charter' THEN SUM(movements) END AS Linie_Charter,
          CASE WHEN FTGrp = 'Sonst_Verkehr' THEN SUM(movements) END AS Sonst_Verkehr,
          CASE WHEN FTGrp = 'Nicht_Gewerbl' THEN SUM(movements) END AS Nicht_Gewerbl
     FROM (
-- Core based on Test_Query
SELECT lvl7.F1 ActMonth,lvl7.F2 FTGrp,SUM(lvl7.F3) Movements
 FROM (SELECT F1,F2,MAX(F3) F3
 FROM (SELECT lvl5.FA1 F1,FN2.column_value F2,lvl5.MOVEMENTS F3, id1, stopno_
 FROM (SELECT lvl4.*,
cast(MULTISET((SELECT column_value FROM TABLE(vals(
CASE  WHEN FLIGHTTYPE IN('11','12','13','21','30','31','32','36','15','16','18') THEN 'Linie_Charter'
END,
CASE  WHEN FLIGHTTYPE IN('40','41','42','45') THEN 'Sonst_Verkehr'
END,
CASE  WHEN FLIGHTTYPE IN('19','51','52','53','54','55','56') THEN 'Nicht_Gewerbl'
END)) WHERE column_value IS NOT NULL))  AS vals) FN2
 FROM (SELECT lvl2.*
 FROM (SELECT
TRUNC(ACTUALDAY, 'MM') FA1,
lvl1.FLIGHTTYPE,
lvl1.MOVEMENTS,
lvl1.ACTUALDAY, id1, stopno stopno_
 FROM MOVEMENT lvl1) lvl2
 WHERE (((ACTUALDAY >= TO_DATE(c_str_DateBeg, 'DD.MM.YYYY') AND ACTUALDAY < TO_DATE(c_str_DateEnd,'DD.MM.YYYY'))
)AND((FLIGHTTYPE IN('11','12','13','21','30','31','32','36','15','16','18')
)OR(FLIGHTTYPE IN('40','41','42','45')
)OR(FLIGHTTYPE IN('19','51','52','53','54','55','56')
)))) lvl4) lvl5,TABLE(lvl5.FN2)(+) FN2
) lvl6 GROUP BY F1,F2, id1) lvl7
GROUP BY lvl7.F1,lvl7.F2)
-- end Core
    GROUP BY ActMonth, FTGrp )
GROUP BY ActMonth;

--
--- davon Strahlflugzeuge
--
v_B_Bonusliste := 0;
v_B_ChapterIII := 0;

--
--- Pax
--
SELECT SUM(DE) DE, SUM(Europa) Europa, SUM(EU) EU, SUM(Schengen) Schengen, SUM(Ausland) Ausland
INTO v_P_von_nach_Deutschland,v_P_von_nach_Europa,v_P_davon_EU,v_P_davon_Schengen, v_P_Ausland
     FROM (
          SELECT ActMonth,
                 CASE WHEN ADVRegion = 'Deutschland' THEN SUM(PaxDisEmb) END AS DE,
                 CASE WHEN ADVRegion = 'EU_oDE' THEN SUM(PaxDisEmb) END AS EU,
                 CASE WHEN ADVRegion = 'Europa_oDE' THEN SUM(PaxDisEmb) END AS Europa,
                 CASE WHEN ADVRegion = 'Schengen_oDE' THEN SUM(PaxDisEmb) END AS Schengen,
                 CASE WHEN ADVRegion IS NULL THEN SUM(PaxDisEmb) END AS Ausland
            FROM (
-- Core from Test_Query
SELECT lvl7.F1 ActMonth,lvl7.F3 ADVRegion,SUM(lvl7.F4) PaxDisEmb
 FROM (SELECT F1,F3,TRUNC(SUM(DISTINCT F4*1000+SIGN(F4)*stopno_)/1000) F4
 FROM (SELECT lvl5.FA1 F1,FN3.column_value F3,lvl5.PAX_EMB_ROUT F4, id1, stopno_
 FROM (SELECT lvl4.*,
cast(MULTISET((SELECT column_value FROM TABLE(vals(
CASE  WHEN FA2 IN('DE') THEN 'Deutschland'
END,
CASE  WHEN FA2 IN('SI','SE','PT','PL','NL','MT','LV','LU','LT','IT','IE','HU','GR','GB','FR','FI','ES','EE','DK','CZ','CY','BE','AT','RO','BG') THEN 'EU_oDE'
END,
case  when FA2 IN('SE','PT','NO','NL','LU','IT','IS','GR','FR','FI','ES','DK','BE','AT','EE','LV','LT','MT','PL','SK','SI','CZ','HU') then 'Schengen_oDE'
END,
CASE  WHEN FA2 IN('YU','UA','TR','SM','SK','SI','SE','RU','RO','PT','PL','NO','NL','MT','MK','MD','MC','LV','LU','LT','IT','IS','IE','HU','HR','GR','GI','GE','GB','FR','FO','FI','ES','EE','DK','CZ','CY','CH','BY','BG','BE','BA','AZ','AT','AM','AL','AD') THEN 'Europa_oDE'
END)) WHERE column_value IS NOT NULL))  AS vals) FN3
 FROM (SELECT lvl2.*
 FROM (SELECT
TRUNC(ACTUALDAY, 'MM') FA1,
lvl1.FLIGHTTYPE,
lvl1.AIRPORT,
lvl1.PAX_EMB_ROUT,
lvl1.ACTUALDAY,
(SELECT COUNTRY_CODE FROM AIRPORTS WHERE CODE=lvl1.AIRPORT) FA2, id1, stopno stopno_
 FROM MOVEMENT lvl1) lvl2
 WHERE (((ACTUALDAY >= TO_DATE(c_str_DateBeg, 'DD.MM.YYYY') AND ACTUALDAY < TO_DATE(c_str_DateEnd,'DD.MM.YYYY'))
)AND(FLIGHTTYPE IN('11','12','13','21','30','31','32','36','15','16','18')
))) lvl4) lvl5,TABLE(lvl5.FN3)(+) FN3
) lvl6 GROUP BY F1,F3, id1) lvl7
GROUP BY lvl7.F1,lvl7.F3)
-- End Core
    GROUP BY ActMonth, ADVRegion)
GROUP BY ActMonth;

--
--- Rest Pax
--
SELECT SUM(Sonst_Verkehr) Sonst_Verkehr, SUM(Transit) Transit
INTO v_P_Sonstiger_Verkehr, v_P_Transit
     FROM (
SELECT
   ActMonth,
   CASE WHEN FTGrp IS NOT NULL THEN SUM(PaxDisEmb) END Sonst_Verkehr,
   CASE WHEN FTGrp IS NULL THEN CASE WHEN IO = 'O' THEN SUM(transit) END END Transit
FROM(
SELECT lvl7.F1 ActMonth,lvl7.F2 FTGrp,lvl7.F3 IO,
MAX((SELECT NAME FROM IO WHERE ROWNUM=1 AND CODE=lvl7.F3)) IO_Long,SUM(lvl7.F4) PaxDisEmb,SUM(lvl7.F5) Transit
 FROM (SELECT F1,F2,F3,TRUNC(SUM(DISTINCT F4*1000+SIGN(F4)*stopno_)/1000) F4,TRUNC(SUM(DISTINCT F5*1000+SIGN(F5)*stopno_)/1000) F5
 FROM (SELECT lvl5.FA1 F1,lvl5.FA2 F2,lvl5.IO F3,lvl5.PAX_EMB_ROUT F4,lvl5.PAXTRANSIT F5, id1, stopno_
 FROM (SELECT lvl4.*,
CASE  WHEN FLIGHTTYPE IN('40','41','42','45') THEN 'Sonst_Verkehr'
END FA2
 FROM (SELECT lvl2.*
 FROM (SELECT
TRUNC(ACTUALDAY, 'MM') FA1,
lvl1.FLIGHTTYPE,
lvl1.IO,
lvl1.PAX_EMB_ROUT,
lvl1.PAXTRANSIT,
lvl1.ACTUALDAY, id1, stopno stopno_
 FROM MOVEMENT lvl1) lvl2
-- where ((extract(Year from lvl2.ACTUALDAY) = v_Year and extract(Month from lvl2.ACTUALDAY) = v_Month)
 WHERE ((ACTUALDAY >= TO_DATE(c_str_DateBeg, 'DD.MM.YYYY') AND ACTUALDAY < TO_DATE(c_str_DateEnd,'DD.MM.YYYY'))
)) lvl4) lvl5
) lvl6 GROUP BY F1,F2,F3, id1) lvl7
GROUP BY lvl7.F1,lvl7.F2,lvl7.F3
)
GROUP BY ActMonth, FTGrp, IO)
GROUP BY ActMonth;

-- Fracht
SELECT SUM(Ausl)/1000 Ausl, SUM(Einl)/1000 Einl, SUM(Transit)/1000 Transit
INTO v_F_Ausladung, V_F_Einladung, V_F_Transit
FROM (
SELECT
   ActMonth,
   CASE WHEN IO = 'I' THEN SUM(Uml) END AS Ausl,
   CASE WHEN IO = 'O' THEN SUM(Uml) END AS Einl,
   CASE WHEN IO = 'I' THEN SUM(Transit) END AS Transit
FROM (
SELECT lvl7.F1 ActMonth,lvl7.F2 IO,
MAX((SELECT NAME FROM IO WHERE ROWNUM=1 AND CODE=lvl7.F2)) IO_Long,SUM(lvl7.F3) Uml,SUM(lvl7.F4) Transit
 FROM (SELECT F1,F2,TRUNC(SUM(DISTINCT F3*1000+SIGN(F3)*stopno_)/1000) F3,TRUNC(SUM(DISTINCT F4*1000+SIGN(F4)*stopno_)/1000) F4
 FROM (SELECT lvl5.FA1 F1,lvl5.IO F2,lvl5.CARGO_EMB F3,lvl5.CARGOTRANSIT F4, id1, stopno_
 FROM (SELECT lvl2.*
 FROM (SELECT
TRUNC(ACTUALDAY, 'MM') FA1,
lvl1.IO,
lvl1.CARGO_EMB,
lvl1.CARGOTRANSIT,
lvl1.ACTUALDAY, id1, stopno stopno_
 FROM MOVEMENT lvl1) lvl2
-- where ((extract(Year from lvl2.ACTUALDAY) = v_Year and extract(Month from lvl2.ACTUALDAY) = v_Month)
 WHERE ((ACTUALDAY >= TO_DATE(c_str_DateBeg, 'DD.MM.YYYY') AND ACTUALDAY < TO_DATE(c_str_DateEnd,'DD.MM.YYYY'))
)) lvl5
) lvl6 GROUP BY F1,F2, id1) lvl7
GROUP BY lvl7.F1,lvl7.F2
)
GROUP BY ActMonth, IO)
GROUP BY ActMonth;

-- Post
SELECT SUM(Uml)/1000 Uml, SUM(Ausl)/1000 Ausl, SUM(Einl)/1000 Einl, SUM(Transit)/1000 Transit
INTO v_M_Lokalaufkommen, v_M_Ausladung, v_M_Einladung, v_M_Transit
FROM (
SELECT
   ActMonth,
   SUM(Uml) Uml,
   CASE WHEN IO = 'I' THEN SUM(Uml) END AS Ausl,
   CASE WHEN IO = 'O' THEN SUM(Uml) END AS Einl,
   CASE WHEN IO = 'O' THEN SUM(Transit) END AS Transit
FROM (
SELECT lvl7.F1 ActMonth, lvl7.F2 IO,
MAX((SELECT NAME FROM IO WHERE ROWNUM=1 AND CODE=lvl7.F2)) IO_Long,SUM(lvl7.F3) Uml,SUM(lvl7.F4) Transit
 FROM (SELECT F1,F2,TRUNC(SUM(DISTINCT F3*1000+SIGN(F3)*stopno_)/1000) F3,TRUNC(SUM(DISTINCT F4*1000+SIGN(F4)*stopno_)/1000) F4
 FROM (SELECT lvl5.FA1 F1,lvl5.IO F2,lvl5.MAIL_EMB F3,lvl5.MAILTRANSIT F4, id1, stopno_
 FROM (SELECT lvl2.*
 FROM (SELECT
TRUNC(ACTUALDAY, 'MM') FA1,
lvl1.IO,
lvl1.MAIL_EMB,
lvl1.MAILTRANSIT,
lvl1.ACTUALDAY, id1, stopno stopno_
 FROM MOVEMENT lvl1) lvl2
 WHERE ((ACTUALDAY >= TO_DATE(c_str_DateBeg, 'DD.MM.YYYY') AND ACTUALDAY < TO_DATE(c_str_DateEnd,'DD.MM.YYYY'))
)) lvl5
) lvl6 GROUP BY F1,F2, id1) lvl7
GROUP BY lvl7.F1,lvl7.F2
)
GROUP BY ActMonth, IO)
GROUP BY ActMonth;

--
-- Get Data for Recordset so called HEADER
--
   OPEN po_rc_1 FOR
      SELECT
            v_Year AS YEAR,
            NVL(TO_CHAR(v_Month, '00'), c_NVL_Format) AS MONTH,
			NVL(TO_CHAR(v_B_Linie_Charter + v_B_Sonstiger_Verkehr, c_Int_Format), c_NVL_Format) AS B_Gewerblich,
			NVL(TO_CHAR(v_B_Linie_Charter, c_Int_Format), c_NVL_Format) AS B_Linie_Charter,
			NVL(TO_CHAR(v_B_Sonstiger_Verkehr, c_Int_Format), c_NVL_Format) AS B_Sonstiger_Verkehr,
			NVL(TO_CHAR(v_B_Nicht_gewerblich, c_Int_Format), c_NVL_Format) AS B_Nicht_gewerblich,
			NVL(TO_CHAR(v_B_Linie_Charter + v_B_Sonstiger_Verkehr + v_B_Nicht_gewerblich, c_Int_Format), c_NVL_Format) AS B_Gesamt_Flugzeugbeweg,
			NVL(TO_CHAR(v_B_Bonusliste, c_Int_Format), c_NVL_Format) AS B_Bonusliste,
			NVL(TO_CHAR(v_B_ChapterIII, c_Int_Format), c_NVL_Format) AS B_ChapterIII,
			NVL(TO_CHAR(v_P_von_nach_Deutschland + v_P_von_nach_Europa + v_P_Ausland + v_P_Sonstiger_Verkehr, c_Int_Format), c_NVL_Format) AS P_Lokalaufkommen,
			NVL(TO_CHAR(v_P_von_nach_Deutschland + v_P_von_nach_Europa + v_P_Ausland, c_Int_Format), c_NVL_Format) AS P_Linie_Charter,
			NVL(TO_CHAR(v_P_von_nach_Deutschland, c_Int_Format), c_NVL_Format) AS P_von_nach_Deutschland,
			NVL(TO_CHAR(v_P_von_nach_Europa, c_Int_Format), c_NVL_Format) AS P_von_nach_Europa,
			NVL(TO_CHAR(v_P_davon_EU, c_Int_Format), c_NVL_Format) AS P_davon_EU,
			NVL(TO_CHAR(v_P_davon_Schengen, c_Int_Format), c_NVL_Format) AS P_davon_Schengen,
			NVL(TO_CHAR(v_P_Ausland, c_Int_Format), c_NVL_Format) AS P_von_nach_Aussereuropa,
			NVL(TO_CHAR(v_P_Sonstiger_Verkehr, c_Int_Format), c_NVL_Format) AS P_Sonstiger_Verkehr,
			NVL(TO_CHAR(v_P_Transit, c_Int_Format), c_NVL_Format) AS P_Transit,
			NVL(TO_CHAR(v_P_von_nach_Deutschland + v_P_von_nach_Europa + v_P_Ausland + v_P_Sonstiger_Verkehr + v_P_Transit, c_Int_Format), c_NVL_Format) AS P_Gesamt_Passagiere,
			NVL(TO_CHAR(v_F_Ausladung + v_F_Einladung, c_Int_Format), c_NVL_Format) AS F_Lokalaufkommen,
			NVL(TO_CHAR(v_F_Ausladung, c_Int_Format), c_NVL_Format) AS F_Ausladung,
			NVL(TO_CHAR(v_F_Einladung, c_Int_Format), c_NVL_Format) AS F_Einladung,
			NVL(TO_CHAR(v_F_Transit, c_Int_Format), c_NVL_Format) AS F_Transit,
			NVL(TO_CHAR(v_F_Ausladung + v_F_Einladung + v_F_Transit, c_Int_Format), c_NVL_Format) AS F_Gesamt_Fracht,
			NVL(TO_CHAR(v_M_Lokalaufkommen, c_Int_Format), c_NVL_Format) AS M_Lokalaufkommen,
			NVL(TO_CHAR(v_M_Ausladung, c_Int_Format), c_NVL_Format) AS M_Ausladung,
			NVL(TO_CHAR(v_M_Einladung, c_Int_Format), c_NVL_Format) AS M_Einladung,
			NVL(TO_CHAR(v_M_Transit, c_Int_Format), c_NVL_Format) AS M_Transit,
			NVL(TO_CHAR(v_M_Lokalaufkommen + v_M_Transit, c_Int_Format), c_NVL_Format) AS M_Gesamt_Post,
			NVL(TO_CHAR(v_F_Ausladung + v_F_Einladung + v_M_Ausladung + v_M_Einladung, c_Int_Format), c_NVL_Format) AS FM_Lokalaufkommen,
			NVL(TO_CHAR(v_F_Ausladung + v_M_Ausladung, c_Int_Format), c_NVL_Format) AS FM_Ausladung,
			NVL(TO_CHAR(v_F_Einladung + v_M_Einladung, c_Int_Format), c_NVL_Format) AS FM_Einladung,
			NVL(TO_CHAR(v_F_Transit + v_M_Transit, c_Int_Format), c_NVL_Format) AS FM_Transit,
			NVL(TO_CHAR(v_F_Ausladung + v_F_Einladung + v_F_Transit + v_M_Ausladung + v_M_Einladung + v_M_Transit, c_Int_Format), c_NVL_Format) AS FM_Gesamt_Fracht
         FROM Dual;

END Rep_Stdausw_Adv;
 
 
/