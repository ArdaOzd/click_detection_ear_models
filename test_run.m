
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


r =[1:5]
lth = [1,5,10,25,50]
BM_flags = [0,1]

al = cell(5,5,2);

test_results = struct();

addpath(genpath('par_run_codes'));


%% INITIAL DATA
number_trials = 5;
% linear threshold division no 
% (selected ranges are in Initialization section below)
n = 50;

% Algorithm specific detection parameters
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
% Initialization
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
% create a matrix of parameters 
% Gather all lists into a cell array
param_lists = {channels_drnl_first_band, med_len_erblet, channel_start, channels_lyon_end, ...
         channels_seneff_end, med_len_seneff, LengthSeg_ar, Order_ar, ...
         LengthSeg_matched, Order_matched, LengthFilt,channel_begin_BM,channel_end_BM};

param_len = length(param_lists);
% Find the length of the longest list
max_len = max(cellfun(@length, param_lists));






%% TEST RUN


% test set results
% second dimension ==> 1 = Ap optimized, 2 = dp optimized 
Ap_test = -1*ones(8,number_trials, 5,2); % Aprime results matrix)
dprime_test = -1*ones(8,number_trials, 5,2); % dprime results matrix)
cd_test = -1*ones(8,number_trials, 5,2); % Correct detection ratio matrix)
fd_test = -1*ones(8,number_trials, 5,2); % False detection results matrix)

% max_vals and indexes for train
max_train = zeros(8,number_trials, 5,2);
maxidx_train = zeros(8,number_trials, 5,2);

% best values of parameters
best_th = zeros(8,number_trials, 5,2);
best_p1 = zeros(8,number_trials, 5,2); % param1 
best_p2 = zeros(8,number_trials, 5,2); % param2

algo_names = {"DRNL", "ERBlet", "Lyon's", "Seneff's", "AR", "Matched", "Wavelet", "Vencovsky's"};

figure;
c = 0;
% Ap, dp test results
for listen_th = lth
    c = c+1;
    for i = r
        for j = BM_flags+1
            filename = ['par_results/output' num2str(i) '_lth' num2str(listen_th) '_BM' num2str(j-1) '.mat']
            al{i,c,j} = load(filename);
        end
    end
end

c=0
for listen_th = lth
    c = c+1;
    for i = r

if i == 1
    train_list = [42, 51, 55, 5, 28, 75, 47, 89, 33, 58, 57, 31, 70, 85, 16, 53, 49, 17, 44, 39, 11, 45, 15, 8, 90, 37, 30, 25, 60, 34, 52, 7, 3, 35, 10, 6, 41, 86, 20, 9, 76, 82, 59, 80, 1, 63, 14, 19, 56, 62, 40, 12, 2, 29, 88, 48, 66, 64, 77, 71];
elseif i == 2
    train_list = [21, 23, 62, 53, 51, 49, 61, 7, 82, 54, 29, 10, 63, 68, 78, 18, 56, 4, 26, 24, 47, 41, 20, 8, 2, 74, 71, 3, 28, 89, 60, 16, 9, 72, 67, 42, 44, 12, 27, 35, 5, 76, 52, 33, 14, 39, 58, 37, 69, 48, 80, 46, 55, 6, 25, 88, 73, 66, 13, 79];
elseif i == 3
    train_list = [65, 7, 55, 87, 75, 51, 49, 63, 4, 14, 42, 30, 2, 56, 19, 46, 70, 90, 64, 32, 40, 58, 21, 35, 12, 76, 28, 3, 20, 33, 67, 44, 5, 57, 22, 38, 48, 86, 47, 54, 31, 60, 9, 16, 17, 1, 78, 41, 73, 10, 39, 80, 50, 66, 36, 24, 72, 13, 45, 68];
elseif i == 4
    train_list = [90, 9, 87, 83, 79, 2, 46, 35, 4, 5, 72, 29, 50, 84, 6, 70, 56, 16, 55, 33, 27, 48, 63, 13, 53, 11, 28, 24, 18, 85, 17, 65, 41, 26, 8, 23, 1, 36, 78, 86, 77, 80, 22, 12, 68, 19, 81, 76, 73, 34, 71, 3, 14, 31, 66, 20, 38, 47, 52, 62];
else
    train_list = [87, 67, 72, 61, 39, 29, 64, 49, 9, 77, 14, 37, 32, 48, 22, 34, 36, 21, 85, 50, 73, 17, 12, 58, 53, 86, 84, 31, 60, 6, 45, 19, 59, 68, 18, 35, 63, 78, 89, 13, 3, 16, 30, 52, 7, 8, 66, 76, 11, 69, 88, 82, 57, 20, 56, 70, 38, 71, 55, 51];
end
    
