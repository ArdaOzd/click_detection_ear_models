% Impulse noise detection using ear model
% Seneff model based detection algorithm - evaluation script
% Authors: Marek Semansky, Frantisek Rund
% FEE CTU in Prague
% https://mmtg.fel.cvut.cz/click-detection/

%S. Seneff, „A joint synchrony/mean-rate model of auditory speech
%processing,“ Journal of Phonetics, pp. 55-76, 1988

%Needs M. Slaney Auditory Toolbox
%https://engineering.purdue.edu/~malcolm/interval/1998-010/ (tested v2)


function [Ap,dprime, results_perc, false_perc, elapsed_time] = run_detect_Seneff(threshold_gain, channels, med_len,sig_list, listen_th)
%clear all%, close all, clc
clear det dprime elapsed_time false_hit false_perc hit num_sig results_perc sada start_sig threshold vysledky%, close all, clc

%% parameters 
start_sig = 1; %first sample (sound file) for analysis (1 - 90)
% sig_list = list of signals to be used
num_sig = length(sig_list);% number of samples (sound files) for analysis (1 - 90)
% threshold_gain = 7.2  %7.2 opt

hit = zeros(1, num_sig);
false_hit = zeros(1, num_sig);  

%Input stimuli files, loading of subjective test results
% details in JAES 2021 article

sada = 'ScratchStimuliTest/'; %path to sound samples
load('subj_results.mat'); %load subjective test results
subjRes = vysledky(sig_list,2)/100;

idxHIT = find(subjRes>=(100-listen_th)/100); %marked as containing clicks > 75 %
idxNO = find(subjRes<=listen_th/100); %marked as containing clicks < 75 %

kstim = sig_list(sort([idxHIT;idxNO])); %"Unsure" samples removed

%evaluation threshold 
        hit(vysledky(kstim, 2)>=(100 - listen_th)) = 1;    %hit
        false_hit(vysledky(kstim, 2)<=listen_th) = 1;  %false hit

% %subjective test results processing
% hit = hit(sig_list); %vector of signals marked by majority of subject as containing clicks
% false_hit = false_hit(sig_list); %vector of singals marked by majority of subjects as not containing clicks

%% calling the detection function
 [det, elapsed_time] = JAES_seneff(sada, start_sig, num_sig, threshold_gain, channels, med_len,kstim);
%[det, elapsed_time] = JAES_seneffp(sada, start_sig, num_sig); %without correlation
%% evaluation 
%clc

disp('Seneff')
[results_perc, false_perc, dprime, Ap] = evaluation(det, hit, false_hit, vysledky);
disp(['Correctly detected: ' num2str(results_perc) '%'])
disp(['False detected: ' num2str(false_perc) '%'])
disp(['d prime: ' num2str(dprime) ])
disp(['A prime: ' num2str(Ap) ])
disp(['Time: ' num2str(elapsed_time) ' sec'])

disp('----------------------------')

%% plot
% idxHIT=find(hit);
% idxNO=find(false_hit);
% figure
% bar(idxHIT,det(idxHIT))
% hold on
% bar(idxNO,abs(det(idxNO)))
% plot(idxHIT,vysledky(idxHIT,2)/100,'-*')
% plot(idxNO,vysledky(idxNO,2)/100,'-*')
% title('Seneff')


