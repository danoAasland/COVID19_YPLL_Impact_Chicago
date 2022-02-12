/* YPLL calc for age groups */
/*
Date
Deaths___Total
Deaths___Age_0_17
Deaths___Age_18_29
Deaths___Age_30_39
Deaths___Age_40_49
Deaths___Age_50_59
Deaths___Age_60_69
Deaths___Age_70_79
Deaths___Age_80_
*/
/* create subset with days with no deaths excluded */
data work.age_group_nomiss;
	set libYPLL.death_age_group;
	where deaths___total NE 0;
run;

/* get midpoint */
data work.age_group_midpoint;
	set work.age_group_nomiss (obs=1);
	midpoint_age1=((0 + 17 + 1)/2);
	midpoint_age2=((18 + 29 + 1)/2);
	midpoint_age3=((30 + 39 + 1)/2);
	midpoint_age4=((40 + 49 + 1)/2);
	midpoint_age5=((50 + 59 + 1)/2);
	midpoint_age6=((60 + 69 + 1)/2);
	midpoint_age7=((70 + 79 + 1)/2);
	midpoint_age8=80;
	keep midpoint_age1-midpoint_age8;
run;

/* subtract midpoint from mean LE for Chicago (77.8) age 70 LE 81.3, age 80 LE 88.6 */
data work.age_group_le;
	set work.age_group_midpoint (obs=1);
	ypll_age1=(77.8 - midpoint_age1);
	ypll_age2=(77.8 - midpoint_age2);
	ypll_age3=(77.8 - midpoint_age3);
	ypll_age4=(77.8 - midpoint_age4);
	ypll_age5=(77.8 - midpoint_age5);
	ypll_age6=(77.8 - midpoint_age6);
	ypll_age7=(81.3 - midpoint_age7);
	ypll_age8=(88.6 - midpoint_age8);
	keep ypll_age1-ypll_age8;
run;

*proc contents data=work.age_group_nomiss short;
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
Deaths___Total
*/
/*  converted each obs count by age group into YPLL (remain LE * number of deaths) */
/* sum of YPLL daily */
/* FINAL OUTPUT - YPLL in Years With Row Sum = Daily */
data libypll.age_group_ypll_qd_final;
	if _n_=1 then
		set work.age_group_le;
	set work.age_group_nomiss;
	ypll_yrs_age1=(ypll_age1*Deaths___Age_0_17);
	ypll_yrs_age2=(ypll_age2*Deaths___Age_18_29);
	ypll_yrs_age3=(ypll_age3*Deaths___Age_30_39);
	ypll_yrs_age4=(ypll_age4*Deaths___Age_40_49);
	ypll_yrs_age5=(ypll_age5*Deaths___Age_50_59);
	ypll_yrs_age6=(ypll_age6*Deaths___Age_60_69);
	ypll_yrs_age7=(ypll_age7*Deaths___Age_70_79);
	ypll_yrs_age8=(ypll_age8*Deaths___Age_80_);
	ypll_sum_qd=ypll_yrs_age1 + ypll_yrs_age2 + ypll_yrs_age3 + ypll_yrs_age4 + ypll_yrs_age5 + ypll_yrs_age6 + ypll_yrs_age7 + ypll_yrs_age8;
	ypll_cumsum + ypll_sum_qd;
	keep date ypll_yrs_age1-ypll_yrs_age8 ypll_sum_qd ypll_cumsum;
run;

/* sum of YPLL daily */
data work.ypll_daily_age_sum_final;
	set libypll.age_group_ypll_qd_final;
	by date;
	ypll_sum_qd=ypll_yrs_age1 + ypll_yrs_age2 + ypll_yrs_age3 + ypll_yrs_age4 + ypll_yrs_age5 + ypll_yrs_age6 + ypll_yrs_age7 + ypll_yrs_age8;
run;

