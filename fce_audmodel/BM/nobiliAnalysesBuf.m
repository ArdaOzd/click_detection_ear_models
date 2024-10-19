function [out auxout] = nobiliAnalysesBuf(fs,signal,par,aux)
% function [BMvel BMdisp TMvel TMdisp other] = mammnobBM(fs,signal,par)
% cochlear frequency selectivity model
% Implemented by: R.Nobili - Padova University, Italy (October 2000)
% 
%   references:
%     Mammano F. and Nobili R. (1993) - Biophysics of the cochlea:  Linear approximation -
%     J.Acoust.Soc.Am. (93) 3320-3332.
% 
%     Nobili R. and Mammano F., (1996) - Biophysics of the cochlea II:    Stationary nonlinear phenomenology - J.Acoust.Soc.Am. (99) 2244-2255.
% 
% 
% fs - sample freq
% input - input signal (stapes velocity or displacement)
% par       nsect - number of sections (points along the BM)
%           active - 1 - active cochlea
%                    0 - passive cochlea
% 
% 
% adjusted by Vaclav Vencovsky, vencovac@fel.cvut.cz, Aug 2010
%
% addpath('Models/BM/mammnob'); % addpath to needed functions
% addpath('Models/BM/vetesnik'); % addpath to needed functions
% addpath('../Models/BM/vetesnik'); % addpath to needed functions
        
    nsect = par.nsect;
    nTimes = par.downsmpl; % how many times resample signal

    fsup = nTimes*fs;
%     [Mh, DampSp, stiff, undamp, Da, Dy, Dw, Vs, N, x, dT,] = alldata(1/fs);
    
    [Mh, DampSp, stiff, Vs, x, dT, Da, Dy, Dw, bigamma, undamp, bmw] = alldataNL(nsect,1/fsup);
    
    % adjustment of active part (how much are different sections amplified)
    hnew = [linspace(10,1.4,14)'; linspace(1.37,0.9,8)'; linspace(0.84,0.5,8)']; % for N = 300
    
    nl_adjust = interp1(1:10:300,hnew,1:300,'spline')';
    nl_adjust = ones(nsect,1); % ADDED
%     h = linspace(10,1,140)';
%     nl_adjust = [h; ones(300-length(h),1)];
    
    if par.active==0
           undamp = 0*undamp;   % passive cochlea (no undamping)
    end;

    Z = zeros(size(x));
    Z=Z(:);% make sure that Z is column	
   
             
    X = Z(:);
	V = Z;	
	dV = Z;
	Y = Z;
	W = Z;
    dW = Z;
	Lo=1;   
    n =1;
    L = length(signal); % number of the signal samples
    
    
    auxout = aux;
    % resample
    
    signalUp = interp(signal,nTimes);
    
    
    
    BMvel = zeros(L,nsect); % output bm velocity
    BMdisp = zeros(L,nsect); % output bm displacement
    TMvel = zeros(L,nsect); % output tm velocity
    TMdisp = zeros(L,nsect); % output tm displacement
    out = zeros(L,nsect);
    undamp = undamp*1.00;
    
    
    
    input = zeros(size(signalUp));
%     input = signal;
    eL = length(input);
    
    input(2:eL) = (signalUp(2:eL) - signalUp(1:eL-1))*1e8; % derivation of the input signal (transfer from velocity to acceleration)
%     input(3:L)=6e9*(signal(3:L)+signal(1:L-2)-2*signal(2:L-1)); % second derivation (just to try)
%     input = 2.4809e+06*signal;

    buf_size = 1000;  % buffer size
    Nb = ceil(length(input)/buf_size); % number of processing steps (num of buffers)
    if mod(length(input),buf_size)>0
        input = [input; zeros(buf_size-mod(length(input),buf_size),1)]; % add zeros to have length equal to multiples of buf size
    end;
        
    BMvel_buf = zeros(buf_size,nsect);
    BMdisp_buf = zeros(buf_size,nsect);
    TMvel_buf = zeros(buf_size,nsect);
    TMdisp_buf = zeros(buf_size,nsect);

    
    for k=1:Nb   % main loop over buffers

        inp_buf = input((k-1)*buf_size + 1:k*buf_size);
%         size(inp_buf)
        
    
        
        for t=Lo:buf_size
      
            % --------- TM equations -------------------
            dW = -Dw.*W - Dy.*Y - Da.*dV; % +0.1*input(t);%TM acceleration times dT, last term = 
      										%driving force neg. proportional to BM acc.
            %WdT=W*dT;									
      
            Y  = Y + W*dT; % TM displacement incrementation
            W  = W + dW*dT; % TM velocity incrementation 
            
            % --------- BM equations -------------------
             %  
      
            % The sigmoidal profile of the cell motor response to stereocilia displacement
            % is approximated by cutting up and down the profile of the TM displacement:
      
            %       Ycut = 0.5*(Y-0.3+abs(Y+0.3)); % cutting down
            %       Ycut = 0.5*(Ycut+0.4 -abs(Ycut-0.4)); % cutting up % old nonlinear
      
            %       Ycut = nonlin(Y); % Vetesnik
  
            %       Ycut = [0.01*V(3:end); 0; 0];

            Ycut = nonlin(Y,nl_adjust); % Vetesnik

      
            dV = -Vs*inp_buf(t) - Mh* (stiff.*X + DampSp*V + undamp.*Ycut);
            %       other1(t,:) = undamp.*Ycut;
            %       other2(t,:) = DampSp*V;
            %       
            %tanh(Y));
      
      										% BM acceleration times dT
      										% Mh (mexican hats) = inverse of Green's fun. matrix
      										% stiff = BM stiffness
                                    % DampSp = BM damping due to absolute and shear
                                    % organ of Corti viscosity (sparse matrix)
                                    % undamp = it is shapeplot(tx,BMvel(:,100),'r--')d so as to compensate for DampSp
            X = X + V*dT; % BM displacement incrementation
            V = V + dV*dT; % BM velocity incrementation 
   
            
            
           BMvel_buf(t,:) = 4e-3./bmw.*V;% take into acount width of basilar membrane
            %       BMvel(t,:) = V;
            %       BMvel(t,:) =  Y;
            BMdisp_buf(t,:) = Y;
            TMvel_buf(t,:) = dV;
            TMdisp_buf(t,:) = Vs*inp_buf(t);
      
        end
        
        % resample and add output buffers to the output matrices
