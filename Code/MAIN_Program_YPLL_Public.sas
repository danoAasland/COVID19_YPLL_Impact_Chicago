/********************************************************************************************/
/*  PROGRAM NAME: MAIN_Program_YPLL.sas														*/
/*  DATE CREATED: Feb 11, 2022																*/
/*  CREATED BY: Dano Aasland																*/
/*  PURPOSE: Runs the programs for calculating the YPLL, data prep ETL, validate, explore 	*/
/*  INPUTS:	PopAdjustmentWeight.sas															*/
/*			AgeGroupData_YPLL.sas															*/
/*			GenderData_YPLL.sas																*/
/*			RaceEthData_YPLL.sas															*/
/*			PlotData_YPLL.sas																*/
/*  Outputs: Desc. stats on YPLL includ. rates raw + age-adjusted per 100K, final DFs and	*/
/*  		 plots are saved in Excel workbook "output.xlsx"								*/
/*------------------------------------------------------------------------------------------*/
/*  Notes: Must update MACRO/GLOBAL VARIABLES to reflect user specified pathways			*/
/*------------------------------------------------------------------------------------------*/
/*  DATE MODIFIED: None																		*/
/*  MODIFIED BY: N/A																		*/
/*  REASON FOR MODIFICATION: N/A															*/
/*  DESCRIPTION OF MODIFICATION: N/A														*/
/*------------------------------------------------------------------------------------------*/
/*  MACRO VARIABLES																			*/
/*------------------------------------------------------------------------------------------*/
/* name of raw data file */
%LET rawData = COVID19_Daily_Cases__Deaths__and_Hospitalizations.xlsx;

/* path to raw data file and SAS program files */
%LET ypllsrc = /YOUR/FILE/PATH/HERE/;

/* path for output files to create and add worksheets to the output excel file */
%LET outpath = /YOUR/FILE/PATH/HERE/output.xlsx;

/* sheet/table to extract from excel raw data file */
%LET covDF = sheet_01;

/* macro col vars r/t death only, and date */
%LET deathVars = Date Deaths___Age_0_17 Deaths___Age_18_29 Deaths___Age_30_39 
Deaths___Age_40_49 Deaths___Age_50_59 Deaths___Age_60_69 Deaths___Age_70_79 Deaths___Age_80_ 
Deaths___Age_Unknown Deaths___Asian_Non_Latinx Deaths___Black_Non_Latinx Deaths___Latinx 
Deaths___White_Non_Latinx Deaths___Other_Race_Non_Latinx Deaths___Unknown_Race_Ethnicity 
Deaths___Female Deaths___Male Deaths___Unknown_Gender Deaths___Total;

/* age only macro excluding unk since its null */
%LET ageFreq = Deaths___Age_0_17 Deaths___Age_18_29 Deaths___Age_30_39 Deaths___Age_40_49 
Deaths___Age_50_59 Deaths___Age_60_69 Deaths___Age_70_79 Deaths___Age_80_;

/* race/eth only macro */
%LET raceFreq = Deaths___Asian_Non_Latinx Deaths___Black_Non_Latinx Deaths___Latinx 
Deaths___White_Non_Latinx Deaths___Other_Race_Non_Latinx Deaths___Unknown_Race_Ethnicity;

/* sex only macro excluding unk since its null */
%LET sexFreq = Deaths___Female Deaths___Male Deaths___Total;

/*------------------------------------------------------------------------------------------*/
/*  GLOBAL LIBRARY REFERENCE(S)																*/
/*------------------------------------------------------------------------------------------*/
/* set libref to store data */
LIBNAME libYPLL "&ypllsrc";

/* set temp libref to read in raw data from excel file */
LIBNAME xlref XLSX "&ypllsrc&rawData";

/* sets a ref to Excel workbook output file to output a copy of the final data tables */
LIBNAME xlout xlsx "&ypllsrc.output.xlsx";

/*------------------------------------------------------------------------------------------*/


/*------------------------------------------------------------------------------------------*/
/*								START - Data ETL											*/
/*------------------------------------------------------------------------------------------*/

/* set variable names to match SAS formatting, run WITH data import step below */
OPTIONS VALIDVARNAME=V7;

/* importing raw dataset to temp lib work*/
data work.raw;
	set xlref.&covDF;
run;

/* clear libref xlref to close link to it so its not locked */
libname xlref clear;

/* exploring and validating data */
/* view metadata (all vars) on raw dataset */
proc contents data=work.raw;
run;

/* create a list of col vars to copy and paste */
/* uncomment to run prn */
*proc contents data=libYPLL.dedup_table short;
*run;

/* view first 10 obs in raw dataset */
PROC PRINT DATA=work.raw(OBS=10);
	VAR _all_;
RUN;

/* create subset of raw data, only death data */
data libYPLL.death_data;
	set work.raw;
	keep &deathVars;
run;

PROC MEANS DATA=libYPLL.death_data N NMISS;
	VAR _all_;
RUN;

/* checking for missing values and if so a count of how many obs */
PROC MEANS DATA=libYPLL.death_data N NMISS;
	VAR _all_;
RUN;