test_list = setdiff([1:90], train_list);


    Ap = al{i,c,1}.Ap;
    dp = al{i,c,1}.dp;

        
            % % find the best Ap and dp thresholds
            % max_...(:,1) = Ap
            [max_train(1,i,c,1), maxidx_train(1,i,c,1)] = max(Ap.Ap1,[],'all','linear');
            [max_train(2,i,c,1), maxidx_train(2,i,c,1)] = max(Ap.Ap2,[],'all','linear');
            [max_train(3,i,c,1), maxidx_train(3,i,c,1)] = max(Ap.Ap3,[],'all','linear');
            [max_train(4,i,c,1), maxidx_train(4,i,c,1)] = max(Ap.Ap4,[],'all','linear');
            [max_train(5,i,c,1), maxidx_train(5,i,c,1)] = max(Ap.Ap5,[],'all','linear');
            [max_train(6,i,c,1), maxidx_train(6,i,c,1)] = max(Ap.Ap6,[],'all','linear');
            [max_train(7,i,c,1), maxidx_train(7,i,c,1)] = max(Ap.Ap7,[],'all','linear');
    
            [best_th(1,i,c,1),best_p1(1,i,c,1),best_p2(1,i,c,1)] = ind2sub([n, max_len, max_len], maxidx_train(1,i,c,1));
            [best_th(2,i,c,1),best_p1(2,i,c,1),best_p2(2,i,c,1)] = ind2sub([n, max_len, max_len], maxidx_train(2,i,c,1));
            [best_th(3,i,c,1),best_p1(3,i,c,1),best_p2(3,i,c,1)] = ind2sub([n, max_len, max_len], maxidx_train(3,i,c,1));
            [best_th(4,i,c,1),best_p1(4,i,c,1),best_p2(4,i,c,1)] = ind2sub([n, max_len, max_len], maxidx_train(4,i,c,1));
            [best_th(5,i,c,1),best_p1(5,i,c,1),best_p2(5,i,c,1)] = ind2sub([n, max_len, max_len], maxidx_train(5,i,c,1));
            [best_th(6,i,c,1),best_p1(6,i,c,1),best_p2(6,i,c,1)] = ind2sub([n, max_len, max_len], maxidx_train(6,i,c,1));
            [best_th(7,i,c,1),best_p1(7,i,c,1),best_p2(7,i,c,1)] = ind2sub([n, max_len, max_len], maxidx_train(7,i,c,1));
    
            % 
            % max_...(:,2) = dp
            [max_train(1,i,c,2), maxidx_train(1,i,c,2)] = max(dp.dp1,[],'all','linear');
            [max_train(2,i,c,2), maxidx_train(2,i,c,2)] = max(dp.dp2,[],'all','linear');
            [max_train(3,i,c,2), maxidx_train(3,i,c,2)] = max(dp.dp3,[],'all','linear');
            [max_train(4,i,c,2), maxidx_train(4,i,c,2)] = max(dp.dp4,[],'all','linear');
            [max_train(5,i,c,2), maxidx_train(5,i,c,2)] = max(dp.dp5,[],'all','linear');
            [max_train(6,i,c,2), maxidx_train(6,i,c,2)] = max(dp.dp6,[],'all','linear');
            [max_train(7,i,c,2), maxidx_train(7,i,c,2)] = max(dp.dp7,[],'all','linear');
    
            [best_th(1,i,c,2),best_p1(1,i,c,2),best_p2(1,i,c,2)] = ind2sub([n, max_len, max_len], maxidx_train(1,i,c,2));
            [best_th(2,i,c,2),best_p1(2,i,c,2),best_p2(2,i,c,2)] = ind2sub([n, max_len, max_len], maxidx_train(2,i,c,2));
            [best_th(3,i,c,2),best_p1(3,i,c,2),best_p2(3,i,c,2)] = ind2sub([n, max_len, max_len], maxidx_train(3,i,c,2));
            [best_th(4,i,c,2),best_p1(4,i,c,2),best_p2(4,i,c,2)] = ind2sub([n, max_len, max_len], maxidx_train(4,i,c,2));
            [best_th(5,i,c,2),best_p1(5,i,c,2),best_p2(5,i,c,2)] = ind2sub([n, max_len, max_len], maxidx_train(5,i,c,2));
            [best_th(6,i,c,2),best_p1(6,i,c,2),best_p2(6,i,c,2)] = ind2sub([n, max_len, max_len], maxidx_train(6,i,c,2));
            [best_th(7,i,c,2),best_p1(7,i,c,2),best_p2(7,i,c,2)] = ind2sub([n, max_len, max_len], maxidx_train(7,i,c,2));
    
    
            % % Ap best threshold test set results
            [Ap_test(1,i,c,1),dprime_test(1,i,c,1),cd_test(1,i,c,1),fd_test(1,i,c,1)] = run_detect_DRNL(th_drnl(best_th(1,i,c,1)),channels_drnl_first_band(best_p1(1,i,c,1)), test_list, listen_th);
            [Ap_test(2,i,c,1),dprime_test(2,i,c,1),cd_test(2,i,c,1),fd_test(2,i,c,1)] = run_detect_erblet(th_erb(best_th(2,i,c,1)), med_len_erblet(best_p1(2,i,c,1)), channel_start(best_p2(2,i,c,1)),test_list,listen_th);
            [Ap_test(3,i,c,1),dprime_test(3,i,c,1),cd_test(3,i,c,1),fd_test(3,i,c,1)] = run_detect_Lyon(th_lyon(best_th(3,i,c,1)),channels_lyon_end(best_p1(3,i,c,1)),test_list,listen_th);
            [Ap_test(4,i,c,1),dprime_test(4,i,c,1),cd_test(4,i,c,1),fd_test(4,i,c,1)] = run_detect_Seneff(th_senef(best_th(4,i,c,1)), channels_seneff_end(best_p1(4,i,c,1)), med_len_seneff(best_p2(4,i,c,1)), test_list,listen_th);
            [Ap_test(5,i,c,1),dprime_test(5,i,c,1),cd_test(5,i,c,1),fd_test(5,i,c,1)] = runAnalysisAR_JAES_f(th_ar(best_th(5,i,c,1)), LengthSeg_ar(best_p1(5,i,c,1)), Order_ar(best_p2(5,i,c,1)), test_list,listen_th);
            [Ap_test(6,i,c,1),dprime_test(6,i,c,1),cd_test(6,i,c,1),fd_test(6,i,c,1)] = runAnalysismatch_JAES_f(th_matched(best_th(6,i,c,1)), LengthSeg_matched(best_p1(6,i,c,1)), Order_matched(best_p2(6,i,c,1)), test_list,listen_th);
            [Ap_test(7,i,c,1),dprime_test(7,i,c,1),cd_test(7,i,c,1),fd_test(7,i,c,1)] = runAnalysisWavelet_JAES_f(th_wave(best_th(7,i,c,1)), LengthFilt(best_p1(7,i,c,1)), test_list,listen_th);
    
            % [Ap_test(1,i,c,2),dprime_test(1,i,c,2),cd_test(1,i,c,2),fd_test(1,i,c,2)] = run_detect_DRNL(th_drnl(best_th(1,i,c,2)),channels_drnl_first_band(best_p1(1,i,c,2)), test_list, listen_th);
            % [Ap_test(2,i,c,2),dprime_test(2,i,c,2),cd_test(2,i,c,2),fd_test(2,i,c,2)] = run_detect_erblet(th_erb(best_th(2,i,c,2)), med_len_erblet(best_p1(2,i,c,2)), channel_start(best_p2(2,i,c,2)),test_list,listen_th);
            % [Ap_test(3,i,c,2),dprime_test(3,i,c,2),cd_test(3,i,c,2),fd_test(3,i,c,2)] = run_detect_Lyon(th_lyon(best_th(3,i,c,2)),channels_lyon_end(best_p1(3,i,c,2)),test_list,listen_th);
            % [Ap_test(4,i,c,2),dprime_test(4,i,c,2),cd_test(4,i,c,2),fd_test(4,i,c,2)] = run_detect_Seneff(th_senef(best_th(4,i,c,2)), channels_seneff_end(best_p1(4,i,c,2)), med_len_seneff(best_p2(4,i,c,2)), test_list,listen_th);
            % [Ap_test(5,i,c,2),dprime_test(5,i,c,2),cd_test(5,i,c,2),fd_test(5,i,c,2)] = runAnalysisAR_JAES_f(th_ar(best_th(5,i,c,2)), LengthSeg_ar(best_p1(5,i,c,2)), Order_ar(best_p2(5,i,c,2)), test_list,listen_th);
            % [Ap_test(6,i,c,2),dprime_test(6,i,c,2),cd_test(6,i,c,2),fd_test(6,i,c,2)] = runAnalysismatch_JAES_f(th_matched(best_th(6,i,c,2)), LengthSeg_matched(best_p1(6,i,c,2)), Order_matched(best_p2(6,i,c,2)), test_list,listen_th);
            % [Ap_test(7,i,c,2),dprime_test(7,i,c,2),cd_test(7,i,c,2),fd_test(7,i,c,2)] = runAnalysisWavelet_JAES_f(th_wave(best_th(7,i,c,2)), LengthFilt(best_p1(7,i,c,2)), test_list,listen_th);
            

    Ap = al{i,c,2}.Ap;
    dp = al{i,c,2}.dp;
    

            % Ap max BM
            [max_train(8,i,c,1), maxidx_train(8,i,c,1)] = max(Ap.Ap8,[],'all','linear');
            [best_th(8,i,c,1),best_p1(8,i,c,1),best_p2(8,i,c,1)] = ind2sub([n, max_len, max_len], maxidx_train(8,i,c,1));
            [Ap_test(8,i,c,1),dprime_test(8,i,c,1),cd_test(8,i,c,1),fd_test(8,i,c,1)] = runBMmodelTEST_JAES_2(th_vencovs(best_th(8,i,c,1)),channel_begin_BM(best_p1(8,i,c,1)),channel_end_BM(best_p2(8,i,c,1)),test_list,listen_th);
    
    
            % % dp max BM
            % [max_train(8,i,c,2), maxidx_train(8,i,c,2)] = max(dp.dp8,[],'all','linear');
            % [best_th(8,i,c,2),best_p1(8,i,c,2),best_p2(8,i,c,2)] = ind2sub([n, max_len, max_len], maxidx_train(8,i,c,2));
            % [Ap_test(8,i,c,2),dprime_test(8,i,c,2),cd_test(8,i,c,2),fd_test(8,i,c,2)] = runBMmodelTEST_JAES_2(th_vencovs(best_th(8,i,c,2)),channel_begin_BM(best_p1(8,i,c,2)),channel_end_BM(best_p2(8,i,c,2)),test_list,listen_th);     
            

    end


    % test_results.ap_test = Ap_test;
    % test_results.dp_test = dprime_test;
    % test_results.cd_test = cd_test;
    % test_results.fd_test = fd_test;
    % test_results.best_th = best_th;
    % test_results.best_p1 = best_p1;
    % test_results.best_p2 = best_p2;

