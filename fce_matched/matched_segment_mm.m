function [ detek_seg] = matched_segment_mm( segment_sig, rad_AR, threshold)
% detek_seg = matched_segment_mm( segment_sig, rad_AR, prah_chyb)
% Click detection based on matched filter, one channel signal segment
% Algorithm of matched filter based click detection described in
% [1] Vaseghi S. V., Rayner P.  A new application of adaptive
% filters for restoration of archived gramophone recordings, Proc. 
% International Conference on Acoustics, Speech and Signal Processing, 1992. 
% http://dx.doi.org/10.1109/ICASSP.1988.197163
% [2] Godsil, S.,  Rayner P.: Digital Audio Restoration, 1998
%
% segment_sig - signal segment (one channel)
% rad_AR - AR model order p
% threshold - threshold parameter (gain) K
%
% Implemented by: Václav Vencovskı, Marek Semanskı, Frantisek Rund
% FEE CTU 2021
% MATLAB Version: 9.4.0.813654 (R2018a)

%lpc coefficients and variance
[lpc_koef, var2] = lpc(segment_sig,rad_AR);

% filtering by decorelation filter
err = filter(lpc_koef,1,segment_sig);

%inverse filter coefficients
lpc_koef_inv = fliplr(lpc_koef);

% filtration by the inverse filter
chybovy_sig = filter(lpc_koef_inv,1,err);

% filter delay compensation
chybovy_sig = [chybovy_sig(rad_AR+1:end); zeros(rad_AR,1)];

% zeroing of samples upto the order
chybovy_sig(1:rad_AR) = 0;

chybovy_sig(end-rad_AR:end) = 0;


% detection using threshold (1 where error signal > threshold)
detek_seg = abs(chybovy_sig) > threshold*sqrt(var2);

end