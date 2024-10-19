function  Y = interpol(x, y, X, plag)
%
%		Yout = INTERPOL(Xin, Yin, Xout, PlotFlag)
%
%       linearly interpolates vector  Yin  within each pair of values 
%	[Yin(i), Yin(i+1)], defined at abscissae [Xin(i), Xin(i+1)], 
%	for all values  Xout(j)  of any given N-dimensional vector  
%	Xout. Values of  Yin  at points  Xin(i) falling out from the range 
%	of  Xout  are linearly extrapolated from the adjacent pairs 
%	of Yin  values.
% 
%	PlotFlag = 1,  to plot interpolation data   

if nargin<4,
	plag=0;
end

n = length(x);   

x = x(:)';	% make sure that x, y, X are rows.
y = y(:)';
X = X(:)';

[x, Ind]= sort(x); 	% make sure y is plotted with x decreasing 	
y = y(Ind);



N = length(X);

if length(x)-length(y) ~= 0,
	disp(' Input data  X   Y  have different dimensions');
	return;
end 

p1=(y(2)-y(1))/(x(2)-x(1));	% first slope
pn=(y(n)-y(n-1))/(x(n)-x(n-1));	% last slope

x1 = x(1);
y1 = y(1);
xn = x(n);
yn = y(n);

if x1 > X(1),
	Y1 = y1 + p1*(X(1)-x1);	% curve extrapolated towards left at [x(1), y(1)];
	y  = [Y1, y];		% vector y is extended at left  
	x  = [X(1), x];		% vector x is extended at left
	n=n+1;
end


if xn < X(N),	
	YN = yn + pn*(X(N)-xn);	% curve extrapolated towards right at [x(n), y(n)]
	y  = [y, YN];
	x  = [x, X(N)];		%  Right-side completion and extrapolation
	n=n+1;
end
lin=0;

if lin==1,
	j=1;
	for i=1:N,
		a=X(i);
		while(a >= x(j) & j < n), 
			j=j+1; 		% j = index of the closest x(j) at right.
		end
		Y(i) = y(j) + (a-x(j))*(y(j)-y(j-1))/(x(j)-x(j-1));
	end
else,
	Y = spline(x, y, X);
end

if plag==1,
	figure(1)
	clg, plot(X,Y,'-r',x,y,'*C5'), pause
end
