/* Plotting output into various charts */
/* YPLL RATE RAW - AGE GROUP */
proc transpose data=libYPLL.age_group_ypll_rate_final out=work.tmpDF1;
run;

data work.tmpDF1;
	set work.tmpDF1;
	rename _name_=Age_Groups COL1=Rate_per_100K;

	if _name_="ypll_total_rate" then
		_name_="All Ages Total";
	else if _name_="ypll_yrs_age1_rate" then
		_name_="Ages 0-17";
	else if _name_="ypll_yrs_age2_rate" then
		_name_="Ages 18-29";
	else if _name_="ypll_yrs_age3_rate" then
		_name_="Ages 30-39";
	else if _name_="ypll_yrs_age4_rate" then
		_name_="Ages 40-49";
	else if _name_="ypll_yrs_age5_rate" then
		_name_="Ages 50-59";
	else if _name_="ypll_yrs_age6_rate" then
		_name_="Ages 60-69";
	else if _name_="ypll_yrs_age7_rate" then
		_name_="Ages 70-79";
	else if _name_="ypll_yrs_age8_rate" then
		_name_="Ages 80+";
	format COL1 comma10.;
run;

/* YPLL RATE AGE-ADJUSTED - AGE GROUP */
proc transpose data=libYPLL.age_group_rate_adj_final out=work.tmpDF2;
run;

data work.tmpDF2;
	set work.tmpDF2;
	rename _name_=Age_Groups COL1=Rate_per_100K;

	if _name_="ypll_total_rate_adj" then
		_name_="All Ages Total";
	else if _name_="ypll_yrs_age1_rate_adj" then
		_name_="Ages 0-17";
	else if _name_="ypll_yrs_age2_rate_adj" then
		_name_="Ages 18-29";
	else if _name_="ypll_yrs_age3_rate_adj" then
		_name_="Ages 30-39";
	else if _name_="ypll_yrs_age4_rate_adj" then
		_name_="Ages 40-49";
	else if _name_="ypll_yrs_age5_rate_adj" then
		_name_="Ages 50-59";
	else if _name_="ypll_yrs_age6_rate_adj" then
		_name_="Ages 60-69";
	else if _name_="ypll_yrs_age7_rate_adj" then
		_name_="Ages 70-79";
	else if _name_="ypll_yrs_age8_rate_adj" then
		_name_="Ages 80+";
	format COL1 comma10.;
run;

/* YPLL YEAR SUMS - AGE GROUP */
proc transpose data=libYPLL.ypll_age_group_sum_final out=work.tmpDF3;
run;

data work.tmpDF3;
	set work.tmpDF3;
	rename _name_=Age_Groups COL1=Years;

	if _name_="ypll_total" then
		_name_="All Ages Total";
	else if _name_="ypll_yrs_age1" then
		_name_="Ages 0-17";
	else if _name_="ypll_yrs_age2" then
		_name_="Ages 18-29";
	else if _name_="ypll_yrs_age3" then
		_name_="Ages 30-39";
	else if _name_="ypll_yrs_age4" then
		_name_="Ages 40-49";
	else if _name_="ypll_yrs_age5" then
		_name_="Ages 50-59";
	else if _name_="ypll_yrs_age6" then
		_name_="Ages 60-69";
	else if _name_="ypll_yrs_age7" then
		_name_="Ages 70-79";
	else if _name_="ypll_yrs_age8" then
		_name_="Ages 80+";
	format COL1 comma10.;
run;

/* YPLL YEAR SUMS - GENDER GROUP */
data work.tmpDF4;
	set libypll.sex_ypll_final;
	where date='07FEB22'd;
	keep female_ypll_sum male_ypll_sum;
run;

proc transpose data=work.tmpDF4 out=work.tmpDF4;
run;

data work.tmpDF4;
	set work.tmpDF4;
	rename _name_=Gender COL1=Years;

	if _name_="female_ypll_sum" then
		_name_="Female";
	else if _name_="male_ypll_sum" then
		_name_="Male";
	COL1=round(COL1);
	format COL1 comma10.;
run;

/* YPLL YEAR RATE - GENDER GROUP */
data tmpDF5;
	set libypll.sex_ypll_final;
	where date='07FEB22'd;
	keep female_ypll_rate male_ypll_rate;
run;

proc transpose data=work.tmpDF5 out=tmpDF5;
run;

data tmpDF5;
	set tmpDF5;
	rename _name_=Rate COL1=Years;

	if _name_="female_ypll_rate" then
		_name_="Female";
	else if _name_="male_ypll_rate" then
		_name_="Male";
	COL1=round(COL1);
	format COL1 comma10.;
run;

/* YPLL YEAR SUMS - RACE/ETH GROUP */
data tmpDF6;
	set libypll.RACE_YPLL_FINAL;
	where date='07FEB22'd;
	keep asian_ypll_sum black_ypll_sum latinx_ypll_sum white_ypll_sum 
		other_ypll_sum unk_ypll_sum;
