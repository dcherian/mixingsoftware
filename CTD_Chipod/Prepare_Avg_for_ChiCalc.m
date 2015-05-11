function [avg todo_inds]=Prepare_Avg_for_ChiCalc(nfft,chi_todo_now,ctd)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function avg=Prepare_Avg_for_ChiCalc(nfft,chi_todo_now,ctd)
%
%
% May 11, 2015 - A. Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%
% make a structure 'avg' will will contain the results
% of chi computed in overlapping windows
clear avg
avg=struct();
%nfft=128;

% AP - for new up/down separated chi structures
todo_inds=1:nfft/2:(length(chi_todo_now.datenum)-nfft);
todo_inds=todo_inds(:);

tfields={'datenum','P','N2','dTdz','fspd','T','S','P','theta','sigma',...
    'chi1','eps1','chi2','eps2','KT1','KT2','TP1var','TP2var'};
for n=1:length(tfields)
    avg.(tfields{n})=NaN*ones(size(todo_inds));
end

% new AP
avg.datenum=chi_todo_now.datenum(todo_inds+(nfft/2));% This is the mid-value of the bin
avg.P=chi_todo_now.P(todo_inds+(nfft/2));
good_inds=find(~isnan(ctd.p));

% interpolate ctd data to same pressures as chipod
avg.N2=interp1(ctd.p(good_inds),ctd.N2(good_inds),avg.P);
avg.dTdz=interp1(ctd.p(good_inds),ctd.dTdz(good_inds),avg.P);
avg.T=interp1(ctd.p(good_inds),ctd.t1(good_inds),avg.P);
avg.S=interp1(ctd.p(good_inds),ctd.s1(good_inds),avg.P);

% note sw_visc not included in newer versions of sw?
% avg.nu=sw_visc(avg.S,avg.T,avg.P);
avg.nu=sw_visc_ctdchi(avg.S,avg.T,avg.P);
% avg.tdif=sw_tdif(avg.S,avg.T,avg.P);
avg.tdif=sw_tdif_ctdchi(avg.S,avg.T,avg.P);

avg.samplerate=1./nanmedian(diff(chi_todo_now.datenum))/24/3600;

return
%%