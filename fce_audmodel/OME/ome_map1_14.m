function output = ome_map1_14(inputSig,fs)
% function output = ome_map1_14(inputSig,fs);


sampleRate = fs;


OMEParams=[];

% parameters for outer ear
OMEParams.externalResonanceFilters= ...
    [ 10    1  1000   4000; ...
    25    1  2500   7000 ];

% parameters for middle ear
OMEParams.OMEstapesHPcutoff= 1000;
%  set scalar. NB Huber gives 2e-9 m at 80 dB, 1 kHz. (==2e-13 at 0 dB SPL)
OMEParams.stapesScalar=	     45e-9;

dt = 1/sampleRate;


inputPressureSegment = inputSig;
signalLength = length(inputPressureSegment);

segmentStartPTR = 1;
segmentEndPTR = signalLength;


%% OME ---
% external ear resonances
OMEexternalResonanceFilters=OMEParams.externalResonanceFilters;
[nOMEExtFilters c]=size(OMEexternalResonanceFilters);
% details of external (outer ear) resonances
OMEgaindBs=OMEexternalResonanceFilters(:,1);
OMEgainScalars=10.^(OMEgaindBs/20);
OMEfilterOrder=OMEexternalResonanceFilters(:,2);
OMElowerCutOff=OMEexternalResonanceFilters(:,3);
OMEupperCutOff=OMEexternalResonanceFilters(:,4);
% external resonance coefficients
ExtFilter_b=cell(nOMEExtFilters,1);
ExtFilter_a=cell(nOMEExtFilters,1);
for idx=1:nOMEExtFilters
    Nyquist=sampleRate/2;
    [b, a] = butter(OMEfilterOrder(idx), ...
        [OMElowerCutOff(idx) OMEupperCutOff(idx)]...
        /Nyquist);
    ExtFilter_b{idx}=b;
    ExtFilter_a{idx}=a;
end
OMEExtFilterBndry=cell(2,1);
OMEextEarPressure=zeros(1,signalLength); % pressure at tympanic membrane

% pressure to velocity conversion using smoothing filter (50 Hz cutoff)
tau=1/(2*pi*50);
a1=dt/tau-1; a0=1;
b0=1+ a1;
TMdisp_b=b0; TMdisp_a=[a0 a1];
% figure(9), freqz(TMdisp_b, TMdisp_a)
OME_TMdisplacementBndry=[];

% OME high pass (simulates poor low frequency stapes response)
OMEhighPassHighCutOff=OMEParams.OMEstapesHPcutoff;
Nyquist=sampleRate/2;
[stapesDisp_b,stapesDisp_a] = butter(1, OMEhighPassHighCutOff/Nyquist, 'high');
% figure(10), freqz(stapesDisp_b, stapesDisp_a)
% 
OMEhighPassBndry=[];
% 
% % OMEampStapes might be reducdant (use OMEParams.stapesScalar)
stapesScalar= OMEParams.stapesScalar;

% Acoustic reflex

% save complete OME record (stapes displacement)
OMEoutput=zeros(1,signalLength);
TMoutput=zeros(1,signalLength);



 % OME ----------------------

    % OME Stage 1: external resonances. Add to inputSignal pressure wave
    y=inputPressureSegment;
    for n=1:nOMEExtFilters
        % any number of resonances can be used
        [x  OMEExtFilterBndry{n}] = ...
            filter(ExtFilter_b{n},ExtFilter_a{n},...
            inputPressureSegment, OMEExtFilterBndry{n});
        x= x* OMEgainScalars(n);
        % This is a parallel resonance so add it
        y=y+x;
    end

    y=y+ inputPressureSegment;
    inputPressureSegment=y;
    OMEextEarPressure(segmentStartPTR:segmentEndPTR)= inputPressureSegment;
    
    % OME stage 2: convert input pressure (velocity) to
    %  tympanic membrane(TM) displacement using low pass filter
%    [TMdisplacementSegment  OME_TMdisplacementBndry] = ...
%        filter(TMdisp_b,TMdisp_a,inputPressureSegment, ...
%        OME_TMdisplacementBndry);
    TMdisplacementSegment = inputPressureSegment;
    % and save it
    TMoutput(segmentStartPTR:segmentEndPTR)= TMdisplacementSegment;

    % OME stage 3: middle ear high pass effect to simulate stapes inertia
    [stapesDisplacement  OMEhighPassBndry] = ...
        filter(stapesDisp_b,stapesDisp_a,TMdisplacementSegment, ...
        OMEhighPassBndry);

    % OME stage 4:  apply stapes scalar
    stapesDisplacement=stapesDisplacement*stapesScalar;

    % OME stage 5:    acoustic reflex stapes attenuation
    %  Attenuate the TM response using feedback from LSR fiber activity

    % segment debugging plots
    % figure(98)
    % plot(segmentTime, stapesDisplacement), title ('stapesDisplacement')

    % and save
    OMEoutput(segmentStartPTR:segmentEndPTR)= stapesDisplacement;

  output = OMEoutput;