end

%%  RESULTS ANALYSIS

% if test_run.mat is available you can directly load it and run from here.
% to obtain Ap error plot



algo_names = {"DRNL", "ERBlet", "Lyon's", "Seneff's", "AR", "Matched", "Wavelet", "Vencovsky's"};

figure;

% Ap variance based on randomizations and levels
x = 1:8; % x-axis values
indices = Ap_test > 1;
Ap_test(indices) = NaN;
colors = {'red','green','blue',[0.8500 0.3250 0.0980],[0.4940 0.1840 0.5560]}
for c = 1:5
var1 = Ap_test(5,:,c,1); % 
var2 = Ap_test(6,:,c,1);
var3 = Ap_test(8,:,c,1);
var4 = Ap_test(3,:,c,1);
var5 = Ap_test(7,:,c,1);
var6 = Ap_test(1,:,c,1);
var7 = Ap_test(4,:,c,1);
var8 = Ap_test(2,:,c,1);
data = [var1; var2; var3; var4; var5; var6; var7; var8];
means = mean(data,2,'omitnan');
stdDevs = std(data, 0, 2,'omitnan');

z(c,:) = stdDevs; 

hold on;
shiftAmount = 0.1;
errorX = x - 0.2 + shiftAmount * (c - 1);
color = rand(1, 3); % random RGB color
marker = {'o', 's', '^', 'd', 'h'}; % 
errorbar(errorX, means, stdDevs, marker{c}, 'Color', colors{c}, 'LineWidth', 5, 'CapSize', 10,'MarkerSize',16);

