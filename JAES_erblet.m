% Impulse noise detection using ear model
% ERBlet based detection algorithm 
% Authors: Marek Semansky, Frantisek Rund
% FEE CTU in Prague
% https://mmtg.fel.cvut.cz/click-detection/

% ERBlet:
% http://www.kfs.oeaw.ac.at/ICASSP2013_ERBlets
% T. Necciari, P. Balasz, N. Holighaus a P. Sondergaard, „The Erblet
% Transform: An Auditory-Based Time-Frequency Representation with Perfect
% Reconstruction,“ v 2013 IEEE International Conference on Acoustics, Speech and Signal Processing, Vancouver, 2013.


% Erblet needs AMT (http://amtoolbox.sourceforge.net/) (or LTFAT) - install AMT and then run amtstart





function [det, elapsed_time] = JAES_erblet(sada, start_sig, num_sig, threshold_gain, med_len,channel_start, sig_list)
%det = [];


% detection parameters
% med_len = 70;
med_mul = threshold_gain; % threshold
% channel_start = 30;

tic
counter = 0;
listing = dir(sada);
NumSig = size(sig_list,1);
det(90)=0;
for nstim=sig_list
    counter = counter+1;
    [y, fs] = audioread([sada listing(nstim+2).name]); %signal loading

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
    

% Erblet transform
% https://www.kfs.oeaw.ac.at/index.php?option=com_content&view=article&id=672:icassp2013-erblets&catid=198&lang=en&Itemid=794
addpath('Erblets')
%addpath('amtoolbox_0.01/general/')
[coef,~,~,~,~] = erblet(sig_in,fs,1); 
    
% Interpolation of erblet coefficients
    coef_interp = [];
    for i = 1:size(coef, 1)
        interp_x = 0:1/size(coef{i, 1}, 1):1-1/size(coef{i, 1}, 1);
        interp_v = coef{i, 1};
        interp_xq = 0:1/size(coef{end/2+1, 1}, 1):1-1/size(coef{end/2+1, 1}, 1);
        coef_interp = [coef_interp; interp1(interp_x, interp_v, interp_xq)];
    end
    nans = find(isnan(coef_interp(1, :)));
    coef_interp_real = real(coef_interp(:, 1:nans(1)-1));
   
    

%% Detection parameter settings
    % med_len = 70;
    % med_mul = threshold_gain; % threshold
    % channel_start = 30;
    
%detection signal
    coef_interp_real_abs_sum = sum(abs(coef_interp_real(channel_start:end-channel_start, :)));
    threshold = medfilt1(sum(abs(coef_interp_real(channel_start:end-channel_start, :))), med_len)*med_mul;
    threshold(20:end) = threshold(1:end-19);
    coef_interp_real_abs_sum(1:60) = 0;
    
%detection signal and threshold reversion
    coef_interp_real_abs_sum = fliplr(coef_interp_real_abs_sum);
    threshold = fliplr(threshold);

%detection evaluation
    if sum(coef_interp_real_abs_sum > threshold) > 0
        det(counter) = 1;
       else
        det(counter) = 0;
           
    end
    
end
elapsed_time = toc; %time elapsed