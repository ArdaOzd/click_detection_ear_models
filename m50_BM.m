function  [Ap,dp,cd,fd,et] = m50_BM(n,max_len,param_lists,train_list,listen_th,thresholds)

[channels_drnl_first_band, med_len_erblet, channel_start, channels_lyon_end, ...
 channels_seneff_end, med_len_seneff, LengthSeg_ar, Order_ar, ...
 LengthSeg_matched, Order_matched, LengthFilt, channel_begin_BM, channel_end_BM] = param_lists{:};

% shortcut lengths
len_drnl = length(channels_drnl_first_band);
len_erblet = length(med_len_erblet);
len_channel_start = length(channel_start);
len_lyon = length(channels_lyon_end);
len_seneff_channels = length(channels_seneff_end);
len_seneff_med = length(med_len_seneff);
len_ar_seg = length(LengthSeg_ar);
len_ar_order = length(Order_ar);
len_matched_seg = length(LengthSeg_matched);
len_matched_order = length(Order_matched);
len_wavelet = length(LengthFilt);
len_begin_bm = length(channel_begin_BM);
len_end_bm = length(channel_end_BM);

% Decompose the struct and assign values to the same names
th_drnl = thresholds.th_drnl;
th_erb = thresholds.th_erb;
th_lyon = thresholds.th_lyon;
th_senef = thresholds.th_senef;
th_ar = thresholds.th_ar;
th_matched = thresholds.th_matched;
th_wave = thresholds.th_wave;
th_vencovs = thresholds.th_vencovs;

% Preallocate arrays
Ap1 = -1 * ones(n, max_len, max_len); % Aprime results matrix
dp1 = -1 * ones(n, max_len, max_len); % dprime results matrix
cd1 = -1 * ones(n, max_len, max_len); % Correct detection ratio matrix
fd1 = -1 * ones(n, max_len, max_len); % False detection results matrix
et1 = zeros(n, max_len, max_len); % elapsed time matrix

% Create Ap2 to Ap8
Ap2 = -1 * ones(n, max_len, max_len);
Ap3 = -1 * ones(n, max_len, max_len);
Ap4 = -1 * ones(n, max_len, max_len);
Ap5 = -1 * ones(n, max_len, max_len);
Ap6 = -1 * ones(n, max_len, max_len);
Ap7 = -1 * ones(n, max_len, max_len);
Ap8 = -1 * ones(n, max_len, max_len);

% Create dp2 to dp8
dp2 = -1 * ones(n, max_len, max_len);
dp3 = -1 * ones(n, max_len, max_len);
dp4 = -1 * ones(n, max_len, max_len);
dp5 = -1 * ones(n, max_len, max_len);
dp6 = -1 * ones(n, max_len, max_len);
dp7 = -1 * ones(n, max_len, max_len);
dp8 = -1 * ones(n, max_len, max_len);

% Create cd2 to cd8
cd2 = -1 * ones(n, max_len, max_len);
cd3 = -1 * ones(n, max_len, max_len);
cd4 = -1 * ones(n, max_len, max_len);
cd5 = -1 * ones(n, max_len, max_len);
cd6 = -1 * ones(n, max_len, max_len);
cd7 = -1 * ones(n, max_len, max_len);
cd8 = -1 * ones(n, max_len, max_len);

% Create fd2 to fd8
fd2 = -1 * ones(n, max_len, max_len);
fd3 = -1 * ones(n, max_len, max_len);
fd4 = -1 * ones(n, max_len, max_len);
fd5 = -1 * ones(n, max_len, max_len);
fd6 = -1 * ones(n, max_len, max_len);
fd7 = -1 * ones(n, max_len, max_len);
fd8 = -1 * ones(n, max_len, max_len);

% Create et2 to et8
et2 = zeros(n, max_len, max_len);
et3 = zeros(n, max_len, max_len);
et4 = zeros(n, max_len, max_len);
et5 = zeros(n, max_len, max_len);
et6 = zeros(n, max_len, max_len);
et7 = zeros(n, max_len, max_len);
et8 = zeros(n, max_len, max_len);

