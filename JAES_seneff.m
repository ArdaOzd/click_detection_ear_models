% Impulse noise detection using ear model
% Seneff model based detection algorithm 
% Authors: Marek Semansky, Frantisek Rund
% FEE CTU in Prague
% https://mmtg.fel.cvut.cz/click-detection/

%S. Seneff, „A joint synchrony/mean-rate model of auditory speech
%processing,“ Journal of Phonetics, pp. 55-76, 1988

%Needs M. Slaney Auditory Toolbox
%https://engineering.purdue.edu/~malcolm/interval/1998-010/ (tested at v2)

function [det, elapsed_time] = JAES_seneff(sada, start_sig, num_sig, threshold_gain, channels_end, med_len,sig_list)

% Detection parameter settings
channels = 1:channels_end; %channels (bands) selection
coef_thr = threshold_gain; % 7.2
% med_len = 150; %median filter length


tic
addpath('Aud_tbx')
load IR/semansky_seneff_impBM.mat %impulse response loading
impBM = impBM(9170:10070, :); %select the right segment of IR
counter = 0;
listing = dir(sada);
NumSig = size(sig_list,1);
det(NumSig)=0;

for nstim = sig_list
    counter = counter+1;    
    [y, fs] = audioread([sada listing(  nstim+2).name]); %signal loading
    y = y(:, 1); % Limit to the first channel only
    
%resampling if necessary
    if fs~=44.1e3
        yresamp = resample(y,44.1e3,fs);
        fs = 44.1e3;
    else
        yresamp = y;
    end
    sig_in = yresamp;
    
%normalization
    Lref = 94;
    Lset = Lref + 20*log10(sqrt(mean(y.^2))*sqrt(2));
    sig_in = 2e-5*10^(Lset/20)*sig_in;
    

%hearing model applied
    [tempBM] = SeneffEar(sig_in, fs, 0); % https://engineering.purdue.edu/~malcolm/interval/1998-010/
    tempBM = tempBM';

%correlation
[~, Nch] = size(tempBM);
corr_out = [];
%corr_out(Ns,Nch) = 0;
for k = 1:Nch
    corr_out(:, k) = xcorr(tempBM(:, k), impBM(:, k));
end

%% Detection parameter settings
%     channels = 1:12; %channels (bands) selection
%     coef_thr = 7.2; %threshold constant 
%     coef_thr = threshold_gain;
%     med_len = 150; %median filter length
    
%detection threshold and detection signal
    corr_out = corr_out(round(0.5669*length(corr_out)):round(0.9779*length(corr_out)), :);
    corr_out = corr_out - mean(corr_out);
    corr_out_sum = sum(abs(corr_out(:, channels)), 2);
    corr_out_sum(1:20, 1) = 0;
    
    threshold = medfilt1(sum(abs(corr_out(:, channels)), 2), med_len);

%detection evaluation
    if sum(corr_out_sum > threshold*coef_thr) > 0
        det(counter) = 1;
    else
        det(counter) = 0;
    end
    
    
end
elapsed_time = toc; %time elapsed