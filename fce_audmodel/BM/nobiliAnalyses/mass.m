function m = mass(x, plotFlag)
%	
%				M = MASS(X, PLOTFLAG)
%
%	Computes the effective organ of Corti mass per unit BM length as a function of 
%   fractional distance from stapes X. This function loads and interpolates BM-width
%   data from BMWDATA.MAT. The unit dimension of  M is Kg/BETA,  where 
%   BETA = 33.5 mm is the BM length.   if PLOTFLAG = 1 the mass density profile
%   is plotted [def. PLOTFLAG = 0]
%

if nargin < 2,
    plotFlag=0;
end

if nargin < 1,
    x=(1:200)/200;
    plotFlag=1;
end
    
bmwdata=[];

load bmwdata.mat -ascii		% loading BM-width data

b=interpol(bmwdata(:,1),bmwdata(:,2),x)/2; 
% On account of the radial BM curvature, the effective width is geometric-width/2.

b=b(:)';

%>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 ho=0.02/33.5;	%  Mean organ of Corti  thickness in BETA units (it is assumed constant)
%>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

N=length(x);

rho=0.0376;	% = 1000/(29.85)^3, water density in Kg/BETA^3, as 1m =29.85 BETA


micron = 29.85e-6; % 1 micron in BETA

 h0 = 20*micron;	  % 20 micron,  putative height of the organ of Corti at base
    		                        % (effective for shear viscosity) 

h = h0*exp(log(4)*x);	% effective organ of Corti height 
			                            % (increases by 4 times from base to apex)

w0 = 50*micron;	  % 50 micron,  
		                         % putative width of the organ of Corti at base
		                         % (effective for shear viscosity) 


w = w0*exp(log(4)*x); % effective organ of Corti width
		                                % (increases by 4 times from base to apex)


w =sqrt(w.*b);	% geometrical mean of  effective widths 

m=rho*(h.*b);	% vector  m  is a row
m = (m+[m(1),m(1:N-1)])/2;  % Local averaging 


if plotFlag ==1,
    figure(1),
    clf, plot(x,m), title('Organ of Corti mass per unit BM length');
    xlabel('Fractional distance from stapes');
    ylabel('Kg/BETA (BETA = 33.5 mm).');
end