run;

proc transpose data=work.tmpDF6 out=tmpDF6;
run;

data tmpDF6;
	set tmpDF6;
	rename _name_=Race_Ethnicity COL1=Years;

	if _name_="asian_ypll_sum" then
		_name_="Asian";
	else if _name_="black_ypll_sum" then
		_name_="Black";
	else if _name_="latinx_ypll_sum" then
		_name_="Latinx";
	else if _name_="white_ypll_sum" then
		_name_="White";
	else if _name_="other_ypll_sum" then
		_name_="Other";
	else if _name_="unk_ypll_sum" then
		_name_="Unknown";
	COL1=round(COL1);
	format COL1 comma10.;
run;

/* YPLL YEAR RATE - RACE/ETH GROUP */
data tmpDF7;
	set libypll.RACE_YPLL_FINAL;
	where date='07FEB22'd;
	keep asian_ypll_rate black_ypll_rate latinx_ypll_rate white_ypll_rate 
		other_ypll_rate unk_ypll_rate;
run;

proc transpose data=work.tmpDF7 out=tmpDF7;
run;

data tmpDF7;
	set tmpDF7;
	rename _name_=Race_Ethnicity COL1=Years;

	if _name_="asian_ypll_rate" then
		_name_="Asian";
	else if _name_="black_ypll_rate" then
		_name_="Black";
	else if _name_="latinx_ypll_rate" then
		_name_="Latinx";
	else if _name_="white_ypll_rate" then
		_name_="White";
	else if _name_="other_ypll_rate" then
		_name_="Other";
	else if _name_="unk_ypll_rate" then
		_name_="Unknown";
	COL1=round(COL1);
	format COL1 comma10.;
run;

data work.tmpDF8;
	set libypll.RACE_YPLL_FINAL;
	keep date asian_ypll_rate black_ypll_rate latinx_ypll_rate white_ypll_rate 
		other_ypll_rate unk_ypll_rate asian_ypll_sum black_ypll_sum white_ypll_sum 
		latinx_ypll_sum;
	label asian_ypll_rate="Asian" black_ypll_rate="Black" 
		latinx_ypll_rate="Latinx" white_ypll_rate="White" other_ypll_rate="Other" 
		unk_ypll_rate="Unknown" asian_ypll_sum="Asian" black_ypll_sum="Black" 
		latinx_ypll_sum="Latinx" white_ypll_sum="White" other_ypll_sum="Other" 
		unk_ypll_sum="Unknown";
run;

/* CHART OUTPUTS FOR ALL THE TEMP DFs MADE */
/* set output to add charts to output.xlsx file, one per worksheet */
ods excel file="&outpath" style=sasdocprinter options(sheet_name='YPLLRateAge');
TITLE1 "Years of Potential Life Lost (YPLL) Rate by Age Group";
TITLE2 "COVID-19 Impact | Chicago 2020 to Current";
footnote "Note: Life Expectancy: Ages < 70 LE 78.2 Yrs | 70-79 LE 81.3 Yrs | 80+ LE 88.6 Yrs";
footnote2 "Age 80+ Est. Population 79,986";

proc sgplot data=work.tmpDF1 noborder;
	vbar Age_Groups / response=Rate_per_100K datalabel dataskin=matte 
		baselineattrs=(thickness=0) fillattrs=(color=Tomato);
	xaxis display=(noline noticks);
	yaxis display=(noline noticks);
	xaxis label='Age Groups';
	yaxis label='Rate Per 100,000 Population' grid;
run;

ods excel options(sheet_name='YPLLRateAgeAdj');
TITLE1 "Years of Potential Life Lost (YPLL) Rate by Age Group, Age-Adjusted";
TITLE2 "COVID-19 Impact | Chicago 2020 to Current";
footnote "Note: Life Expectancy: Ages < 70 LE 78.2 Yrs | 70-79 LE 81.3 Yrs | 80+ LE 88.6 Yrs";

proc sgplot data=work.tmpDF2 noborder;
	vbar Age_Groups / response=Rate_per_100K datalabel dataskin=matte 
		baselineattrs=(thickness=0) fillattrs=(color=Tomato);
	xaxis display=(noline noticks);
	yaxis display=(noline noticks);
	xaxis label='Age Groups';
	yaxis label='Rate Per 100,000 Population' grid;
run;

ods excel options(sheet_name='YPLLSumAge');
TITLE1 "Total Years of Potential Life Lost (YPLL) by Age Group";
TITLE2 "COVID-19 Impact | Chicago 2020 to Current";
footnote "Note: Life Expectancy: Ages < 70 LE 78.2 Yrs | 70-79 LE 81.3 Yrs | 80+ LE 88.6 Yrs";

