/* YPLL by race/ethnicity */
/* MAIN dataset for this process libYPLL.death_race_group */
/* drop any obs where death total for the day was 0 */
data work.sex_race_nomiss;
	set libypll.death_race_group;
	where deaths___total NE 0;
run;

/* inner join death by age group data with race/eth data on date */
proc sql;
	create table work.race_group_age as select * from work.sex_race_nomiss as s, 
		libYPLL.death_age_group as d where s.date=d.date;
quit;

proc contents data=libypll.race_ypll_final short;
run;

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
Deaths___Asian_Non_Latinx
Deaths___Black_Non_Latinx
Deaths___Latinx
Deaths___Other_Race_Non_Latinx
Deaths___Total Deaths___Unknown_Race_Ethnicity
Deaths___White_Non_Latinx
*/
/* convert death counts within age groups to YPLL QD */
data work.YPLL_daily_race;
	set work.race_group_age;
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

/* retain date race/eth groups and sum of YPLL daily */
data work.ypll_daily_race_sum;
	set work.YPLL_daily_race;
	by date;
	ypll_sum_qd=age1_qd + age2_qd + age3_qd + age4_qd + age5_qd + age6_qd + age7_qd + age8_qd;
	keep date Deaths___Asian_Non_Latinx Deaths___Black_Non_Latinx Deaths___Latinx 
		Deaths___Other_Race_Non_Latinx Deaths___Total Deaths___Unknown_Race_Ethnicity 
		Deaths___White_Non_Latinx Deaths___Total ypll_sum_qd;
run;


/* get proportion of each daily YPLL by race/eth */
data work.race_proportion_qd;
	set work.ypll_daily_race_sum;
	asian_pct=((Deaths___Asian_Non_Latinx/Deaths___Total)*ypll_sum_qd);
	black_pct=((Deaths___Black_Non_Latinx/Deaths___Total)*ypll_sum_qd);
	latinx_pct=((Deaths___Latinx/Deaths___Total)*ypll_sum_qd);
	white_pct=((Deaths___White_Non_Latinx/Deaths___Total)*ypll_sum_qd);
	other_pct=((Deaths___Other_Race_Non_Latinx/Deaths___Total)*ypll_sum_qd);
	unk_pct=((Deaths___Unknown_Race_Ethnicity/Deaths___Total)*ypll_sum_qd);
	asian_ypll_sum + asian_pct;
	black_ypll_sum + black_pct;
	latinx_ypll_sum + latinx_pct;
	white_ypll_sum + white_pct;
	other_ypll_sum + other_pct;
	unk_ypll_sum + unk_pct;
run;

/*  FINAL OUTPUT DATASET FOR RACE/ETH */
/* calculate YPLL rate reflects cumsum by race/eth */
data libypll.race_ypll_final;
	set work.race_proportion_qd;
	asian_ypll_rate=((asian_ypll_sum/179841)*100000);
	black_ypll_rate=((black_ypll_sum/784266)*100000);
	latinx_ypll_rate=((latinx_ypll_sum/776661)*100000);
	white_ypll_rate=((white_ypll_sum/899980)*100000);
	other_ypll_rate=((other_ypll_sum/119467)*100000);
	unk_ypll_rate=((unk_ypll_sum/541198)*100000);
	keep Date asian_ypll_rate black_ypll_rate latinx_ypll_rate white_ypll_rate 
		other_ypll_rate unk_ypll_rate asian_ypll_sum black_ypll_sum latinx_ypll_sum 
		white_ypll_sum other_ypll_sum unk_ypll_sum ypll_sum_qd Deaths___Total;
run;
