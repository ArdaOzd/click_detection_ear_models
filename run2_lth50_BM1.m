% Run this file for complete evaluation of all the models.
% Some of the models take long time to run, so adjust.
clear all;
close all;

% profile -memory on


%%% Set the main folder path %%%
folder_path = 'ScratchStimuliTest';
addpath(genpath(folder_path))
folder_path = 'MAP';
addpath(genpath(folder_path))
folder_path = 'IR';
addpath(genpath(folder_path))
folder_path = 'fce_wavelet';
addpath(genpath(folder_path))
folder_path = 'fce_matched';
addpath(genpath(folder_path))
folder_path = 'fce_audmodel';
addpath(genpath(folder_path))
folder_path = 'fce_AR';
addpath(genpath(folder_path))
folder_path = 'Erblets';
addpath(genpath(folder_path))
folder_path = 'Aud_tbx';
addpath(genpath(folder_path))
folder_path = 'amtoolbox-full-1.2.0';
addpath(genpath(folder_path))

% start amtoolbox-full-1.2.0l
amt_start;

cd Aud_tbx/
Makefile;
cd ..


%% BM or others
BM_flag = 1;
%% Uncertanity threshold of listening tests for sample selection
listen_th = 50;
random_flag = 2;

%% Randomization settings

% general settings, number of trials and training list size
sig_num = 60; % train list size
number_trials = 5; % number of randomization
train_lists_all = zeros(number_trials, sig_num); % empty list for random samples

%% Threshold settings

% linear threshold division no 
% (selected ranges are in Initialization section below)
n = 50;

%% Algorithm specific detection parameters

% DRNL
channels_drnl_first_band  = 7:18 ; % DRNL correlation channels 

% Erblet
med_len_erblet = 30:5:180; %median filter length
channel_start = 20:40 ;

% Lyon
channels_lyon_end = 25:55;

% Seneff 
channels_seneff_end = 8:24; %channels (bands) selection
med_len_seneff = 50:20:500; %median filter length

% AR
LengthSeg_ar = 256:256:8192; % be careful about the stationarity of the signal  
Order_ar = 8:2:40; 

% matched
LengthSeg_matched = 256:256:8192; % be careful about the stationarity of the signal  
Order_matched = 8:2:40; 

% Wavelet 
LengthFilt = 30:5:180; %Median filter window length L !

% BM
channel_begin_BM = round(logspace(log10(5),log10(100),8)); % cross correlation channels
channel_end_BM = round(logspace(log10(40),log10(150),8)); 
%% Initialization

% Hard-set threshold ranges based-on previous experiments
%new models
th_drnl = linspace(10, 32, n);
th_erb = linspace(3, 10, n);
th_lyon = linspace(8, 22, n);
th_senef = linspace(2, 20, n);

%old models
th_ar = linspace(4, 32, n);
th_matched = linspace(5, 50, n);
th_wave = linspace(5, 50, n);
th_vencovs = linspace(25, 65, n);

% Create a struct to store the threshold values
thresholds.th_drnl = th_drnl;
thresholds.th_erb = th_erb;
thresholds.th_lyon = th_lyon;
thresholds.th_senef = th_senef;
thresholds.th_ar = th_ar;
thresholds.th_matched = th_matched;
thresholds.th_wave = th_wave;
thresholds.th_vencovs = th_vencovs;

%% create a matrix of parameters 
% Gather all lists into a cell array
param_lists = {channels_drnl_first_band, med_len_erblet, channel_start, channels_lyon_end, ...
        channels_seneff_end, med_len_seneff, LengthSeg_ar, Order_ar, ...
         LengthSeg_matched, Order_matched, LengthFilt,channel_begin_BM,channel_end_BM};

param_len = length(param_lists);
% Find the length of the longest list
max_len = max(cellfun(@length, param_lists));

%% RESULT VARIABLES 
% Matrices contain
% (algorithms,randomization,threshold,#param_for_each_algo,param_division)
% training set results
% Ap_train = -1*ones(8,number_trials,n,max_len,max_len); % Aprime results matrix)
% dprime_train = -1*ones(8,number_trials,n,max_len,max_len); % dprime results matrix)
% cd_train = -1*ones(8,number_trials,n,max_len,max_len); % Correct detection ratio matrix)
% fd_train = -1*ones(8,number_trials,n,max_len,max_len); % False detection results matrix)
% elapsed_time = zeros(8,number_trials,n,max_len,max_len); % elapsed time matrix)

% test set results
% second dimension ==> 1 = Ap optimized, 2 = dp optimized 
Ap_test = -1*ones(8,number_trials,2); % Aprime results matrix)
dprime_test = -1*ones(8,number_trials,2); % dprime results matrix)
cd_test = -1*ones(8,number_trials,2); % Correct detection ratio matrix)
fd_test = -1*ones(8,number_trials,2); % False detection results matrix)