% threshold
parfor t = 1:n 
    % parameter division steps iteration
    for p = 1:max_len
        % % algorithms that have only 1 parameter
        % try 
        %     if p <= len_drnl
        %         [Ap1(t, p, 1), dp1(t, p, 1), cd1(t, p, 1), fd1(t, p, 1), et1(t, p, 1)] = run_detect_DRNL(th_drnl(t), channels_drnl_first_band(p), train_list, listen_th);
        %     end
        % catch ME
        %     Ap1(t, p, 1) = -1;
        %     dp1(t, p, 1) = -1;
        %     cd1(t, p, 1) = -1;
        %     fd1(t, p, 1) = -1;
        %     et1(t, p, 1) = -1;
        %     % Access properties of the MException object
        %     disp(['Error Message: ' ME.message]);
        %     disp(['Error Identifier: ' ME.identifier]);
        %     disp(['DRNL_th' num2str(t) '_p_' num2str(p)]);
        % 
        % end
        % try
        %     % Case 1: len_lyon
        %     if p <= len_lyon
        %         [Ap3(t, p, 1), dp3(t, p, 1), cd3(t, p, 1), fd3(t, p, 1), et3(t, p, 1)] = run_detect_Lyon(th_lyon(t), channels_lyon_end(p), train_list, listen_th);
        %     end
        % catch ME
        %     Ap3(t, p, 1) = -1;
        %     dp3(t, p, 1) = -1;
        %     cd3(t, p, 1) = -1;
        %     fd3(t, p, 1) = -1;
        %     et3(t, p, 1) = -1;
        %     % Access properties of the MException object
        %     disp(['Error Message: ' ME.message]);
        %     disp(['Error Identifier: ' ME.identifier]);
        %     disp(['lyon_th' num2str(t) '_p_' num2str(p)]);
        % end
        % 
        % try
        %     % Case 2: len_wavelet
        %     if p <= len_wavelet
        %         [Ap7(t, p, 1), dp7(t, p, 1), cd7(t, p, 1), fd7(t, p, 1), et7(t, p, 1)] = runAnalysisWavelet_JAES_f(th_wave(t), LengthFilt(p), train_list, listen_th);
        %     end
        % catch ME
        %     Ap7(t, p, 1) = -1;
        %     dp7(t, p, 1) = -1;
        %     cd7(t, p, 1) = -1;
        %     fd7(t, p, 1) = -1;
        %     et7(t, p, 1) = -1;
        %     % Access properties of the MException object
        %     disp(['Error Message: ' ME.message]);
        %     disp(['Error Identifier: ' ME.identifier]);
        %     disp(['wavelet_th' num2str(t) '_p_' num2str(p)]);
        % end
        % run the second parameter /
        for pp = 1:max_len
            % try
            %     % Case 3: len_erblet
            %     if p <= len_erblet && pp <= len_channel_start
            %         [Ap2(t, p, pp), dp2(t, p, pp), cd2(t, p, pp), fd2(t, p, pp), et2(t, p, pp)] = run_detect_erblet(th_erb(t), med_len_erblet(p), channel_start(pp), train_list, listen_th);
            %     end
            % catch ME
            %     Ap2(t, p, pp) = -1;
            %     dp2(t, p, pp) = -1;
            %     cd2(t, p, pp) = -1;
            %     fd2(t, p, pp) = -1;
            %     et2(t, p, pp) = -1;
            % % Access properties of the MException object
            % disp(['Error Message: ' ME.message]);
            % disp(['Error Identifier: ' ME.identifier]);
            % disp(['erblet_th' num2str(t) '_p_' num2str(p) '_pp_' num2str(pp)]);
            % end
            % 
            % try
            %     % Case 4: len_seneff_channels
            %     if p <= len_seneff_channels && pp <= len_seneff_med
            %         [Ap4(t, p, pp), dp4(t, p, pp), cd4(t, p, pp), fd4(t, p, pp), et4(t, p, pp)] = run_detect_Seneff(th_senef(t), channels_seneff_end(p), med_len_seneff(pp), train_list, listen_th);
            %     end
            % catch ME
            %     Ap4(t, p, pp) = -1;
            %     dp4(t, p, pp) = -1;
            %     cd4(t, p, pp) = -1;
            %     fd4(t, p, pp) = -1;
            %     et4(t, p, pp) = -1;
            % % Access properties of the MException object
            % disp(['Error Message: ' ME.message]);
            % disp(['Error Identifier: ' ME.identifier]);
            % disp(['seneff_th' num2str(t) '_p_' num2str(p) '_pp_' num2str(pp)]);
            % end
            % try
            %     if p <= len_ar_seg && pp <= len_ar_order
            %         [Ap5(t, p, pp), dp5(t, p, pp), cd5(t, p, pp), fd5(t, p, pp), et5(t, p, pp)] = runAnalysisAR_JAES_f(th_ar(t), LengthSeg_ar(p), Order_ar(pp), train_list, listen_th);
            %     end
            % catch ME
            %     Ap5(t, p, pp) = -1;
            %     dp5(t, p, pp) = -1;
            %     cd5(t, p, pp) = -1;
            %     fd5(t, p, pp) = -1;
            %     et5(t, p, pp) = -1;
            % % Access properties of the MException object
            % disp(['Error Message: ' ME.message]);
            % disp(['Error Identifier: ' ME.identifier]);
            % disp(['ar_th' num2str(t) '_p_' num2str(p) '_pp_' num2str(pp)]);
            % end
            % try
            % 
            %     if p <= len_matched_seg && pp <= len_matched_order
            %         [Ap6(t, p, pp), dp6(t, p, pp), cd6(t, p, pp), fd6(t, p, pp), et6(t, p, pp)] = runAnalysismatch_JAES_f(th_matched(t), LengthSeg_matched(p), Order_matched(pp), train_list, listen_th);
            %     end
            % catch ME
            %     Ap6(t, p, pp) = -1;
            %     dp6(t, p, pp) = -1;
            %     cd6(t, p, pp) = -1;
            %     fd6(t, p, pp) = -1;
            %     et6(t, p, pp) = -1;
            % % Access properties of the MException object
            % disp(['Error Message: ' ME.message]);
            % disp(['Error Identifier: ' ME.identifier]);
            % disp(['matched_th' num2str(t) '_p_' num2str(p) '_pp_' num2str(pp)]);
            % end
            try
                if p <= len_begin_bm && pp <= len_end_bm
                    [Ap8(t, p, pp), dp8(t, p, pp), cd8(t, p, pp), fd8(t, p, pp), et8(t, p, pp)] = runBMmodelTEST_JAES_2(th_vencovs(t), channel_begin_BM(p), channel_end_BM(pp), train_list, listen_th);
                end
            catch ME
                Ap8(t, p, pp) = -1;
                dp8(t, p, pp) = -1;
                cd8(t, p, pp) = -1;
                fd8(t, p, pp) = -1;
                et8(t, p, pp) = -1;
            % Access properties of the MException object
            disp(['Error Message: ' ME.message]);
            disp(['Error Identifier: ' ME.identifier]);
            disp(['BM_th' num2str(t) '_p_' num2str(p) '_pp_' num2str(pp)]);
            end
        end
    end