%         out((k-1)*buf_size/par.downsmpl + 1:k*buf_size/par.downsmpl,:) = downsample(BMvel_buf,par.downsmpl); % velocity
        out((k-1)*buf_size/par.downsmpl + 1:k*buf_size/par.downsmpl,:) = downsample(BMdisp_buf,par.downsmpl); % displacement
                
    end
    
      other.stiff = stiff;
%       other.DampSp = resample(DampSp,1,par.downsmpl);
      other.undamp = undamp;
      other.Mh = Mh;
      other.x = x;
      other.Vs = Vs;
% out = resample(BMvel,1,par.downsmpl);   % velocity output
% out = phaseOFharmonic(1e10*BMvel(:,190),input);
% out = resample(BMdisp,1,par.downsmpl) - resample(TMdisp,1,par.downsmpl); % displacement output
% out = resample(TMdisp,1,par.downsmpl); % TM displacement output
% auxout.BMdisp = resample(BMdisp,1,par.downsmpl);
% auxout.TMvel = resample(TMvel,1,par.downsmpl);
% auxout.TMdisp = resample(TMdisp,1,par.downsmpl);
% auxout.other1 = resample(TMw,1,par.downsmpl);;
% auxout.other2 = resample(TMdisp,1,par.downsmpl);;
auxout.other = other;
% auxout.input = input;
%auxout.cf = get_cf(size(out,2));    % call function for getting cf vector
auxout.newMin = par.minSection;
auxout.newMax = par.maxSection;

      
      
      
%       rmpath('Models/BM/vetesnik'); % addpath to needed functions
      
%  rmpath('Models/BM/mammnob'); % addpath to needed functions
 
function [Z]=nonlin(Y,nl_adjust)
% nonlinear function taken from Vetesnik
     
Y  = 1.0*Y;     
y1=0.01139;
y2=0.03736;
c1=0.7293;
c2=1.4974;
b=0.30991;

%     h = linspace(10,1,140)';
%     nl_adjust = [h; ones(300-length(h),1)];

Z=(1./(1+c1*exp(-nl_adjust.*Y./y1)+c2*exp(-nl_adjust.*Y./y2)+0.0))-b;

Z=0.1*Z./nl_adjust;


% Z=(1./(1+c1*exp(-Y./y1)+c2*exp(-Y./y2)))-b;
% 
% Z=0.1*Z;



     %function cf = get_cf(nSamples)
         
         
%      % BM according to Vetesnik parameters
%      
%      f = [20 50	100	150	200	300	400	500	600	800	1000	1200	1500	2000	3000	4000	5000	6000	7000	8000	10000];
% 
% 
%      section = [290	281	277	272	268	256	245	235	226	211	198	187	172	152	120	96	77	60	45	32	9];
%      
%      
%      
%      
%      
%      
%      sectionInt = nSamples:-1:1;
%      cf = fliplr(spline(section,f,sectionInt')); % interpolation
%      
%      cf(find(cf==(min(cf)))+1:end) = 0; % because the last cf are more then again lower, so I have to zero them manually
%      
   %load cf_nobiliEXP.mat     % load cf vector
%    load cf_nobiliEXP_R3107.mat     % load cf vector
          
     %load c
     