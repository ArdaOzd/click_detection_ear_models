function [x,BMinput,Ginv,stiff,ShSp,undamp,bigamma,wm2] = alldataRG(N,Fo,alpha,base)
%
% 	Function ALLDATARG is called by the main routine COCHLEARG.M in order to load 
%   all data being necessary  to the time domain RungeKutta implementation of the human cochlea
%    
%	 x  =	BM point vector (nonuniform (function vargrid1(N))
%    BMinput =	Stapes propagator multiplayed by the inverse of the Green's function
%	 Prop =	  Stapes propagator times by dx
%	 Ginv =	  Mexican hat matrix: inverse of the Green's function
%	 DampSp = BM damping matrix accounting for absolute and shear viscosity
%	 stiff = BM stiffness vector
%	 undamp = undamping vector
%	 wm2 =	TM normalized stiffness (K/M)
%	 Dw =	TM normalized damping   (H/M)
%	 N  =	Number of points on BM

if nargin<4, base=2.4531;    end
if nargin<3, alpha=-6.36;  end
if nargin<2, Fo=2.11e+004; end
if nargin <1, N=600;         end



%________________________BM data_______________________________
if exist('BMDATARG.MAT')==2,
	load BMDATARG.MAT
else,
	disp(' File BMDATARG.MAT does not exist. It will be created!');
    x = gaussgrid(N);  % Generates a set of points covering the interval 0-1 with Gaussian distributed density    (see GAUSSGRID.M) 
    bmdataRG(x); 
    disp('	Now BMDATARG.MAT does exist');
    load BMDATARG.MAT
end

%________________________________________________
 %load LAMBDAS6.MAT lam
 load LAMBDAS6a.MAT lam
%--------------------TM-parameters-----------
 %-------------------------------------------
  wm=2*pi*Fo*base.^(alpha*(x+0.05));
  wm2=wm.*wm;  % equivalent to K/M along the TM 
  bigamma=2*pi*Fo*base.^(0.5*alpha*(x+0.05));
  bigamma=bigamma(:)./0.95;
  wm2=wm2(:);% equivalent to H/M along the TM 
  undamp=0.87*damp0.*bigamma.*lam;

 