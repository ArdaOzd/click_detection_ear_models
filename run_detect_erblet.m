% Impulse noise detection using ear model
% ERBlet based detection algorithm - evaluation script
% Authors: Marek Semansky, Frantisek Rund
% FEE CTU in Prague
% https://mmtg.fel.cvut.cz/click-detection/

% ERBlet:
% http://www.kfs.oeaw.ac.at/ICASSP2013_ERBlets
% T. Necciari, P. Balasz, N. Holighaus a P. Sondergaard, „The Erblet
% Transform: An Auditory-Based Time-Frequency Representation with Perfect
% Reconstruction,“ v 2013 IEEE International Conference on Acoustics, Speech and Signal Processing, Vancouver, 2013.


% Erblet needs AMT (http://amtoolbox.sourceforge.net/) (or LTFAT) - install AMT and then run amtstart




function [Ap, dprime, results_perc, false_perc, elapsed_time] = run_detect_erblet(threshold_gain, med_len, channel_start, sig_list, listen_th)
clear det dprime elapsed_time false_hit false_perc hit num_sig results_perc sada start_sig threshold vysledky%, close all, clc

%% parameters 
start_sig = 1; %first sample (sound file) for analysis (1 - 90)
% sig_list = list of signals to be used
num_sig = length(sig_list);% number of samples (sound files) for analysis (1 - 90)

hit = zeros(1, num_sig);
false_hit = zeros(1, num_sig);  

%Input stimuli files, loading of subjective test results
% details in JAES 2021 article

sada = 'ScratchStimuliTest/'; %path to sound samples
load('subj_results.mat'); %load subjective test results
subjRes = vysledky(sig_list,2)/100;

idxHIT = find(subjRes>=(100-listen_th)/100); %marked as containing clicks > 75 %
idxNO = find(subjRes<=listen_th/100); %marked as not containing clicks < 75 %

kstim = sig_list(sort([idxHIT;idxNO])); %"Unsure" samples removed

%evaluation threshold 
        hit(vysledky(kstim, 2)>=(100 - listen_th)) = 1;    %hit
        false_hit(vysledky(kstim, 2)<=listen_th) = 1;  %false hit

% %subjective test results processing
% hit = hit(sig_list); %vector of signals marked by majority of subject as containing clicks
% false_hit = false_hit(sig_list); %vector of singals marked by majority of subjects as not containing clicks

%% calling the detection function
 [det, elapsed_time] = JAES_erblet(sada, start_sig, num_sig, threshold_gain, med_len, channel_start, kstim);

 %% evaluation 

disp('erblet')
[results_perc, false_perc, dprime, Ap] = evaluation(det, hit, false_hit, vysledky);
disp(['Correctly detected: ' num2str(results_perc) '%'])
disp(['False detected: ' num2str(false_perc) '%'])
disp(['d prime: ' num2str(dprime) ])
disp(['A prime: ' num2str(Ap) ])
disp(['Time: ' num2str(elapsed_time) ' s'])

disp(['----------------------------'])

%% plot
% idxHIT=find(hit);
% idxNO=find(false_hit);
% figure
% bar(idxHIT,det(idxHIT))
% hold on
% bar(idxNO,abs(det(idxNO)))
% plot(idxHIT,vysledky(idxHIT,2)/100,'-*')
% plot(idxNO,vysledky(idxNO,2)/100,'-*')
% title('Erblet')
