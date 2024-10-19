% function bmdataNL(x)
%
%       FUNCTION  BMADATANL(X) 
%
%      Generates the distributed parameters for the basilar membrane (BM) motion equation.  
%
%       X = coordinates of a set of points along the BM in BETA units. BETA is the BM length, therefore X range from 0 to 1.  
%       The distributed parameters are computed  for any set of points. X may be an equally spaced set of  values covering
%       the interval 0-1, or a set of values non-uniformly spaced along the BM (see function VARGRID.M)
%

% if nargin <1,
  x=gaussgrid(300);               %  Generates a set of points covering the interval 0-1 with a Gaussian-distributed density    (see GAUSSGRID.M)
% end   



[Gs, G, Sh bmw] = greenf(x);   % The routine GREENF.M generates the Green's function matrix G, the stapes-BM coupling coefficient
% Gs = 0.8*max(Gs)*ones(size(Gs));          %  vector Gs, and the shearing viscosity matrix Sh for the human cochlea. 
%Gs=Gs*5e-3;                                            
G = 1.0*G; % adjustment of the greenfunction
N=length(x);
M = diag(mass(x));          % MASS.M computes the organ of Corti local mass as a function of position. 
x = x(:);
dx=[x(1);x(2:N)-x(1:N-1)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------- STIFFNESS --------------------------------------
 x = x(:); 		
 dx=[x(1);x(2:N)-x(1:N-1)]; 
 expk = -3.6*log(10); 	% Stiffness exponent  (Base E) (default -3.6*log(10))
 ko = 2e+3;		  % Kg/(BETA*sec^2) , BETA = BM length taken as lenght unit
 k1= ko*exp(expk*x);
 k1=k1(:);
 stiff=[k1(1)-ko; k1(2:N)-k1(1:N-1)]./(expk*dx); 

 
 % slight adjustment
 
 expk2 = -4.9*log(10); 	% Stiffness exponent  (Base E) (default -3.6*log(10))
ko2 = 15e+3;		  % Kg/(BETA*sec^2) , BETA = BM length taken as lenght unit
k12= ko2*exp(expk2*x);
k12=k12(:);
stiff2=[k12(1)-ko2; k12(2:N)-k12(1:N-1)]./(expk2*dx); 

stiff = min(stiff,stiff2);
 
 %----------------------------------------------------
%  m=mass(x(:)');
%  alpha=2.1;A=0.4;k=1.4541;
%  xr=1-x;%relative distance from the apex
%  CF=1e3*A*(10.^(alpha*xr)-k);
%  stiff=((2*pi*CF).^2).*m(:);
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------  DAMPING -------------------------------------------

 % damping constant is imagined to depend mainly the
 % intrinsic viscosity of cochlear motor (OHC+DEITERS CELLS) 
 % h = eta*L/H ; eta = viscosity coefficient
 % [3.35e-5 kg/(BETA*sec) for water, see GREENF.M]
 % L/H = shearing ratio between length L of viscous segment and 
 % thickness H of shearing medium (about 10)
 %    
 %		Author: Renato Nobili - Padova University, Italy (October 2000)

 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 ho = 1*10e-3; 	% Kg/(BETA sec) [about 30 times water viscosity]
 exph = -log(7);	% decreases 4 times
 dampn = 0.8*ho*exp(exph*x)+0.9e-3;
exph = -log(4);	% decreases 4 times DEFUALT
 dampn = 0.8*ho*exp(exph*x);
 %  dampn = 1.1*ho*exp(-1.7*x);
 hbo = 1.1*ho; 
 heo=1.3*dampn(N);
 expho=log(heo/hbo);
 damp0 =hbo*exp(expho*x);
 Ce=2*dampn(N);				
%  dampn = dampn + Ce*exp((x-1)/0.075); default
dampn = dampn + Ce*exp((x-1)/0.035);
%  dampn = dampn;
 h=dampn(:);
 damp0=damp0(:); 
%  Sh = diag(Sh);
%  Sh(105:116) = -1e-2*Sh(105:116);
%  Sh = diag(Sh);



%  ShSp=sparse(diag(1*dampn)) + 65*sparse(Sh);
ShSp=sparse(diag(.29*dampn)) + 65*sparse(Sh); % changed
 % 0.29 posledni verze


% string='save bmdataNL.mat x N M stiff dampn damp0 ShSp G Gs bmw';
% disp(['	',string]);
% eval(string);

