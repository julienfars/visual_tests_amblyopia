function modeloT=LIKELOGISTIC4AFC(estimatedthreshold)

%%New parameters for the likelihood function. Dr. Ignacio Serrano-Pedraza
%%23-8-2016

%%Old function can be found at LIKELOGISTIC4AFC_old.m 8/25/16 AMG

sigma=1.5;
delta=0.0180;
pg=0.25;% guessing rate 0.5 for 2AFC   0.0 for yes-no
pl=0.04*(1-pg);%Lapsing rate assuming 4 sneezes every 100 trials

%*****************************
pii=0.75;% %%0.82 Tadin et al 2003 (They used 0.82 in Quest)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b=(2/sigma)*log((1-pl-pg-delta)/delta);
a=(1/b)*log((1-pl-pii)/(pii-pg));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%m=[0.1:0.001:3,9]; %%Changed per Ignacio 9/6/2016 AMG
m=linspace(log10(1),log10(3600),1000);%%Disparity in log units
modeloT=pg+((1-pl-pg)./(1+exp(b*(a+m-estimatedthreshold))));%Logistic function
