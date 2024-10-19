% Impulse noise detection using ear model
% DRNL model based detection algorithm
% Authors: Marek Semansky, Frantisek Rund
% FEE CTU in Prague
% https://mmtg.fel.cvut.cz/click-detection/

%DRNL needs MAP Toolbox, function DRNL_MAP _14 (so, before run copy this
%function into the folder)
% MAP Toolbox: https://github.com/rmeddis/MAP


function [det, elapsed_time] = JAES_DRNL(sada, start_sig, num_sig, threshold_gain, channels_start, sig_list)

% Detection parameter settings
channels = channels_start:21  % 13:21; %channels (bands) selection
thr_const = threshold_gain;  %threshold constant 22 opt


tic
load IR/semansky_MAP_DRNL_impBM.mat %impulse response loading
impBM = tempBM(9.8e3:10.7e3,:); %select the right segment of IR
counter = 0;
listing = dir(sada);
NumSig = size(sig_list,1);
det(NumSig)=0;
for nstim = sig_list
    counter = counter+1;
    [y, fs] = audioread([sada listing(nstim+2).name]); %signal loading
    y = y(:, 1);% Limit to the first channel only

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
    
%DRNL filtering
    [tempBM] = DRNL_MAP1_14(sig_in, fs)'; %https://github.com/rmeddis/MAP
    
%correlation
    [Ns, Nch] = size(tempBM);
    [Nimp] = size(impBM,1);
    steps = floor(Ns/Nimp);
    corr_out = [];
    %xcoutj(steps,Nch)=0;
    for k=1:steps
        for ch=1:Nch
            xcoutj(:,ch) = xcorr(impBM(:,ch),tempBM(1+(k-1)*Nimp:k*Nimp,ch),'coeff');
        end
        corr_out = [corr_out; xcoutj];
    end


%% Detection parameter settings
% channels = 13:21; %channels (bands) selection
% thr_const = threshold_gain;  %threshold constant 22 opt

%detection evaluation
    if max(abs(sum(corr_out(:, channels), 2)))>thr_const*mean(abs(sum(corr_out(:, channels), 2)))
        det(counter) = 1;
    else
        det(counter) = 0;
    end
    
    %elapsed_time = toc; %time elapsed
end
elapsed_time = toc; %time elapsed