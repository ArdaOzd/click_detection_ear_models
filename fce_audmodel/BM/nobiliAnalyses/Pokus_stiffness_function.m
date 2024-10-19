
N = 300;
x = gaussgrid(N,0);





x = x(:); 		
dx=[x(1);x(2:N)-x(1:N-1)]; 
expk = -3.6*log(10); 	% Stiffness exponent  (Base E) (default -3.6*log(10))
ko = 2e+3;		  % Kg/(BETA*sec^2) , BETA = BM length taken as lenght unit
k1= ko*exp(expk*x);
k1=k1(:);
stiff=[k1(1)-ko; k1(2:N)-k1(1:N-1)]./(expk*dx); 


expk2 = -4.9*log(10); 	% Stiffness exponent  (Base E) (default -3.6*log(10))
ko2 = 15e+3;		  % Kg/(BETA*sec^2) , BETA = BM length taken as lenght unit
k12= ko2*exp(expk2*x);
k12=k12(:);
stiff2=[k12(1)-ko; k12(2:N)-k12(1:N-1)]./(expk2*dx); 


figure;
semilogy(x,stiff,x,stiff2,x,min(stiff,stiff2));