% matched filter based click-detection test
% Authors: Václav Vencovský, Marek Semanský, Frantisek Rund
% FEE CTU 2021
% MATLAB Version: 9.4.0.813654 (R2018a)

%clear, close all, %clc
function [Ap,dprime, CD, FA, elapsed_time] = runAnalysismatch_JAES_f(threshold_gain, LengthSeg, Order, sig_list, listen_th)

% addpath('fce_matched');  % add path to folder with matched filter click detection functions

%sig_list = list of signals to be used
% sig_list = randperm(90, 60);
% threshold_gain = 35;
% listen_th = 1;
% LengthSeg = 5;
% Order = 5;
%subjective test results loading
load('subj_results.mat');
subjRes = vysledky(sig_list,2)/100;


idxHIT = find(subjRes>=(100-listen_th)/100); %marked as containing clicks > 75 %
idxNO = find(subjRes<=listen_th/100); %marked as containing clicks < 75 %

%Folder with the samples
FolderName = 'ScratchStimuliTest/';
listWav = dir(FolderName);

%% detection parameters
% LengthSeg = 6144; %Frame length N !
Threshold = threshold_gain % 35; %Detection threshold gain K !
% Order = 30; %Prediction order P

idxLup = 17640; % Starting position for the detection - half of the signal (sample) length
idxTol = idxLup-1; % Range for click detection - half of the signal (sample) length - a click is searched in full length of the sample

kstim = sig_list(sort([idxHIT;idxNO])); %"Unsure" samples removed

disp(['Frame length N: ' num2str(LengthSeg) ', Detection threshold parameter K: ' num2str(Threshold) ', Prediction order p: ' num2str(Order)]) %zobrazeni parametru detekce

clickAR = zeros(1,length(listWav)-2); %preallocation of detection vector

%%
tic
%-------------------------------------------------------------------------------------------------
for k=1:length(kstim) %%detection for cycle
    %-------------------------------------------------------------------------------------------------
    disp(['stim: ' num2str(kstim(k))])
    [y, fs] = audioread([FolderName listWav(kstim(k)+2).name]); %sample loading

    y = y(:,1); %only left channel used for the subjective test 
    
    if ismember(k,idxHIT) %matched filter
          % disp('here')
          clickAR(kstim(k)) = match_filter_mm(y, Order, Threshold, LengthSeg,idxLup,idxTol,1);%click perceived
    else
        % disp('there')
          clickAR(kstim(k)) = match_filter_mm(y, Order, Threshold, LengthSeg,idxLup,idxTol,0);%click not perceived
    end    
end
elapsed_time = toc; %time elapsed
%evaluation
ErrorRate = 100-(sum(clickAR(sig_list(idxHIT)))/length(idxHIT))*100; 
CD=100-ErrorRate; %Hit
FA = sum(abs(clickAR(sig_list(idxNO))))/length(idxNO)*100; % False Alarm
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
disp(['----------------------------'])


% figure
% bar(idxHIT,clickAR(idxHIT))
% hold on
% bar(idxNO,abs(clickAR(idxNO)))
% plot(idxHIT,subjRes(idxHIT),'-*')
% plot(idxNO,subjRes(idxNO),'-*')
% title('matched')

% rmpath('fce_matched');