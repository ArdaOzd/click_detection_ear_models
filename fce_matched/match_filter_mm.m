function[ClickDetection] = match_filter_mm(stim_in, order, threshold, LengthSeg,idxLup,idxTolerance,isClick)
% [ClickDetection] = match_filter_mm(stim_in, rad, prah1, LengthSeg,idxLup,idxTolerance,isClick)
% signal segmentation + AR model based click detection evaluation with
% respect to listening tests
% Authors: Václav Vencovský, Marek Semanský, Frantisek Rund
% FEE CTU 2021
% MATLAB Version: 9.4.0.813654 (R2018a)
% ClickDetection == 1 click detected
% ClickDetection == 0 click not detected
% ClickDetection == -1 click detected but not marked in listening tests
% (false detection)
%
%The prediction of AR model is improved by backward prediction, as
%suggested in Godsil, S.,  Rayner P.: Digital Audio Restoration, 1998
%
% stim_in: input signal, one channel
% rad: AR model order
% prah1: threshold
% LengthSeg: length of one segment (frame)
% idxLup: position of known click
% idxTolerance: distance tolerance
% idClick: 1 - input signal contains clicks (from subj. test), 0 - input
% signal contains no clicks


Step = LengthSeg/2; 
slen = length(stim_in); % signal lenghth
kmax = floor(1 + (slen-LengthSeg)/Step); %number of segments
detekce_res = zeros(slen,1);%output vector


%segmentation
for k=3:kmax-1

    ii = (k-1)*Step + 1;  %step
    jj = (k-1)*Step + LengthSeg;

    segment_vybr = stim_in(ii:jj,:);

   %forward detection
    [ detect_seg_fw] = matched_segment_mm( segment_vybr, order, threshold); %matched filter based click detection
       
   %backward detection
    [ detect_seg_bw] = matched_segment_mm( flipud(segment_vybr), order, threshold); %matched filter based click detection
    
    %sum of forward and backward detection to improve localization of a
    %click.
    detekce_res(ii:jj,:) = detekce_res(ii:jj,:) + detect_seg_fw + flipud(detect_seg_bw);
end

%conversion to 0 and 1 only
detekce_res(detekce_res > 0) = 1; 

%is there perceptible click?
if isClick==1
        if max(detekce_res(idxLup-idxTolerance:idxLup+idxTolerance))>0
            ClickDetection=1;
        else
            ClickDetection=0;
        end
    else
        if max(detekce_res)>0
            ClickDetection = -1;
        else
            ClickDetection = 0;
        end        
    end  
end
    
 