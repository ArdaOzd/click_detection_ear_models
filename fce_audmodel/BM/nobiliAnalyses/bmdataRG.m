function bmdataRG(x)
%
%       FUNCTION  BMADATARG(X) 
%
%      Generates the distributed parameters for the basilar membrane (BM) motion equation.  
%
%       X = coordinates of a set of points along the BM in BETA units. BETA is the BM length, therefore X range from 0 to 1.  
%       The distributed parameters are computed  for any set of points. X may be an equally spaced set of  values covering
%       the interval 0-1, or a set of values non-uniformly spaced along the BM (see function VARGRID.M)
%

if nargin <1,
  x=gaussgrid(500);               %  Generates a set of points covering the interval 0-1 with a Gaussian-distributed density    (see GAUSSGRID.M)
end   

[Gs, G, Sh] = greenf(x);   % The routine GREENF.M generates the Green's function matrix G, the stapes-BM coupling coefficient
                                            %  vector Gs, and the shearing viscosity matrix Sh for the human cochlea. 
N=length(x);
M = diag(mass(x));          % MASS.M computes the organ of Corti local mass as a function of position. 
x = x(:); 		
dx=[x(1);x(2:N)-x(1:N-1)]; 
Ginv = inv(G+M);                % Ginv is  the inverse of the BM integro-differential motion equation kernel G+M.   
                                             % The unit length dimension of the model is BETA = BM length; consequently the  
                                             % units of the quantities are Ginv [BETA/Kg]; Gs [Kg/BETA]; Sh [Kg/(BETA*sec)]; x [BETA]

BMinput = Ginv*Gs'; % Adimensional quantity.
% BMinput represents the ratio between the BM displacement and
% stapes displacement as the direct effect of stapes motion
% on the BM and the BM-to-BM reaction at zero BM stiffness
% and viscosity (BMinput decays rapidly from base to apex
% starting from about 250) 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------- STIFFNESS --------------------------------------
%  Default values of parameters for the human cochlea
disp('	Computing stiffness ...')

expk = -3.6*log(10); 	% Stiffness exponent  (Base E)
ko = 2e+3;		  % Kg/(BETA*sec^2) , BETA = BM length taken as lenght unit


% Averaging stiffness over dx

k= ko*exp(expk*x);
k=k(:);
stiff=[k(1)-ko; k(2:N)-k(1:N-1)]./(expk*dx); 
 
% ---------------------------------------------------------------------------

%-------------------  DAMPING -------------------------------------------
%  Default values of parameters

disp('	Computing damping ...')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% damping constant is imagined to depend mainly the
% intrinsic viscosity of cochlear motor (OHC+DEITERS CELLS) 
% h = eta*L/H ; eta = viscosity coefficient
% [3.35e-5 kg/(BETA*sec) for water, see GREENF.M]
% L/H = shearing ratio between length L of viscous segment and 
% thickness H of shearing medium (about 10)
%    
%		Author: Renato Nobili - Padova University, Italy (October 2000)

ho = 10e-3; 	% Kg/(BETA sec) [about 30 times water viscosity]
exph = -log(4);	% decreases 4 times
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dampn = ho*exp(exph*x);
hbo = 1.1*ho; 
heo=1.3*dampn(N);
expho=log(heo/hbo);
damp0 =hbo*exp(expho*x);
Ce=2*dampn(N);				
dampn = dampn + Ce*exp((x-1)/0.075); 

% -----------------------------
dampn=dampn(:);
damp0=damp0(:); 
ShSp = sparse(Sh); 
ShSp=sparse(diag(dampn)) + 95*sparse(Sh);

string='save BMDATARG.MAT Ginv x stiff dampn damp0 ShSp BMinput N';
disp(['	',string]);
eval(string);




