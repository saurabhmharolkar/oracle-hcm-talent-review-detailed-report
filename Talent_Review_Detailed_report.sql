WITH
    MGR_LEVEL
    AS
        (SELECT FULL_NAME, PERSON_ID EMPID,                  -- MANAGER_LEVEL,
                                                              -- MANAGER_TYPE,
                 MANAGER_ID
           FROM (SELECT MGR_PPNF.FULL_NAME, MAN.PERSON_ID, --'FUNCTIONAL REPORTS TO' MANAGER_LEVEL,
                                                           --MAN.MANAGER_TYPE,
                         MAN.MANAGER_ID
                   FROM FUSION.PER_MANAGER_HRCHY_DN  MAN,
                        FUSION.PER_ALL_PEOPLE_F      PAPF,
                        FUSION.PER_PERSON_NAMES_F    MGR_PPNF
                  WHERE     MAN.PERSON_ID = MGR_PPNF.PERSON_ID
                        AND MGR_PPNF.NAME_TYPE = 'GLOBAL'
                        AND MAN.MANAGER_ID = PAPF.PERSON_ID
                        AND MAN.MANAGER_TYPE = 'FUNC_REPORT'
                        AND MAN.MANAGER_LEVEL <= 1
                        --AND 'Y' = :P_FUNCTIONAL_REPORTS_TO         -- Y/N FLAG
                        AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                                        MGR_PPNF.EFFECTIVE_START_DATE)
                                                AND TRUNC (
                                                        MGR_PPNF.EFFECTIVE_END_DATE)
                        AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                                        PAPF.EFFECTIVE_START_DATE)
                                                AND TRUNC (
                                                        PAPF.EFFECTIVE_END_DATE)
                        AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                                        MAN.EFFECTIVE_START_DATE)
                                                AND TRUNC (
                                                        MAN.EFFECTIVE_END_DATE)
                        AND NOT EXISTS
                                (SELECT MAN2.PERSON_ID
                                   FROM FUSION.PER_MANAGER_HRCHY_DN MAN2
                                  WHERE     1 = 1
                                        AND MAN2.MANAGER_TYPE =
                                            'LINE_MANAGER'
                                        AND MAN2.PERSON_ID = MAN.PERSON_ID
                                        AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                                                        MAN2.EFFECTIVE_START_DATE)
                                                                AND TRUNC (
                                                                        MAN2.EFFECTIVE_END_DATE)
                                        AND (   MAN2.MANAGER_ID IN
                                                    (:MANAGER_NAME)
                                             OR (LEAST (:MANAGER_NAME)
                                                     IS NULL))
                                        AND (   MAN2.MANAGER_ID IN
                                                    (:P_LINE_MGR_ID)
                                             OR (LEAST (:P_LINE_MGR_ID)
                                                     IS NULL)))
                 UNION
                 SELECT MGR_PPNF.FULL_NAME, MAN.PERSON_ID, MAN.MANAGER_ID
                   FROM FUSION.PER_MANAGER_HRCHY_DN  MAN,
                        FUSION.PER_ALL_PEOPLE_F      PAPF,
                        FUSION.PER_PERSON_NAMES_F    MGR_PPNF
                  WHERE     MAN.PERSON_ID = MGR_PPNF.PERSON_ID
                        AND MGR_PPNF.NAME_TYPE = 'GLOBAL'
                        AND MAN.MANAGER_ID = PAPF.PERSON_ID
                        AND MAN.MANAGER_TYPE = 'LINE_MANAGER'
                        AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                                        MGR_PPNF.EFFECTIVE_START_DATE)
                                                AND TRUNC (
                                                        MGR_PPNF.EFFECTIVE_END_DATE)
                        AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                                        PAPF.EFFECTIVE_START_DATE)
                                                AND TRUNC (
                                                        PAPF.EFFECTIVE_END_DATE)
                        AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                                        MAN.EFFECTIVE_START_DATE)
                                                AND TRUNC (
                                                        MAN.EFFECTIVE_END_DATE)
                 UNION
                 SELECT MGR_PPNF.FULL_NAME,
                        PAPF.PERSON_ID,
                        PAPF.PERSON_ID MANAGER_ID
                   FROM FUSION.PER_ALL_PEOPLE_F    PAPF,
                        FUSION.PER_PERSON_NAMES_F  MGR_PPNF
                  WHERE     PAPF.PERSON_ID = MGR_PPNF.PERSON_ID
                        AND MGR_PPNF.NAME_TYPE = 'GLOBAL'
                        AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                                        MGR_PPNF.EFFECTIVE_START_DATE)
                                                AND TRUNC (
                                                        MGR_PPNF.EFFECTIVE_END_DATE)
                        AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                                        PAPF.EFFECTIVE_START_DATE)
                                                AND TRUNC (
                                                        PAPF.EFFECTIVE_END_DATE))
          WHERE     1 = 1
                AND (   MANAGER_ID IN (:MANAGER_NAME)
                     OR (LEAST (:MANAGER_NAME) IS NULL))
                AND (   MANAGER_ID IN (:P_LINE_MGR_ID)
                     OR (LEAST (:P_LINE_MGR_ID) IS NULL))),
    ORG_UDT
    AS
        (SELECT  /*+ MATERIALIZE */
                FUCI_BG.VALUE BUSINESS_GROUP, FUR.ROW_NAME BUSINESS_UNIT
           FROM FUSION.FF_USER_TABLES_VL           FUT,
                FUSION.FF_USER_ROWS_VL             FUR,
                FUSION.FF_USER_COLUMNS_VL          FUC_BG,
                FUSION.FF_USER_COLUMN_INSTANCES_F  FUCI_BG
          WHERE     1 = 1
                AND UPPER (FUT.BASE_USER_TABLE_NAME) =
                    'UDT_NAME'
                AND FUT.USER_TABLE_ID = FUR.USER_TABLE_ID
                AND TRUNC (SYSDATE) BETWEEN TRUNC (FUR.EFFECTIVE_START_DATE)
                                        AND TRUNC (FUR.EFFECTIVE_END_DATE)
                AND FUT.USER_TABLE_ID = FUC_BG.USER_TABLE_ID
                AND FUC_BG.USER_COLUMN_NAME = 'Business_Group'
                AND FUC_BG.USER_COLUMN_ID = FUCI_BG.USER_COLUMN_ID
                AND FUR.USER_ROW_ID = FUCI_BG.USER_ROW_ID
                AND TRUNC (SYSDATE) BETWEEN TRUNC (
                                                FUCI_BG.EFFECTIVE_START_DATE(+))
                                        AND TRUNC (
                                                FUCI_BG.EFFECTIVE_END_DATE)),
    WORLD_AREAS
    AS
        (SELECT FUCI_PLAT.VALUE WORLD_AREA, FUR.ROW_NAME COUNTRY
           FROM FF_USER_TABLES_VL           FUT,
                FF_USER_ROWS_VL             FUR,
                FF_USER_COLUMNS_VL          FUC_PLAT,
                FF_USER_COLUMN_INSTANCES_F  FUCI_PLAT
          WHERE     1 = 1
                AND UPPER (FUT.BASE_USER_TABLE_NAME) = 'EMR_WORLD_AREAS'
                AND FUT.USER_TABLE_ID = FUR.USER_TABLE_ID
                AND TRUNC (SYSDATE) BETWEEN FUR.EFFECTIVE_START_DATE
                                        AND FUR.EFFECTIVE_END_DATE --SR#804068 ADDED TRUNC ON SYSDATE
                AND FUT.USER_TABLE_ID = FUC_PLAT.USER_TABLE_ID
                AND FUC_PLAT.USER_COLUMN_NAME = 'World_Area'
                AND FUC_PLAT.USER_COLUMN_ID = FUCI_PLAT.USER_COLUMN_ID
                AND FUR.USER_ROW_ID = FUCI_PLAT.USER_ROW_ID(+)
                AND TRUNC (SYSDATE) BETWEEN FUCI_PLAT.EFFECTIVE_START_DATE(+)
                                        AND FUCI_PLAT.EFFECTIVE_END_DATE(+)),
    EMP_RATING
    AS                                                    /*TO FETCH RATINGS*/
        (SELECT P.PERSON_ID,
                P.PROFILE_ID,
                PI.CONTENT_TYPE_ID,
                PI.DATE_FROM,
                PI.SOURCE_KEY1,
                PI.BUSINESS_GROUP_ID    PI_BUSINESS_GROUP_ID,
                HTAT1.DASHBOARD_TMPL_ID,
                HTAT1.BUSINESS_GROUP_ID HTAT1_BUSINESS_GROUP_ID,
                HTABLT.BOX_LABEL
           FROM HRT_PROFILES_B               P,
                HRT_PROFILE_ITEMS            PI,
                HRT_PROFILE_TYP_SECTIONS_VL  HPTSV,
                HRR_TMPL_ANALYTIC_TYPES_B    HTAT,
                HRR_TMPL_ANALYTIC_TYPES_B    HTAT1,
                HRR_TMPL_ANLYT_BOX_LBLS_B    HTABL,
                HRR_TMPL_ANLYT_BOX_LBLS_TL   HTABLT
          WHERE     P.PROFILE_ID = PI.PROFILE_ID
                AND PI.BUSINESS_GROUP_ID = P.BUSINESS_GROUP_ID
                AND PI.BUSINESS_GROUP_ID = HPTSV.BUSINESS_GROUP_ID
                AND PI.CONTENT_TYPE_ID = HPTSV.CONTENT_TYPE_ID
                AND PI.SECTION_ID = HPTSV.SECTION_ID
                --AND UPPER(HPTSV.NAME) = '9 BOX PLACEMENT'
                AND UPPER (HPTSV.NAME) = 'N BOX CELL ASSIGNMENT'
                AND PI.SOURCE_KEY2 = HTAT.ANALYTIC_TYPE_ID
                AND PI.BUSINESS_GROUP_ID = HTAT.BUSINESS_GROUP_ID
                AND HTAT1.ANALYTIC_TYPE_ID = HTABL.ANALYTIC_TYPE_ID
                AND HTAT1.BUSINESS_GROUP_ID = HTABL.BUSINESS_GROUP_ID
                AND HTAT1.ANALYTIC_TYPE_ID = HTAT.ANALYTIC_TYPE_ID
                AND PI.ITEM_NUMBER_1 = HTABL.BOX_SEQUENCE
                AND HTABL.ANALYTIC_BOX_LABEL_ID =
                    HTABLT.ANALYTIC_BOX_LABEL_ID
                AND HTABL.BUSINESS_GROUP_ID = HTABLT.BUSINESS_GROUP_ID
                AND HTABLT.LANGUAGE = USERENV ('LANG')),
    MEET_STATUS
    AS
        (SELECT  /*+ MATERIALIZE */
                STATUSLOOKUPPEO.MEANING, STATUSLOOKUPPEO.LOOKUP_CODE
           FROM HR_LOOKUPS STATUSLOOKUPPEO
          WHERE 1 = 1 AND STATUSLOOKUPPEO.LOOKUP_TYPE = 'HRR_MEETING_STATUS'),
    REPORTS_TO_data
    AS
        (SELECT pasf.manager_assignment_id reports_to_asg_id,
                pasf.manager_id,
                pn.full_name               reports_to_name,
                paam_mgr.assignment_number reports_to_asg_number,
                papfs.person_number        reports_to_number,
                pasf.assignment_id,
                past.user_status           assignment_status_ln
           FROM per_assignment_supervisors_f    pasf,
                per_person_names_f              pn,
                per_all_people_f                papfs,
                per_all_assignments_m           paam_mgr,
                per_assignment_status_types_vl  past
          WHERE     1 = 1
                AND pn.name_type = 'GLOBAL'
                AND TRUNC (SYSDATE) BETWEEN pn.effective_start_date
                                        AND pn.effective_end_date
                AND pn.person_id = pasf.manager_id
                AND papfs.person_id = pasf.manager_id
                AND TRUNC (SYSDATE) BETWEEN papfs.effective_start_date
                                        AND papfs.effective_end_date
                AND paam_mgr.person_id = pasf.manager_id
                AND paam_mgr.assignment_id = pasf.MANAGER_ASSIGNMENT_ID
                AND TRUNC (SYSDATE) BETWEEN paam_mgr.effective_start_date
                                        AND paam_mgr.effective_end_date
                AND TRUNC (SYSDATE) BETWEEN pasf.effective_start_date
                                        AND pasf.effective_end_date
                AND paam_mgr.effective_latest_change = 'Y'
                AND pasf.MANAGER_TYPE = 'LINE_MANAGER'
                AND paam_mgr.assignment_Status_type_id =
                    past.assignment_Status_type_id),
	NOTES_DATA AS (SELECT /*TO_CHAR (
                     REPLACE (REPLACE (HN.NOTE_TEXT, '<p>', ''), '</p>', ''))*/
                 REGEXP_REPLACE (
                     REGEXP_REPLACE (
                         REGEXP_REPLACE (
                             REGEXP_REPLACE (
                                 REGEXP_REPLACE (
                                     REPLACE (
                                         REGEXP_REPLACE (
                                             REGEXP_REPLACE (
                                                 REGEXP_REPLACE (
                                                     REGEXP_REPLACE (
                                                         REGEXP_REPLACE (
                                                             REPLACE (
                                                                 REGEXP_REPLACE (
                                                                     DBMS_LOB.SUBSTR (
                                                                         HN.NOTE_TEXT,
                                                                         400,
                                                                         1),
                                                                     '<.*?>'),
                                                                 '&nbsp;',
                                                                 ' '),
                                                             '<style[^>]*>'),
                                                         '<span[^>]*>'),
                                                     '</?p[^>]*>'),
                                                 '<table[^>]*>'),
                                             '<td[^>]*>'),
                                         '&middot;',
                                         '*'),
                                     '<b[^>]*>'),
                                 '<div[^>]*>'),
                             '<col[^>]*>'),
                         '<ul[^>]*>',
                         '-'),
                     '<li[^>]*>',
                     '-') NOTE,
					 HN.CONTEXT_ID,
					 HN.OBJECT_ID,
					 HN.CREATED_BY,
					 PPNF.LAST_NAME || ', ' || PPNF.FIRST_NAME NAME
					 
            FROM HRT_NOTES HN,
			     PER_PERSON_NAMES_F            PPNF
				 
           WHERE     1=1 
		         
                 AND HN.CREATION_DATE = (SELECT MAX (HN1.CREATION_DATE)
                                           FROM HRT_NOTES HN1
                                          WHERE HN1.CONTEXT_ID = HN.CONTEXT_ID)
				 AND PPNF.PERSON_ID = HN.AUTHOR_ID
                 AND PPNF.NAME_TYPE = 'GLOBAL'
                 AND TRUNC (SYSDATE) BETWEEN PPNF.EFFECTIVE_START_DATE
                                 AND PPNF.EFFECTIVE_END_DATE
				  
)
  SELECT DISTINCT
         PAPF.PERSON_NUMBER
             EMP_ID,
         PAAM.ASSIGNMENT_NUMBER,
         PAAM.ASSIGNMENT_NAME,
         PASTT.USER_STATUS
             ASSIGNMENT_STATUS,
         PPNF.LAST_NAME || ', ' || PPNF.FIRST_NAME
             NAME,
         PEAW.EMAIL_ADDRESS
             WORK_EMAIL,
         HM.MEETING_TITLE,
         JOB.NAME
             JOB_NAME,
         JOB_FAMILY.JOB_FAMILY_NAME
             JOB_FAMILY,
         PER_EXTRACT_UTILITY.GET_DECODED_LOOKUP ('JOB_FUNCTION_CODE',
                                                 JOB.JOB_FUNCTION_CODE)
             JOB_FUNCTION,
         JOB.ATTRIBUTE12
             JOB_FUNCTION_GROUP,
         JOB.MANAGER_LEVEL
             CONTRIBUTOR_TYPE,
         JOB.ATTRIBUTE13
             CONTRIBUTOR_TYPE_LEVEL,
         JOB.APPROVAL_AUTHORITY
             ORG_LEVEL,
         ORG_UDT.BUSINESS_GROUP,
         HAOUFVL_BU.NAME
             BU_UNIT,
         HAOU.NAME
             EMPLOYEE_DEPARTMENT,
         LE.NAME
             EMPLOYEE_LEGAL_EMPLOYER,
         HLA.LOCATION_NAME
             EMPLOYEE_LOCATION,
         HG.GEOGRAPHY_NAME
             LEGAL_EMPLOYER_COUNTRY,
         WORLD_AREAS.WORLD_AREA
             WORLD_AREA,
         PPNF_MO.LAST_NAME || ', ' || PPNF_MO.FIRST_NAME
             MEETING_OWNER_NAME,
		 PEAW_MO.EMAIL_ADDRESS MEETING_OWNER_EMAIL,
         PPNF_BL.LAST_NAME || ', ' || PPNF_BL.FIRST_NAME
             BUSINESS_LEADER_NAME,
         PEAW_BL.EMAIL_ADDRESS
             BUSINESS_LEADER_WORK_EMAIL,
         HM.MEETING_ID,
         (SELECT HRL_TR.RATING_DESCRIPTION
            FROM HRT_RATING_LEVELS_TL HRL_TR
           WHERE     HRL_TR.RATING_LEVEL_ID = HD.EXTN_METRIC_CALIB_VALUE4
                 AND HRL_TR.LANGUAGE = 'US')
             AS PTA_RATING,
         (SELECT HRL_PTA.RATING_DESCRIPTION
            FROM HRT_RATING_LEVELS_TL HRL_PTA
           WHERE     HRL_PTA.RATING_LEVEL_ID(+) = HD.EXTN_METRIC_CALIB_VALUE5
                 AND HRL_PTA.LANGUAGE = 'US')
             AS TALENT_READINESS,
         (SELECT HRL_POT.RATING_DESCRIPTION
            FROM HRT_RATING_LEVELS_TL HRL_POT
           WHERE     HRL_POT.RATING_LEVEL_ID(+) = HD.EXTN_METRIC_CALIB_VALUE3
                 AND HRL_POT.LANGUAGE = 'US')
             AS POT_RATING,
         /*(SELECT 
                 REGEXP_REPLACE (
                     REGEXP_REPLACE (
                         REGEXP_REPLACE (
                             REGEXP_REPLACE (
                                 REGEXP_REPLACE (
                                     REPLACE (
                                         REGEXP_REPLACE (
                                             REGEXP_REPLACE (
                                                 REGEXP_REPLACE (
                                                     REGEXP_REPLACE (
                                                         REGEXP_REPLACE (
                                                             REPLACE (
                                                                 REGEXP_REPLACE (
                                                                     DBMS_LOB.SUBSTR (
                                                                         HN.NOTE_TEXT,
                                                                         400,
                                                                         1),
                                                                     '<.*?>'),
                                                                 '&nbsp;',
                                                                 ' '),
                                                             '<style[^>]*>'),
                                                         '<span[^>]*>'),
                                                     '</?p[^>]*>'),
                                                 '<table[^>]*>'),
                                             '<td[^>]*>'),
                                         '&middot;',
                                         '*'),
                                     '<b[^>]*>'),
                                 '<div[^>]*>'),
                             '<col[^>]*>'),
                         '<ul[^>]*>',
                         '-'),
                     '<li[^>]*>',
                     '-')
            FROM HRT_NOTES HN
           WHERE     HN.CONTEXT_ID = HM.MEETING_ID
                 AND HN.OBJECT_ID = PAPF.PERSON_ID
                 AND HN.CREATION_DATE = (SELECT MAX (HN1.CREATION_DATE)
                                           FROM HRT_NOTES HN1
                                          WHERE HN1.CONTEXT_ID = HN.CONTEXT_ID)
                 AND ROWNUM = 1)*/
             ND.NOTE MEETING_FACILITATOR_NOTES,
			 ND.NAME NOTE_CREATORS_NAME,
			 ND.CREATED_BY NOTE_CREATORS_ID,
         EMP_RATING.BOX_LABEL
             EMP_BOX_RATING,
         MEET_STATUS.MEANING
             MEETING_STATUS,
         TO_NCHAR (HM.MEETING_DATE,
                   'DD-Mon-YYYY',
                   'NLS_DATE_LANGUAGE=AMERICAN')
             MEETING_DATE,
         DECODE (PAAM.PRIMARY_FLAG,  'Y', 'Yes',  'N', 'No')
             PRIMARY_ASSIGNMENT,
         DECODE (PAAM.EMPLOYMENT_CATEGORY,
                 'FT', 'Full-time temporary',
                 'PR', 'Part-time regular',
                 'FR', 'Full-time regular',
                 'PT', 'Part-time temporary',
                 PAAM.FREQUENCY, PAAM.EMPLOYMENT_CATEGORY)
             ASSIGNMENT_CATEGORY,
         PPT.USER_PERSON_TYPE
             PERSON_TYPE,
         FLV.MEANING
             WORKER_CATEGORY,
         DECODE (PAAM.HOURLY_SALARIED_CODE,  'S', 'Salaried',  'H', 'Hourly')
             HOURLY_OR_SALARIED,
         TO_CHAR (PPOS.ACTUAL_TERMINATION_DATE,
                  'dd-Mon-YYYY',
                  'NLS_DATE_LANGUAGE=AMERICAN')
             TERMINATION_DATE,
         TO_CHAR (PPOS.DATE_START, 'dd-Mon-YYYY', 'NLS_DATE_LANGUAGE=AMERICAN')
             LE_START_DATE,
         TO_CHAR (PPOS.ADJUSTED_SVC_DATE,
                  'DD-Mon-YYYY',
                  'NLS_DATE_LANGUAGE = AMERICAN')
             LATEST_START_DATE,
         CASE
             WHEN EMP_RATING.BOX_LABEL IS NULL
             THEN
                 ''
             WHEN EMP_RATING.BOX_LABEL IN
                      ('High Performance and Potential to Move Up 1 Level',
                       'High Performance and Potential to Move Up 2+ Levels')
             THEN
                 'Y'
             ELSE
                 'N'
         END
             AS HIGH_POTENTIAL_DESIGNATION,
         REPORTS_TO.REPORTS_TO_name
             FULL_NAME,
         REPORTS_TO.REPORTS_TO_number
             LINE_MGR_ID,
		 REPORTS_TO.reports_to_asg_number,
         (SELECT (PEAW_LN_MANAGER.EMAIL_ADDRESS)
            FROM PER_EMAIL_ADDRESSES         PEAW_LN_MANAGER,
                 PER_ASSIGNMENT_SUPERVISORS_F PASF
           WHERE     PASF.ASSIGNMENT_ID = PAAM.ASSIGNMENT_ID
                 AND PASF.MANAGER_TYPE = 'LINE_MANAGER'
                 --AND PASF.PRIMARY_FLAG = 'Y'
                 AND PASF.MANAGER_ID = PEAW_LN_MANAGER.PERSON_ID(+)
                 AND TRUNC (SYSDATE) BETWEEN PASF.EFFECTIVE_START_DATE
                                         AND PASF.EFFECTIVE_END_DATE
                 AND PEAW_LN_MANAGER.EMAIL_TYPE(+) = 'W1'
                 AND TRUNC (SYSDATE) BETWEEN PEAW_LN_MANAGER.DATE_FROM(+)
                                         AND COALESCE (
                                                 PEAW_LN_MANAGER.DATE_TO(+),
                                                 TO_DATE ('4712/12/31',
                                                          'YYYY/MM/DD'))
                 AND ROWNUM = 1)
             REPORTS_TO_MNGR_WORK_EMAIL
    FROM HRR_DASHBOARDS                HD,
         PER_ALL_PEOPLE_F              PAPF,
         PER_ALL_ASSIGNMENTS_M         PAAM,
         PER_PERIODS_OF_SERVICE        PPOS,
         PER_ASSIGNMENT_STATUS_TYPES_TL PASTT,
         PER_PERSON_TYPES_VL           PPT,
         PER_PERSON_NAMES_F            PPNF,
         PER_EMAIL_ADDRESSES           PEAW,
         HRR_MEETINGS                  HM,
         PER_JOBS_F_VL                 JOB,
         PER_JOB_FAMILY_F_VL           JOB_FAMILY,
         ORG_UDT,
         HR_ALL_ORGANIZATION_UNITS_F_VL HAOUFVL_BU,
         HR_ALL_ORGANIZATION_UNITS     HAOU,
         HR_ALL_ORGANIZATION_UNITS     LE,
         HR_LOCATIONS_ALL              HLA,
         WORLD_AREAS,
         HZ_GEOGRAPHIES                HG,
         PER_PERSON_NAMES_F            PPNF_MO,
		 PER_EMAIL_ADDRESSES           PEAW_MO,
         PER_PERSON_NAMES_F            PPNF_BL,
         PER_EMAIL_ADDRESSES           PEAW_BL,
         EMP_RATING                    EMP_RATING,
         MEET_STATUS,
         FND_LOOKUP_VALUES_VL          FLV,
         REPORTS_TO_data               REPORTS_TO,
		 NOTES_DATA                    ND
   WHERE     1 = 1
         AND TRUNC (SYSDATE) BETWEEN PAPF.EFFECTIVE_START_DATE
                                 AND PAPF.EFFECTIVE_END_DATE
         AND PAPF.PERSON_ID = PAAM.PERSON_ID
         AND PAAM.ASSIGNMENT_TYPE IN ('E', 'C')
         AND PAAM.PERIOD_OF_SERVICE_ID = PPOS.PERIOD_OF_SERVICE_ID
         AND TRUNC (SYSDATE) BETWEEN PAAM.EFFECTIVE_START_DATE
                                 AND PAAM.EFFECTIVE_END_DATE
         AND PAAM.ASSIGNMENT_ID = HD.ASSIGNMENT_ID
         AND PAAM.ASSIGNMENT_STATUS_TYPE_ID =
             PASTT.ASSIGNMENT_STATUS_TYPE_ID(+)
         AND PASTT.LANGUAGE = 'US'
         AND PPNF.PERSON_ID = PAPF.PERSON_ID
         AND PAAM.PERSON_TYPE_ID = PPT.PERSON_TYPE_ID
         AND PPNF.NAME_TYPE = 'GLOBAL'
         AND TRUNC (SYSDATE) BETWEEN PPNF.EFFECTIVE_START_DATE
                                 AND PPNF.EFFECTIVE_END_DATE
         AND PPNF_MO.PERSON_ID =
             (SELECT PAPF_MO.PERSON_ID
                FROM PER_ALL_PEOPLE_F PAPF_MO
               WHERE     PAPF_MO.PERSON_NUMBER = HM.CREATED_BY
                     AND SYSDATE BETWEEN PAPF_MO.EFFECTIVE_START_DATE
                                     AND PAPF_MO.EFFECTIVE_END_DATE)
         AND PPNF_MO.NAME_TYPE = 'GLOBAL'
         AND TRUNC (SYSDATE) BETWEEN PPNF_MO.EFFECTIVE_START_DATE
                                 AND PPNF_MO.EFFECTIVE_END_DATE
		 AND PPNF_MO.PERSON_ID = PEAW_MO.PERSON_ID(+)
         AND PEAW_MO.EMAIL_TYPE(+) = 'W1'
         AND TRUNC (SYSDATE) BETWEEN PEAW_MO.DATE_FROM(+)
                                 AND COALESCE (
                                         PEAW_MO.DATE_TO(+),
                                         TO_DATE ('4712/12/31', 'YYYY/MM/DD'))
         AND PPNF_BL.PERSON_ID = HM.MEETING_LEADER_ID
         AND PPNF_BL.NAME_TYPE = 'GLOBAL'
         AND TRUNC (SYSDATE) BETWEEN PPNF_BL.EFFECTIVE_START_DATE
                                 AND PPNF_BL.EFFECTIVE_END_DATE
         AND HM.MEETING_LEADER_ID = PEAW_BL.PERSON_ID(+)
         AND PEAW_BL.EMAIL_TYPE(+) = 'W1'
         AND TRUNC (SYSDATE) BETWEEN PEAW_BL.DATE_FROM(+)
                                 AND COALESCE (
                                         PEAW_BL.DATE_TO(+),
                                         TO_DATE ('4712/12/31', 'YYYY/MM/DD'))
         AND PAPF.PERSON_ID = PEAW.PERSON_ID(+)
         AND PEAW.EMAIL_TYPE(+) = 'W1'
         AND TRUNC (SYSDATE) BETWEEN PEAW.DATE_FROM(+)
                                 AND COALESCE (
                                         PEAW.DATE_TO(+),
                                         TO_DATE ('4712/12/31', 'YYYY/MM/DD'))
         AND HD.MEETING_ID = HM.MEETING_ID
         AND PAAM.ASSIGNMENT_ID = REPORTS_TO.ASSIGNMENT_ID(+)
         AND PAAM.JOB_ID = JOB.JOB_ID(+)
         AND JOB.JOB_FAMILY_ID = JOB_FAMILY.JOB_FAMILY_ID(+)
         AND TRUNC (SYSDATE) BETWEEN JOB.EFFECTIVE_START_DATE(+)
                                 AND JOB.EFFECTIVE_END_DATE(+)
         AND TRUNC (SYSDATE) BETWEEN JOB_FAMILY.EFFECTIVE_START_DATE(+)
                                 AND JOB_FAMILY.EFFECTIVE_END_DATE(+)
         AND PAAM.BUSINESS_UNIT_ID = HAOUFVL_BU.ORGANIZATION_ID
         AND TRUNC (SYSDATE) BETWEEN HAOUFVL_BU.EFFECTIVE_START_DATE
                                 AND HAOUFVL_BU.EFFECTIVE_END_DATE
         AND UPPER (HAOUFVL_BU.NAME) = UPPER (ORG_UDT.BUSINESS_UNIT(+))
         AND PAAM.ORGANIZATION_ID = HAOU.ORGANIZATION_ID(+)
         AND TRUNC (SYSDATE) BETWEEN TRUNC (HAOU.EFFECTIVE_START_DATE(+))
                                 AND TRUNC (HAOU.EFFECTIVE_END_DATE(+))
         AND PAAM.LEGAL_ENTITY_ID = LE.ORGANIZATION_ID
         AND TRUNC (SYSDATE) BETWEEN TRUNC (LE.EFFECTIVE_START_DATE)
                                 AND TRUNC (LE.EFFECTIVE_END_DATE)
         AND PAAM.LOCATION_ID = HLA.LOCATION_ID(+)
         AND TRUNC (SYSDATE) BETWEEN TRUNC (HLA.EFFECTIVE_START_DATE(+))
                                 AND TRUNC (HLA.EFFECTIVE_END_DATE(+))
         AND HG.GEOGRAPHY_TYPE = 'COUNTRY'
         AND HG.GEOGRAPHY_CODE = PAAM.LEGISLATION_CODE
         AND WORLD_AREAS.COUNTRY(+) = HG.GEOGRAPHY_NAME
         AND EMP_RATING.SOURCE_KEY1(+) = HM.MEETING_ID
         AND EMP_RATING.PERSON_ID(+) = PAAM.PERSON_ID
         AND PAPF.PERSON_ID IN (SELECT EMPID FROM MGR_LEVEL)
         AND MEET_STATUS.LOOKUP_CODE(+) = HM.MEETING_STATUS_CODE
         AND FLV.LOOKUP_CODE = PAAM.EMPLOYEE_CATEGORY
         AND FLV.LOOKUP_TYPE = 'EMPLOYEE_CATG'
		 AND ND.CONTEXT_ID(+) = HM.MEETING_ID
         AND ND.OBJECT_ID(+) = PAPF.PERSON_ID
         AND EXISTS
                 (SELECT 1
                    FROM PER_PERSON_SECURED_LIST_V PSSL
                   WHERE PSSL.PERSON_ID = PAPF.PERSON_ID)
         /*PARAMETERS*/

         AND (   MEET_STATUS.MEANING IN (:P_MEET_STATUS)
              OR (LEAST (:P_MEET_STATUS) IS NULL))
         AND (   (    :P_DATE_MODE = 'MD_BEFORE'
                  AND TRUNC (HM.MEETING_DATE) <= TRUNC (:P_EFFECTIVE_DATE))
              OR (    :P_DATE_MODE = 'MD_AFTER'
                  AND TRUNC (HM.MEETING_DATE) >= TRUNC (:P_EFFECTIVE_DATE))
              OR (    :P_DATE_MODE = 'MSD_BEFORE'
                  AND TRUNC (HM.MEETING_SUBMISSION_DATE) <=
                      TRUNC (:P_EFFECTIVE_DATE))
              OR (    :P_DATE_MODE = 'MSD_AFTER'
                  AND TRUNC (HM.MEETING_SUBMISSION_DATE) >=
                      TRUNC (:P_EFFECTIVE_DATE)))
         AND (   EXTRACT (YEAR FROM HM.MEETING_DATE) IN (:P_REVIEW_YEAR)
              OR (LEAST (:P_REVIEW_YEAR) IS NULL))
         /* AND (   TO_CHAR (HM.MEETING_DATE, 'MM') =
                   TO_CHAR (:P_EFFECTIVE_DATE, 'MM'))*/
         -- AND (HAOUFVL_BU.NAME IN (:P_BU_NAME) OR (LEAST (:P_BU_NAME) IS NULL))
         AND (   HAOUFVL_BU.ORGANIZATION_ID IN (:P_BU_NAME)
              OR (LEAST (:P_BU_NAME) IS NULL))
         -- AND (HAOU.NAME IN (:P_DEP_NAME) OR (LEAST (:P_DEP_NAME) IS NULL))
         AND (   HAOU.ORGANIZATION_ID IN (:P_DEP_NAME)
              OR (LEAST (:P_DEP_NAME) IS NULL))
         AND (   PAAM.LEGISLATION_CODE IN (:P_LE_COUNTRY)
              OR (LEAST (:P_LE_COUNTRY) IS NULL))
         AND (PAAM.LOCATION_ID IN (:LOCATION) OR (LEAST (:LOCATION) IS NULL))
         AND (   PASTT.USER_STATUS IN (:ASSIGNMENT_STATUS)
              OR (LEAST (:ASSIGNMENT_STATUS) IS NULL))
         AND (   PPT.USER_PERSON_TYPE IN (:P_PERSON_TYPE)
              OR (LEAST (:P_PERSON_TYPE) IS NULL))
         AND (   FLV.MEANING IN (:P_WORKER_CATEGORY)
              OR (LEAST (:P_WORKER_CATEGORY) IS NULL))
         AND (   :P_HOURLY_SALARIED IS NULL
              OR DECODE (PAAM.HOURLY_SALARIED_CODE,
                         'S', 'Salaried',
                         'H', 'Hourly') =
                 :P_HOURLY_SALARIED)
         --AND (LE.NAME IN (:P_LE_NAME) OR (LEAST (:P_LE_NAME) IS NULL))
         AND (   LE.ORGANIZATION_ID IN (:P_LE_NAME)
              OR (LEAST (:P_LE_NAME) IS NULL))
         AND (   PAPF.PERSON_ID IN (:PERSON_NUMBER)
              OR (LEAST (:PERSON_NUMBER) IS NULL))
         AND (   PPNF.PERSON_ID IN (:PERSON_NAME)
              OR (LEAST (:PERSON_NAME) IS NULL))
         --AND  HM.MEETING_TITLE = 'ENTERPRISE IT - TEST DRESS REHEARSAL'
         AND (HM.MEETING_ID IN (:P_MEET_NAME) OR (LEAST (:P_MEET_NAME) IS NULL))
         AND (   HM.MEETING_LEADER_ID IN (:P_BL_NAME)
              OR (LEAST (:P_BL_NAME) IS NULL))
ORDER BY NAME