% max_vals and indexes for train
max_train = zeros(8,number_trials,2);
maxidx_train = zeros(8,number_trials,2);

% best values of parameters
best_th = zeros(8,number_trials,2);
best_p1 = zeros(8,number_trials,2); % param1 
best_p2 = zeros(8,number_trials,2); % param2

% save
all_ap = cell(1,number_trials);
all_dp = cell(1,number_trials);
all_cod = cell(1,number_trials);
all_fd = cell(1,number_trials);
all_et = cell(1,number_trials);

%% Experiment loops

% parpool(n);

t1 = cputime;

MetaParPool('open');



tic;
if random_flag == 1
    train_list = [42, 51, 55, 5, 28, 75, 47, 89, 33, 58, 57, 31, 70, 85, 16, 53, 49, 17, 44, 39, 11, 45, 15, 8, 90, 37, 30, 25, 60, 34, 52, 7, 3, 35, 10, 6, 41, 86, 20, 9, 76, 82, 59, 80, 1, 63, 14, 19, 56, 62, 40, 12, 2, 29, 88, 48, 66, 64, 77, 71];
elseif random_flag == 2
    train_list = [21, 23, 62, 53, 51, 49, 61, 7, 82, 54, 29, 10, 63, 68, 78, 18, 56, 4, 26, 24, 47, 41, 20, 8, 2, 74, 71, 3, 28, 89, 60, 16, 9, 72, 67, 42, 44, 12, 27, 35, 5, 76, 52, 33, 14, 39, 58, 37, 69, 48, 80, 46, 55, 6, 25, 88, 73, 66, 13, 79];
elseif random_flag == 3
    train_list = [65, 7, 55, 87, 75, 51, 49, 63, 4, 14, 42, 30, 2, 56, 19, 46, 70, 90, 64, 32, 40, 58, 21, 35, 12, 76, 28, 3, 20, 33, 67, 44, 5, 57, 22, 38, 48, 86, 47, 54, 31, 60, 9, 16, 17, 1, 78, 41, 73, 10, 39, 80, 50, 66, 36, 24, 72, 13, 45, 68];
elseif random_flag == 4
    train_list = [90, 9, 87, 83, 79, 2, 46, 35, 4, 5, 72, 29, 50, 84, 6, 70, 56, 16, 55, 33, 27, 48, 63, 13, 53, 11, 28, 24, 18, 85, 17, 65, 41, 26, 8, 23, 1, 36, 78, 86, 77, 80, 22, 12, 68, 19, 81, 76, 73, 34, 71, 3, 14, 31, 66, 20, 38, 47, 52, 62];
else
    train_list = [87, 67, 72, 61, 39, 29, 64, 49, 9, 77, 14, 37, 32, 48, 22, 34, 36, 21, 85, 50, 73, 17, 12, 58, 53, 86, 84, 31, 60, 6, 45, 19, 59, 68, 18, 35, 63, 78, 89, 13, 3, 16, 30, 52, 7, 8, 66, 76, 11, 69, 88, 82, 57, 20, 56, 70, 38, 71, 55, 51];
end
    
    if BM_flag == 0 
    % paralel 
        if listen_th == 1 
            [Ap,dp,cod,fd,et] = m1(n,max_len,param_lists,train_list,listen_th,thresholds);
        elseif listen_th == 5
            [Ap,dp,cod,fd,et] = m5(n,max_len,param_lists,train_list,listen_th,thresholds);
        elseif listen_th == 10
            [Ap,dp,cod,fd,et] = m10(n,max_len,param_lists,train_list,listen_th,thresholds);
        elseif listen_th == 25
            [Ap,dp,cod,fd,et] = m25(n,max_len,param_lists,train_list,listen_th,thresholds);
        elseif listen_th == 50
            [Ap,dp,cod,fd,et] = m50(n,max_len,param_lists,train_list,listen_th,thresholds);
        end
    else
        if listen_th == 1 
            [Ap,dp,cod,fd,et] = m1_BM(n,max_len,param_lists,train_list,listen_th,thresholds);
        elseif listen_th == 5
            [Ap,dp,cod,fd,et] = m5_BM(n,max_len,param_lists,train_list,listen_th,thresholds);
        elseif listen_th == 10
            [Ap,dp,cod,fd,et] = m10_BM(n,max_len,param_lists,train_list,listen_th,thresholds);
        elseif listen_th == 25
            [Ap,dp,cod,fd,et] = m25_BM(n,max_len,param_lists,train_list,listen_th,thresholds);
        elseif listen_th == 50
            [Ap,dp,cod,fd,et] = m50_BM(n,max_len,param_lists,train_list,listen_th,thresholds);
        end
    end
    
    t2 = cputime;
    t2-t1

ALLTIME = toc;
disp(ALLTIME)

MetaParPool('close');

save

