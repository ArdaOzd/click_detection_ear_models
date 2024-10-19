function [G0S, G0M] = g0(x, plotflag)
%
%	    Computes coarse profiles of the hydrodynamic Green's function for a 
%	    realistic geometry of the human cochlear duct.
%
%		[G0S, G0M] = G0(X, PlotFlag)
%
%	    X   = BM point vector (points may be irregularly spaced!)
%	    PlotFlag = if set to 1, plots are shown [def.0]
%
%	    G0S = Stapes_BM  coarse Green's function (Stapes-BM  fluid coupling); 
%       G0M = Basilar membrane coarse Green's function (BM-BM fluid coupling).
%	
%	    G0S and G0M are the mere result of the integration over
%	    the inverse of the coclear duct section surfaces and are
%	    NOT multiplied by the BM width. This latter step
%	    is accomplished in the routine GREENF.M. The dimension of 
%	    G0S and G0M is  1/BETA  in BETA units (1 BETA = 33.5 mm).
%
%	(R.Nobili-Padova University, F.Mammano-SISSA, rev. 21-11-97)



if nargin < 2,
	plotflag=0;
end

if nargin < 1
	plotflag=1;
    x = (1:400)/400;
end

% initializing the coordinates of cochlear semiduct radii: 
xp=0;
xm=0;
yp=0;
ym=0;

disp('	Reading human cochlea data...');

x=x(:)'; 	                % Make sure x is a row
N=length(x);

load cddata.mat	% File contains cochlear duct profile data 
		                           % All lengths are scaled to 1 unit == 33.5 mm
		                           % Data from the upper side:  xp, yp 
		                           % Data from the lower side:  xm, ym
		                           % ap, am = cross--sectional areas
		                           % "p" is for upper profile, "m" is for lower.
% xm = xp;
% ym = yp;
Np=max(size(xp))-1;
Nm=max(size(xm))-1;     

ypm= (yp(1:Np)+yp(2:Np+1))/2;   % middle point values (number = Np)	
Sp = pi*ypm.^2;     	                      % Find cross section areas at middle points
				                                            % from human cochlea data, assuming cochlear
				                                            % duct cross sections are circles in this version
ymm= (ym(1:Nm)+ym(2:Nm+1))/2;
Sm = pi*ymm.^2;	 

%%%%%%%%%%%%%%%%%%%% COMMENT THIS TO AVOID PLOTTING %%%%%%%%%%%%%%%%
 if plotflag==1,
	figure(1)
    clf
	plot(xp,yp*33.5,xm,-ym*33.5)
	xlabel('Fractional distance from stapes');
	ylabel('mm');
	title('Radii of human cochlea scalae'),
	pause(5)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% disp('	Computing G0 ...');

dxp = xp(2:Np+1)-xp(1:Np);	% Find interval lengths
dxm = xm(2:Nm+1)-xm(1:Nm);

Intp=zeros(size(1:Np+1));		% Initialize
Intm=zeros(size(1:Nm+1));
IntpP=zeros(size(1:Np+1));		% Initialize

dx_over_Sp = dxp./Sp;		% Find integrand
dx_over_Sm = dxm./Sm;

Intp(Np+1) = (0.5*pi)*yp(Np+1)/Sp(Np);	% Contribution from upper side of helicotrema;
Intm(Nm+1) = (0.5*pi)*ym(Nm+1)/Sm(Nm); 	% Contribution from lower side of helicotrema;

% IntpP(1) = (0.5*pi)*yp(1)/Sp(1);

% uprava (integrace horni casti od ovalneho okenka)

% for i=1:Np
% 	IntpP(i) = IntpP(i+1)+dx_over_Sp(i);
% end

% default
for i=Np:-1:1,
	Intp(i) = Intp(i+1)+dx_over_Sp(i);
end

for i=Nm:-1:1,
	Intm(i) = Intm(i+1)+dx_over_Sm(i);
end

% Interpolation of Intp and Intm: 

G0S= interpol(xp(1:Np+1),Intp,x) + interpol(xm(1:Nm+1), Intm,x);  
G0M=G0S'*ones(size(G0S));
G0M=tril(G0M) + tril(G0M)'- diag(G0S);

%%%%%%%%%%%%%%%%%%%%%% COMMENT THIS TO AVOID PLOTTING %%%%%%%%%%%%%%%

if plotflag==1,
	figure(2)
    clf
	plot(x', G0M(:,(1:10:N)))
	title('Coarse BM-BM pressure Green''s functions'), 
	pause(5)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('	Loading BM width data ...')
load bmwdata.mat -ascii         % BM WIDTH DATA ARE IN BETA UNIT (BETA = BM length = 33.5 mm)

if plotflag==1,
	figure(3)
	clf,
	plot(bmwdata(:,1), 33.5*bmwdata(:,2),bmwdata(:,1),33.5*bmwdata(:,2),':r'),
    axis([0 1 0 0.02*33.5]);
    title('Basilar membrane width');
	xlabel('Fractional distance from stapes');
	ylabel('mm');
	pause(5)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if plotflag==1,
    b=interpol(bmwdata(:,1), bmwdata(:,2),x);	% b is a column
    b=b/2;  % Effective BM width in BETA units
    Gc = G0M.*(b'*b);
	figure(4)
    clf
	plot(x',Gc(:,1:10:N)),
    title('Coarse BM-BM force Green''s function')
    pause(5)
end