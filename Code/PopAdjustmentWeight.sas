/* create population weights to age-adjust, U.S. Census 2000 data */
/* creating df of census data 2000 */
data work.pop_weights_2000;
	length age_group $1;
	input age_group $ pop_count pop_weight;
	datalines;
1 3795 0.013818
1 3759 0.013687
1 11433 0.041630
1 3896 0.014186
1 11800 0.042966
1 4224 0.015380
1 8258 0.030069
1 11799 0.042963
1 11819 0.043035
2 8001 0.029133
2 18257 0.066478
2 17722 0.064530
3 19511 0.071044
3 22180 0.080762
4 22479 0.081851
4 19806 0.072118
5 17224 0.062716
5 13307 0.048454
6 10654 0.038793
6 9410 0.034264
7 8726 0.031773
7 7415 0.027000
8 4900 0.017842
8 4259 0.015508
;
run;

/* creating pop count and age-adjustment weights aligned to death df */
/* 8 rows that align to the 8 age-groups in the chicago death data */
data libYPLL.pop_adj_chi;
	set work.pop_weights_2000;
	by age_group;

	if first.age_group then
		do;
			pop_cnt_sum=0;
			pop_wght_sum=0;
		end;
	pop_cnt_sum + pop_count;
	pop_wght_sum + pop_weight;

	if last.age_group;
	keep pop_cnt_sum pop_wght_sum;
run;