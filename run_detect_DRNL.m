% Impulse noise detection using ear model
% DRNL model based detection algorithm - evaluation script
% Authors: Marek Semansky, Frantisek Rund
% FEE CTU in Prague
% https://mmtg.fel.cvut.cz/click-detection/

%DRNL needs MAP Toolbox, function DRNL_MAP _14 (so, before run copy this
%function into the folder)
% MAP Toolbox: https://github.com/rmeddis/MAP


function [Ap,dprime, results_perc, false_perc, elapsed_time] = run_detect_DRNL(threshold_gain, channels, sig_list,listen_th)
%clear all%, close all, clc
clear det dprime elapsed_time false_hit false_perc hit num_sig results_perc sada start_sig threshold vysledky
%% parameters 
start_sig = 1; %first sample (sound file) for analysis (1 - 90)
% sig_list = selected audio recordings
num_sig = length(sig_list);% number of samples (sound files) for analysis (1 - 90)
% threshold = 75; % threshold for subjective test (50,   75)  
% threshold_gain = 22; % thr_const = 22;  %threshold constant 22 opt


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
%subjective test results processing
% % save('hit.mat',hit)
% disp(hit)
% 
% hit = hit(sig_list); %click perceived
% disp(hit)
% false_hit = false_hit(sig_list); %click not perceived



%% calling the detection function
 [det, elapsed_time] = JAES_DRNL(sada, start_sig, num_sig,threshold_gain, channels, kstim);    
 %[det, elapsed_time] = JAES_DRNLp(sada, start_sig, num_sig);    %without
 %correlation

%% evaluation 
%clc
disp('DRNL')
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
% title('DRNL')

