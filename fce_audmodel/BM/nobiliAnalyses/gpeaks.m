function [P,dx] = gpeaks(x, plotflag);
%
% 	PEAKS.M  computes the Green's function peak matrix of the human 
%       cochlea. Data is loaded from MAN_DATA.MAT.
%
%		[P, dx] = GPEAKS(x);
%
% 	x  =  BM point vector.
%	plotflag = If set to 1, plots are showed (def. 0)
% 
%	dx = Interpoint distances
%	P  = Peak matrix
%	
%	Matrix P is not normalised (see PSIGMA.M) and must be multiplied 
%	by b(x)*b(x'), where b(x) is the BM width. The dimension of P
%	is  1/BETA  in BETA units (1 BETA = 33.5 mm).
%
%	Files CDDATA.MAT, BMWDATA.MAT, INTERPOL.M  and PSIGMA.M are called.
%	
%			(R.Nobili-Padova University, last rev. 15-2-03)

if nargin <2,
	plotflag=0;
end

if nargin < 1
	plotflag=1;
    x = (1:400)/400;
end


disp('	Function GPEAKS is at work');
bmwdata=[];	% initialisation of basilar membrane width array
N=length(x);
x=x(:);		% To make sure that x is a column
c=[x(1);x(2:N)+x(1:N-1)]/2;	% averaged coordinates

load bmwdata.mat -ascii	% Loading BM width data. This yields 2-column matrix 'bmw'

b=interpol(bmwdata(:,1),bmwdata(:,2),x); 	% Interpolating BM-width data	

b=b/2; 		% The effective BM width is 1/2 the geometrical width		

% Initialization of arrays to be loaded from CDDATA.MAT 

xp=[];
yp=[];
xm=[];
ym=[];

load cddata.mat 	% Loading cochlear radii. This yields xp, yp, xm, ym  

rp=interpol(xp, yp, c); % Interpolating upper cochlear radius

rm=interpol(xm, ym, c); % Interpolating lower cochlear radius

r = (rp+rm)/2;   % Computing averaged coclear radius at point c(i) 

% ---------------------------------------------------------


xo=[0;x(1:N-1)];
dx=x-xo;	% interval lengths

% The following routine computes peaks without reflection effect at the stapes

P=zeros(N,N);

% for j=1:N,
% 	P(:,j)=psigma(x-c(j),b(j),r(j))-psigma(xo-c(j),b(j),r(j));
% end

%---------------------------------------------------------------

% The following routine computes peaks with reflection at stapes,
% i.e.  peak + image-peak  mirrored a x=0.

for j=1:N,
 cj=c(j);
 bj=b(j);
 rj=r(j);
 P(:,j) = psigma(x-cj,bj,rj)-psigma(xo-cj,bj,rj)+psigma(x+cj,bj,rj)-psigma(xo+cj,bj,rj);
end



if plotflag==1,
	figure(5)
	clf
	plot(x, P(:,1:20:N) ),
	title('BM-BM Green''s function peaks'),
	pause(5)
end	