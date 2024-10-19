% Peripheral-ear model based click-detection test
% Authors: Václav Vencovský, Frantisek Rund
% detection method described in
% Rund F., Vencovský V. and Bouse J. Detection of clicks in analog records using peripheral-ear model, Proc. DAFx 2016, pp. 195-199, Brno, Czech Republic, 2016.
%
% FEE CTU 2021, edited 2022
% MATLAB Version: 9.4.0.813654 (R2018a)

function [Ap, dprime, CD, FA, elapsed_time] = runBMmodelTEST_JAES_2(threshold_gain,channel_begin, channel_end,sig_list,listen_th)

%clear all, close all, clc
% addpaths to auditory model scripts
% addpath('fce_audmodel/BM');  % add path to folder with bm model functions
% addpath('fce_audmodel/OME'); % add path to folder with ome model functions
% addpath('fce_audmodel/BM/nobiliAnalyses'); % add path to folder with bm model functions
tic

load fce_audmodel/impulsBM2d0.mat % loads template (BM model response to an artificial click)
impBM = tempBM(9.8e3:1.06e4,:); % select temporally narrow part

% threshold_gain = 41.5;%with 41.5 is performance 85.23/7.67/2.48 - for 45 it is 82.35/5.13/2.56 

listing = dir('ScratchStimuliTest');
NumSig = size(sig_list,1);
det(90)=0;
counter = 0;

load('subj_results.mat');
subjRes = vysledky(sig_list,2)/100;

idxHIT = find(subjRes >= (100-listen_th)/100); %marked as containing clicks > 75 %
idxNO = find(subjRes <= listen_th/100); %marked as containing clicks < 75 %

kstim = sig_list(sort([idxHIT;idxNO]));

for nstim = kstim
    counter = counter+1;
    disp(['stim: ' num2str(nstim)])
    %soundsList{counter} = ['ScratchStimuliTest/' listing(nstim+2).name];
    [y, fs] = audioread(['ScratchStimuliTest/' listing(nstim+2).name]);
    y = y(:, 1); % take only the left channel
    % addjust sample rate to 44.1kHz
    if fs~=44.1e3
        yresamp = resample(y,44.1e3,fs);
        fs = 44.1e3;
    else
        yresamp = y;
    end

    sig_in = yresamp;

    % calibration of the input signals
    Lref = 94; % reference level for +-1 ampl.
    Lset = Lref + 20*log10(sqrt(mean(y.^2))*sqrt(2));
    sig_in = 2e-5*10^(Lset/20)*sig_in;

    %--- ome filter (MAP)
    sigome = 2e6*ome_map1_14(sig_in,fs)';

    %--- BM model (Nobili et al.)
    load cf_nobiliEXP_R3107_10dBOME.mat; % cfnew -- cf vector for the model
    par.nsect = 300;
    par.fmin = 200;
    par.active =  1;
    par.downsmpl = 10;
    par.minSection =  210;
    par.maxSection=  210;
    scaleIN_N = 4;
    [tempBM, auxout] = nobiliAnalysesBuf(fs,scaleIN_N*sigome,par,[]);
%     tempBM(tempBM<0) = 0;
    
    
    [Ns, Nch] = size(tempBM);
    [Nimp] = size(impBM,1);

    steps = floor(Ns/Nimp);
    xxout = [];

    for k=1:steps
    
        for ch=1:Nch
            
            if ch >= channel_begin & ch <= channel_end
                xcoutj(:,ch) = xcorr(impBM(:,ch),tempBM(1+(k-1)*Nimp:k*Nimp,ch),'coeff');    
            end
        end
    
        xxout = [xxout; xcoutj];
    
    end

    if max(abs(sum(xxout(:,channel_begin:channel_end)')))> threshold_gain
        det(counter) = 1;
    else
        det(counter) = 0;
    end
    
end
elapsed_time = toc;





%evaluation
ErrorRate = 100-(sum(det(idxHIT))/length(idxHIT))*100; 
CD=100-ErrorRate; %Hit
FA = sum(abs(det(idxNO)))/length(idxNO)*100; % False Alarm
total = ErrorRate + FA;
dprime=(norminv(CD/100)-norminv(FA/100));
% Ap
cd = CD/100;
fd = FA/100;
Ap = 0.5 + sign(cd-fd)*((cd-fd)^2 + abs(cd-fd))/(4*max(cd,fd)-4*cd*fd);

disp(['Not detected: ' num2str(ErrorRate) '%'])
disp(['Correcty detected: ' num2str(CD) '%'])
disp(['False detected: ' num2str(FA) '%'])
disp(['d prime: ' num2str(dprime) ])
disp(['A prime: ' num2str(Ap) ])
disp(['Time: ' num2str(elapsed_time) ' sec'])
disp('----------------------------')


% figure
% bar(idxHIT,det(idxHIT))
% hold on
% bar(idxNO,abs(det(idxNO)))
% plot(idxHIT,subjRes(idxHIT),'-*')
% plot(idxNO,subjRes(idxNO),'-*')
% title('perihperal-ear')
% 
% 
% 
% for k=1:length(idxNO)
%     if det(idxNO(k))>0
%         subjRes(idxNO(k))
%         soundsList{idxNO(k)}
%     end
% end
% 
% 
% 
% for k=1:length(idxHIT)
%     if det(idxHIT(k))==0
%         subjRes(idxHIT(k))
%         soundsList{idxHIT(k)}
%     end
% end

% rmpath('fce_audmodel/BM');  % rm path to folder with bm model functions
% rmpath('fce_audmodel/OME'); % rm path to folder with ome model functions
% rmpath('fce_audmodel/BM/nobiliAnalyses'); % rm path to folder with bm model functions
