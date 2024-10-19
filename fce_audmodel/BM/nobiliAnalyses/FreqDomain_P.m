function [Y]=FreqDomain_P(F,AM,plotflag);



if nargin<3
   plotflag=1;
end
if nargin<2
   AM=4e-5;
end
if nargin<1
    F=5400;
end
N=600;
[x,Gs,G,M,stiff,DampSp,undamp,bigamma,wm2] = alldataNL(N);
I=sqrt(-1);
omega=2*pi*F;
omega_2=omega*omega;

Gs=-omega_2*AM*Gs(:);


Bh=I*omega*DampSp;
Bk=diag(stiff);
Gm=-omega_2*(G+M);

A=Gm+Bh+Bk;
Y=-A\Gs;


if plotflag == 1
   cycle=2*pi;
   Ya=abs(Y);
   Yph=unwrap(angle(Y))/cycle;
   figure(1)
   subplot(2,1,1)
     plot(x,Ya,'r')
   subplot(2,1,2)
     plot(x,Yph,'r')
 end