end

Ap = struct();
dp = struct();
cd = struct();
fd = struct();
et = struct();

Ap.Ap1 = Ap1;
Ap.Ap2 = Ap2;
Ap.Ap3 = Ap3;
Ap.Ap4 = Ap4;
Ap.Ap5 = Ap5;
Ap.Ap6 = Ap6;
Ap.Ap7 = Ap7;
Ap.Ap8 = Ap8;

dp.dp1 = dp1;
dp.dp2 = dp2;
dp.dp3 = dp3;
dp.dp4 = dp4;
dp.dp5 = dp5;
dp.dp6 = dp6;
dp.dp7 = dp7;
dp.dp8 = dp8;

cd.cd1 = cd1;
cd.cd2 = cd2;
cd.cd3 = cd3;
cd.cd4 = cd4;
cd.cd5 = cd5;
cd.cd6 = cd6;
cd.cd7 = cd7;
cd.cd8 = cd8;

fd.fd1 = fd1;
fd.fd2 = fd2;
fd.fd3 = fd3;
fd.fd4 = fd4;
fd.fd5 = fd5;
fd.fd6 = fd6;
fd.fd7 = fd7;
fd.fd8 = fd8;

et.et1 = et1;
et.et2 = et2;
et.et3 = et3;
et.et4 = et4;
et.et5 = et5;
et.et6 = et6;
et.et7 = et7;
et.et8 = et8;

end
