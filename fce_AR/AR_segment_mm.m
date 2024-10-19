function detek_seg = AR_segment_mm( segment_sig, rad_AR, prah_chyb)
% detek_seg = AR_segment_mm( segment_sig, rad_AR, prah_chyb)
% Click detection based on AR model, one channel signal segment
% Algorithm of AR model based click detection described in
% [1] Godsil, S.,  Rayner P.: Digital Audio Restoration, 1998
%
% segment_sig - signal segment (one channel)
% rad_AR - AR model order
% prah_chyb - threshold
%
% Implemented by: Václav Vencovský, Marek Semanský, Frantisek Rund
% FEE CTU 2021
% MATLAB Version: 9.4.0.813654 (R2018a)

%lpc coefficients and variance
[lpc_koef, var2] = lpc(segment_sig,rad_AR);

err = filter([0 -lpc_koef(2:end)],1,segment_sig);

% error signal
chybovy_sig = segment_sig - err;

% zeroing of samples upto the order
chybovy_sig(1:rad_AR) = 0;
chybovy_sig(end-rad_AR:end) = 0;

% detection using threshold (1 where error signal > threshold)
detek_seg = abs(chybovy_sig) > (prah_chyb*sqrt(var2));


end
