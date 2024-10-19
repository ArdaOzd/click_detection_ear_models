function  x  = gaussgrid(N, plotflag)
%
%	    FUNCTION  X = GAUSSGRID(N, PLOT_FLAG)
%
%       Generates a set of points covering the interval 0-1 with Gaussian distributed density    
%	    N = Number of points in the grid
%	    X = BM site array of gaussian distributed spacing
%       PLOT_FLAG = plot only if 1
%


if nargin<2,
	plotflag=0;
end

if nargin<1,
	N=500;
end

stred=0.35;
sig1=2*(1.2)^2;    
sig2=2*(0.46)^2;   

xo=(1:N)/N;

ind=ceil(stred/xo(1));
dx(1:ind)=exp(((xo(1:ind)-xo(ind)).^2)./sig1);
dx(ind+1:N)=exp(((xo(ind+1:N)-xo(ind)).^2)./sig2);
dx=dx/sum(dx);

x(1)=dx(1);

for i=2:N,
	x(i)=x(i-1)+dx(i);
end

if (x(N) > 1), 
	x(N) = 1; 
end

dens=ones(size(dx))./dx;
Nmx=max(dens);
Nmn=min(dens);

if plotflag==1,
	[xm, im] = min(abs(x-0.5));
	Nmdl=dens(im);

	figure(22);
	clf,
	plot(x, zeros(size(x))+Nmx/2,'.w',x,dens,'-r'), 
	axis([0,1,0,Nmx]);
	text(0.2, 0.95*Nmx, ['Max.density = ', num2str(Nmx)])
	text(0.2, 0.85*Nmx,  ['Mid.density = ', num2str(Nmdl)])
	text(0.2, 0.75*Nmx, ['Min.density = ', num2str(Nmn)])
	ylabel('Point density')
    xlabel('Fractional distance from stapes')
end