proc sgplot data=work.tmpDF3 noborder;
	vbar Age_Groups / response=Years datalabel dataskin=matte 
		baselineattrs=(thickness=0) fillattrs=(color=OliveDrab);
	xaxis display=(noline noticks);
	yaxis display=(noline noticks);
	xaxis label='Age Groups';
	yaxis label='Years' grid;
run;

ods excel options(sheet_name='YPLLSumGender');
TITLE1 "Total Years of Potential Life Lost (YPLL) by Gender";
TITLE2 "COVID-19 Impact | Chicago 2020 to Current";
footnote "Note: Life Expectancy: Ages < 70 LE 78.2 Yrs | 70-79 LE 81.3 Yrs | 80+ LE 88.6 Yrs";

proc sgplot data=work.tmpDF4 noborder;
	vbar Gender / response=Years datalabel dataskin=matte 
		baselineattrs=(thickness=0) fillattrs=(color=CornFlowerBlue);
	xaxis display=(noline noticks);
	yaxis display=(noline noticks);
	xaxis label='Gender';
	yaxis label='Years' grid;
run;

ods excel options(sheet_name='YPLLRateGender');
TITLE1 "Years of Potential Life Lost (YPLL) Rate by Gender";
TITLE2 "COVID-19 Impact | Chicago 2020 to Current";
footnote "Note: Rate Expressed Per 100,000 Population";

proc sgplot data=work.tmpDF5 noborder;
	vbar Rate / response=Years datalabel dataskin=matte 
		baselineattrs=(thickness=0) fillattrs=(color=CornFlowerBlue);
	xaxis display=(noline noticks);
	yaxis display=(noline noticks);
	xaxis label='Gender';
	yaxis label='Years' grid;
run;

ods excel options(sheet_name='YPLLSumRaceEth');
TITLE1 "Total Years of Potential Life Lost (YPLL) by Race/Ethnicity";
TITLE2 "COVID-19 Impact | Chicago 2020 to Current";
footnote 'Note: Race/Eth Group Mean Used For "Unknown" ';

proc sgplot data=work.tmpDF6 noborder;
	vbar Race_Ethnicity / response=Years datalabel dataskin=matte 
		baselineattrs=(thickness=0) fillattrs=(color=Orange);
	xaxis display=(noline noticks);
	yaxis display=(noline noticks);
	xaxis label='Race Ethnicity Group';
	yaxis label='Years' grid;
run;

ods excel options(sheet_name='YPLLRateRaceEth');
TITLE1 "Years of Potential Life Lost (YPLL) Rate by Race/Ethnicity";
TITLE2 "COVID-19 Impact | Chicago 2020 to Current";
footnote 'Note: Race/Eth Group Mean Used For "Unknown" ';

proc sgplot data=work.tmpDF7 noborder;
	vbar Race_Ethnicity / response=Years datalabel dataskin=matte 
		baselineattrs=(thickness=0) fillattrs=(color=Orange);
	xaxis display=(noline noticks);
	yaxis display=(noline noticks);
	xaxis label='Race Ethnicity Group';
	yaxis label='Years' grid;
run;

ods excel options(sheet_name='YPLLSeriesSumRaceEth');
TITLE1 "Years of Potential Life Lost (YPLL) by Race/Ethnicity";
TITLE2 "COVID-19 Impact | Chicago 2020 to Current";
footnote 'Note: "Unknown" and "Other" Excluded';

proc sgplot data=work.tmpDF8;
	series x=date y=asian_ypll_sum / lineattrs=(color=red thickness=2 
		pattern=solid);
	series x=date y=black_ypll_sum / lineattrs=(color=blue thickness=2 
		pattern=solid);
	series x=date y=white_ypll_sum / lineattrs=(color=green thickness=2 
		pattern=solid);
	series x=date y=latinx_ypll_sum / lineattrs=(color=orange thickness=2 
		pattern=solid);
	xaxis label='Date' values=("01MAR20"d to "01MAR22"d by month);
	yaxis label='YPLL - Sum Years' grid;
run;

ods excel options(sheet_name='YPLLSeriesRateRaceEth');
TITLE1 "Years of Potential Life Lost (YPLL) Rate by Race/Ethnicity";
TITLE2 "COVID-19 Impact | Chicago 2020 to Current";
footnote 'Note: "Unknown" and "Other" Excluded';

proc sgplot data=work.tmpDF8;
	series x=date y=asian_ypll_rate / lineattrs=(color=red thickness=2 
		pattern=solid);
	series x=date y=black_ypll_rate / lineattrs=(color=blue thickness=2 
		pattern=solid);
	series x=date y=white_ypll_rate / lineattrs=(color=green thickness=2 
		pattern=solid);
	series x=date y=latinx_ypll_rate / lineattrs=(color=orange thickness=2 
		pattern=solid);
	xaxis label='Date' values=("01MAR20"d to "01MAR22"d by month);
	yaxis label='YPLL - Sum Years' grid;
run;

ods excel close;