/* NOTE: date is only var with missing values and its only missing one */
/* NOTE: unknown age and unknown gender both ret. 0 */
/* detailed data on each col that is numeric */
PROC UNIVARIATE DATA=libYPLL.death_data;
	VAR _all_;
RUN;

/* proc freq by stratification */
PROC FREQ DATA=libYPLL.death_data;
	TABLES  &ageFreq;
RUN;

/*  preparing data for analysis */
/* checking for dupes and deduplicating data by removing adjacent rows entirely duplicated */
PROC SORT DATA=libYPLL.death_data OUT=libYPLL.dedup_table NODUPKEY 
		DUPOUT=dup_table;
	BY _ALL_;
RUN;

/* NOTE: dropped two obs, one for 3/4 and one for 3/5 */
/* create df of deaths by age group, excluding unk age */
data libYPLL.death_age_group;
	set libYPLL.dedup_table;

	if missing(Date) then
		delete;
	keep Date Deaths___Total Deaths___Age_0_17 Deaths___Age_18_29 
		Deaths___Age_30_39 Deaths___Age_40_49 Deaths___Age_50_59 Deaths___Age_60_69 
		Deaths___Age_70_79 Deaths___Age_80_;
run;

/* create df of deaths by gender group, excluding unk sex */
data libYPLL.death_sex_group;
	set libYPLL.dedup_table;

	if missing(Date) then
		delete;
	keep Date Deaths___Total Deaths___Female Deaths___Male;
run;

/* create df of deaths by race/eth group */
data libYPLL.death_race_group;
	set libYPLL.dedup_table;

	if missing(Date) then
		delete;
	keep Date Deaths___Total Deaths___Latinx Deaths___Asian_Non_Latinx 
		Deaths___Black_Non_Latinx Deaths___White_Non_Latinx 
		Deaths___Other_Race_Non_Latinx Deaths___Unknown_Race_Ethnicity;
run;

/* create summary stats for each death data subset */
proc means data=libYPLL.death_age_group sum;
	var _all_;
run;

proc means data=libYPLL.death_sex_group sum;
	var _all_;
run;

proc means data=libYPLL.death_race_group sum;
	var _all_;
run;

/*------------------------------------------------------------------------------------------*/
/*								END - Data ETL 											*/
/*------------------------------------------------------------------------------------------*/


/*------------------------------------------------------------------------------------------*/
/*								START - Age Group Data										*/
/*------------------------------------------------------------------------------------------*/

%INCLUDE "&ypllsrc.PopAdjustmentWeight.sas";

/*------------------------------------------------------------------------------------------*/
/*								END - Age Group Data										*/
/*------------------------------------------------------------------------------------------*/


/*------------------------------------------------------------------------------------------*/
/*								START - Age Group Data										*/
/*------------------------------------------------------------------------------------------*/

%INCLUDE "&ypllsrc.AgeGroupData_YPLL.sas";

/*------------------------------------------------------------------------------------------*/
/*								END - Age Group Data										*/
/*------------------------------------------------------------------------------------------*/


/*------------------------------------------------------------------------------------------*/
/*								START - Gender Group Data									*/
/*------------------------------------------------------------------------------------------*/

%INCLUDE "&ypllsrc.GenderData_YPLL.sas";

/*------------------------------------------------------------------------------------------*/
/*								END - Gender Group Data										*/
/*------------------------------------------------------------------------------------------*/


/*------------------------------------------------------------------------------------------*/
/*								START - Race/Eth Group Data									*/
/*------------------------------------------------------------------------------------------*/

%INCLUDE "&ypllsrc.RaceEthData_YPLL.sas";

/*------------------------------------------------------------------------------------------*/
/*								END - Race/Eth Group Data									*/
/*------------------------------------------------------------------------------------------*/


/*------------------------------------------------------------------------------------------*/
/*								START - Visualize Data										*/
/*------------------------------------------------------------------------------------------*/

%INCLUDE "&ypllsrc.PlotData_YPLL.sas";

/*------------------------------------------------------------------------------------------*/
/*								END - Visualize Data										*/
/*------------------------------------------------------------------------------------------*/


/*------------------------------------------------------------------------------------------*/
/*								START - Output Data	+ Graphs								*/
/*------------------------------------------------------------------------------------------*/

/* copies final data tables to Excel workbook "output" */
data xlout.age_group_ypll_qd_final;
set libypll.age_group_ypll_qd_final;
run;

data xlout.ypll_age_group_sum_final;
set libypll.ypll_age_group_sum_final;
run;

data xlout.age_group_ypll_rate_final;
set libypll.age_group_ypll_rate_final;
run;

data xlout.age_group_rate_adj_final;
set libypll.age_group_rate_adj_final;
run;

data xlout.race_ypll_final;
	set libypll.race_ypll_final;
run;

data xlout.sex_ypll_final;
	set libypll.sex_ypll_final;
run;

data xlout.pop_adj_chi;
	set data libYPLL.pop_adj_chi;
run;

/* clearing libname ref for xlout to output file */
libname xlout clear;

/*------------------------------------------------------------------------------------------*/
/*								END - Output Data + Graphs									*/
/*------------------------------------------------------------------------------------------*/