xlabel('Algorithms');
ylabel("A'");
title("A' error plot based on experiment levels");
xticks(x);
xticklabels(algo_names([5, 6, 8, 3, 7, 1, 4, 2]));
grid on;

end
% Your plotting code here
legend('x = 1', 'x = 5', 'x = 10', 'x = 25', 'x = 50')
% Save the figure as EPS
filename = 'Ap_var.eps';
print(gcf, filename, '-depsc', '-r300'); % Use '-r' to specify the resolution (dots per inch), adjust as needed

mean_ap = [];
mean_cd = [];
mean_fd = [];
sigma_ap =[];


for i = 1:8
    matrix = Ap_test(i,:,:,1);

    % Find indices of non-NaN values
    indx = find(~isnan(matrix));

     mean_ap= [mean_ap, mean(matrix(indx),'all','omitnan')];
     matrix = cd_test(i,:,:,1)
     mean_cd= [mean_cd, mean(matrix(indx),'all','omitnan')];
     matrix = fd_test(i,:,:,1)
     mean_fd= [mean_fd, mean(matrix(indx),'all','omitnan')];
     matrix = Ap_test(i,:,:,1)
     sigma_ap = [sigma_ap, std(matrix(indx), 0, 'all','omitnan')];
   
end

% Create a table
data = table(algo_names',sigma_ap', mean_ap', mean_cd', mean_fd', 'VariableNames', {'Algorithm','sigma_ap','Mean_Ap', 'Mean_cd', 'Mean_fd'});

% Sort the table by increasing mean Ap_test scores
[sorted_data, idx]= sortrows(data, 'Mean_Ap');

disp(idx)
% Display the table
disp(sorted_data);


















