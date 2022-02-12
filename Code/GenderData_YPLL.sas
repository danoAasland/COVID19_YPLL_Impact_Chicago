/* YPLL for gender */
/* drop any obs where death total for the day was 0 */
data work.sex_group_nomiss;
	set libypll.death_sex_group;
	where deaths___total NE 0;
run;

/* inner join death by age group data with gender data on date */
proc sql;
	create table work.sex_group_age as select * from work.sex_group_nomiss as s, 
		libYPLL.death_age_group as d where s.date=d.date;
quit;

/* these are YPLL mean for each age group */
/* 68.8	53.8	42.8	32.8	22.8	12.8	6.3	8.6	 */
*proc contents data=libypll.sex_ypll_final short;
*run;

/*
Date
Deaths___Age_0_17
Deaths___Age_18_29
Deaths___Age_30_39
Deaths___Age_40_49
Deaths___Age_50_59
Deaths___Age_60_69
Deaths___Age_70_79
Deaths___Age_80_
Deaths___Female
Deaths___Male
Deaths___Total
*/
/* convert death counts within age groups to YPLL QD */
data work.YPLL_daily_age;
	set work.sex_group_age;
	by date;

	if Deaths___Age_0_17 > 0 then
		age1_qd=(Deaths___Age_0_17*68.8);
	else if Deaths___Age_0_17=0 then
		age1_qd=0;

	if Deaths___Age_18_29 > 0 then
		age2_qd=(Deaths___Age_18_29*53.8);
	else if Deaths___Age_18_29=0 then
		age2_qd=0;

	if Deaths___Age_30_39 > 0 then
		age3_qd=(Deaths___Age_30_39*42.8);
	else if Deaths___Age_30_39=0 then
		age3_qd=0;

	if Deaths___Age_40_49 > 0 then
		age4_qd=(Deaths___Age_40_49*32.8);
	else if Deaths___Age_40_49=0 then
		age4_qd=0;

	if Deaths___Age_50_59 > 0 then
		age5_qd=(Deaths___Age_50_59*22.8);
	else if Deaths___Age_50_59=0 then
		age5_qd=0;

	if Deaths___Age_60_69 > 0 then
		age6_qd=(Deaths___Age_60_69*12.8);
	else if Deaths___Age_60_69=0 then
		age6_qd=0;

	if Deaths___Age_70_79 > 0 then
		age7_qd=(Deaths___Age_70_79*6.3);
	else if Deaths___Age_70_79=0 then
		age7_qd=0;

	if Deaths___Age_80_ > 0 then
		age8_qd=(Deaths___Age_80_*8.6);
	else if Deaths___Age_80_=0 then
		age8_qd=0;
run;

/* retain date gender groups and sum of YPLL daily */
data work.ypll_daily_sex_sum;
	set work.YPLL_daily_age;
	by date;
	ypll_sum_qd=age1_qd + age2_qd + age3_qd + age4_qd + age5_qd + age6_qd + age7_qd + age8_qd;
	keep date Deaths___Female Deaths___Male Deaths___Total ypll_sum_qd;
run;

/* get proportion of each daily YPLL by gender */
data work.sex_proportion_qd;
	set work.ypll_daily_sex_sum;
	female_pct=((Deaths___Female/Deaths___Total)*ypll_sum_qd);
	male_pct=((Deaths___Male/Deaths___Total)*ypll_sum_qd);
	female_ypll_sum + female_pct;
	male_ypll_sum + male_pct;
run;

/*  FINAL OUTPUT DATASET FOR GENDER */
/* calculate YPLL rate reflects cumsum by gender by gender */
data libypll.sex_ypll_final;
	set work.sex_proportion_qd;
	female_ypll_rate=((female_ypll_sum/1386113)*100000);
	male_ypll_rate=((male_ypll_sum/1319875)*100000);
	keep Date female_ypll_rate male_ypll_rate female_ypll_sum male_ypll_sum 
		Deaths___Female Deaths___Male Deaths___Total ypll_sum_qd;
run;
