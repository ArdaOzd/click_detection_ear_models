function ClickDetection = vlnkova_segment_mm( segment_sig, vlnka, prah_fil, delka_fil, idxLup, idxTolerance,isClick)
% ClickDetection = vlnkova_segment_JAES( segment_sig, vlnka, prah_fil, delka_fil, idxLup, idxTolerance,isClick)
% Wavelet transform based click detection evaluation with respect to listening tests
% ClickDetection == 1 click detected
% ClickDetection == 0 click not detected
% ClickDetection == -1 click detected but not marked in listening tests
% (false detection)
%
% The algorithm is described in 
% [1] Nongpiur R. C., Impulse noise removal in speech using wavelets, 
% Proc. of the IEEE international conference on Acoustics, Speech, and 
% Signal Processing (ICASSP 2008)}, pp. 866--879 (2008).
% http://dx.doi.org/10.1109/ICASSP.2008.4517929
%
% segment_sig: input signal, one channel
% vlnka: wavelet
% prah_fil: threshold
% delka_fil: Median filter window length L
% idxLup: position of known click
% idxTolerance: distance tolerance
% idClick: 1 - input signal contains clicks (from subj. test)
%
% Implemented by: Václav Vencovský, Marek Semanský, Frantisek Rund
% FEE CTU 2021
% MATLAB Version: 9.4.0.813654 (R2018a)


%decomposition to N level
N =2 ;

[C,L] = wavedec(segment_sig,N,vlnka);

for i=1:N
    
    Xw(i,:) = abs(wrcoef('d',C,L,vlnka,i));
        
    env(i,:) = medfilt1(Xw(i,:),delka_fil); %envelope calculated by median filtration
       
end

%detection 
detect_seg = Xw > prah_fil*env;

detect_seg(1:round(1.5*delka_fil)) = 0;
detect_seg(end-round(1.5*delka_fil):end) = 0;

zL = 1000; % zero samples at the begining and end of the sample
detect_seg(1:zL) = 0;
detect_seg(end-zL+1:end) = 0;

%decomposition to the first level only
detect_res = detect_seg(1,:);%.*detect_seg(2,:);

%Evaluation
    if isClick==1
        if max(detect_res(idxLup-idxTolerance:idxLup+idxTolerance))>0
            ClickDetection=1;
        else
            ClickDetection=0;
        end
    else
        if max(detect_res)>0
            ClickDetection = 1;
        else
            ClickDetection = 0;
        end        
    end
end