/* total YPLL by age group */
PROC MEANS DATA=work.ypll_daily_age_sum_final sum;
	VAR ypll_sum_qd ypll_yrs_age1-ypll_yrs_age8;
	output out=ypll_age_group_sum sum(ypll_sum_qd)=ypll_total 
		sum(ypll_yrs_age1)=ypll_yrs_age1 sum(ypll_yrs_age2)=ypll_yrs_age2 
		sum(ypll_yrs_age3)=ypll_yrs_age3 sum(ypll_yrs_age4)=ypll_yrs_age4 
		sum(ypll_yrs_age5)=ypll_yrs_age5 sum(ypll_yrs_age6)=ypll_yrs_age6 
		sum(ypll_yrs_age7)=ypll_yrs_age7 sum(ypll_yrs_age8)=ypll_yrs_age8;
RUN;

/* drop type and freq cols */
/* FINAL OUTPUT - YPLL Agg by Each Age Group */
data libypll.ypll_age_group_sum_final;
	set work.ypll_age_group_sum;
	drop _TYPE_ _FREQ_;
run;

/*  FOR NEXT DF DO AGE RATE CALCS AND AGE-ADJUSTED CALCS */
*proc contents data=libypll.ypll_age_group_sum short;
*run;

/*
ypll_total
ypll_yrs_age1
ypll_yrs_age2
ypll_yrs_age3
ypll_yrs_age4
ypll_yrs_age5
ypll_yrs_age6
ypll_yrs_age7
ypll_yrs_age8
*/
/* FINAL OUTPUT - YPLL Rate Per 100K */
data libypll.age_group_ypll_rate_final;
	set libypll.ypll_age_group_sum_final;
	ypll_total_rate=round((ypll_total/2705988)*100000);
	ypll_yrs_age1_rate=round((ypll_yrs_age1/548999)*100000);
	ypll_yrs_age2_rate=round((ypll_yrs_age2/552935)*100000);
	ypll_yrs_age3_rate=round((ypll_yrs_age3/456321)*100000);
	ypll_yrs_age4_rate=round((ypll_yrs_age4/336457)*100000);
	ypll_yrs_age5_rate=round((ypll_yrs_age5/312965)*100000);
	ypll_yrs_age6_rate=round((ypll_yrs_age6/262991)*100000);
	ypll_yrs_age7_rate=round((ypll_yrs_age7/155334)*100000);
	ypll_yrs_age8_rate=round((ypll_yrs_age8/79986)*100000);
	keep ypll_total_rate ypll_yrs_age1_rate ypll_yrs_age2_rate ypll_yrs_age3_rate 
		ypll_yrs_age4_rate ypll_yrs_age5_rate ypll_yrs_age6_rate ypll_yrs_age7_rate 
		ypll_yrs_age8_rate;
run;

/* FINAL OUTPUT - YPLL Age-adjusted Rate Per 100K */
data libypll.age_group_rate_adj_final;
	set libypll.age_group_ypll_rate_final;
	ypll_yrs_age1_rate_adj=round(ypll_yrs_age1_rate*0.25773);
	ypll_yrs_age2_rate_adj=round(ypll_yrs_age2_rate*0.16014);
	ypll_yrs_age3_rate_adj=round(ypll_yrs_age3_rate*0.15181);
	ypll_yrs_age4_rate_adj=round(ypll_yrs_age4_rate*0.15397);
	ypll_yrs_age5_rate_adj=round(ypll_yrs_age5_rate*0.11117);
	ypll_yrs_age6_rate_adj=round(ypll_yrs_age6_rate*0.07306);
	ypll_yrs_age7_rate_adj=round(ypll_yrs_age7_rate*0.05877);
	ypll_yrs_age8_rate_adj=round(ypll_yrs_age8_rate*0.03335);
	ypll_total_rate_adj=round(sum(ypll_yrs_age1_rate_adj, ypll_yrs_age2_rate_adj, 
		ypll_yrs_age3_rate_adj, ypll_yrs_age4_rate_adj, ypll_yrs_age5_rate_adj, 
		ypll_yrs_age6_rate_adj, ypll_yrs_age7_rate_adj, ypll_yrs_age8_rate_adj));
	keep ypll_total_rate_adj ypll_yrs_age1_rate_adj ypll_yrs_age2_rate_adj 
		ypll_yrs_age3_rate_adj ypll_yrs_age4_rate_adj ypll_yrs_age5_rate_adj 
		ypll_yrs_age6_rate_adj ypll_yrs_age7_rate_adj ypll_yrs_age8_rate_adj;
run;
