function [YA,YDFT,YDFTC]=CochleaRGB_P_DFT(A,F,NC,NS,Ma,Fo,alpha,base)

if nargin < 1,  A=10; end
if nargin < 2,  F=4000; end
if nargin < 3,  NC=20; end
if nargin < 4,  NS=20;end
if nargin < 5,  Ma=2e-2; end
if nargin < 6,  base=2.4531;  end
if nargin < 7,  alpha=-6.36;  end
if nargin <8,   Fo=2.11e+004; end 

  
 

global BMinput Ginv DampSp  stiff bigamma  wm2 undamp N  x 
global om om2 fac  AM

h=5e-6; %time step
ResetAll;
NuSa=10000;
fs=1/h;
AM=db2input(A);

im=sqrt(-1);
im=2*pi*im;
im1=-im*F;
[TW]=FreqDomain_A(F,AM,0);
TWa=abs(TW);TWph=unwrap(angle(TW))/pi;
Ma=1.1*max(TWa);
om=2*pi*F;
om2=-om^2;
tf=NC*(1/F); 
ts=NS*(1/F); 
fac=4*F/NC; %used for scaling of tanh function 
%________________________BM PARAMETERS_____________________________________%
N=600;
[x,BMinput,Ginv,stiff,DampSp,undamp,bigamma,wm2] = alldataRG(N,Fo,alpha,base);



Lp=fix(tf*fs)+NuSa;
t1=(1:Lp)*h;

Sig=-AM*om2.*cos(om*t1);
form=tanh(t1*fac);
Sig=form.*Sig;
%________________________Graphics_________________________________
 y=zeros(size(x));
 H_FIG = figure('Name','TW-BOX MODEL','DoubleBuffer','on','NumberTitle','off');
   H_BM=axes('Position', [.072 .1 .9 .4], 'Box', 'on','XLim',[x(1),x(N)],'YLim',[-Ma,Ma]);
      h_tit1 = text(-1, 0, 'BM displacement');
      set(H_BM, 'Title', h_tit1);
      h_L1 = line('XData',x,'YData',zeros(N,1),'Color', 'r');
      h_L2 = line('XData',x,'YData',TWa,'Color', 'k');
             xlabel('Distance from stapes [cm]');
   Ma1=-AM*om2;       
   H_SIG =	axes('Box', 'on','Position',[0.072,0.675,0.9,0.25]);
   set(H_SIG,'Xlim', [0, t1(Lp)], 'Ylim', [-Ma1, Ma1]);
   h_tit2 = text(-1, 0, ['Input signal-->F:=',num2str(F), ' [Hz]'],'Tag','h_tit2');
   h_xlbl2 = text(-1,0, 'Time [sec]', 'Tag','h_xlbl2');
   h_ylbl2 = text(-1,0, 'Amplitude', 'Tag', 'h_ylbl2');
   set(H_SIG, 'Title', h_tit2,'XLabel', h_xlbl2, 'YLabel',h_ylbl2);
   h_L2 = line('XData',t1,'YData',Sig,'Erasemode','none','Color', 'b');
   h_L0=line('Xdata', [t1(1), t1(1)], 'Ydata', [-Ma1, Ma1]);   
   set(h_L0, 'Color', 'r');
   drawnow;
 
 %_________________________RUNGE KUTTA____________________________________%
 n_c=1;             %statistic for graphics 
 n_c1=1;
 t0=0;              %start time
 y0=zeros(4*N,1);   %initial conditions
 y=y0(:);
 t=t0;
 neq = length(y);
 %------------------------------------------- 
 pow = 1/5;
 A = [1/5; 3/10; 4/5; 8/9; 1; 1];
 B = [
    1/5         3/40    44/45   19372/6561      9017/3168       35/384
    0           9/40    -56/15  -25360/2187     -355/33         0
    0           0       32/9    64448/6561      46732/5247      500/1113
    0           0       0       -212/729        49/176          125/192
    0           0       0       0               -5103/18656     -2187/6784
    0           0       0       0               0               11/84
    ];

F = zeros(neq,6);


hA = h * A;
hB = h * B;
%____________________Main routine___________________________________%
YA=zeros(N,1);
YDFT=zeros(N,1);
YDFTC=zeros(N,1);
count=0;

while count<NuSa    
                             
       F(:,1)=activeC(t,y);
       F(:,2) = activeC(t + hA(1), y + F*hB(:,1));
       F(:,3) = activeC(t + hA(2), y + F*hB(:,2));
       F(:,4) = activeC(t + hA(3), y + F*hB(:,3));
       F(:,5) = activeC(t + hA(4), y + F*hB(:,4));
       F(:,6) = activeC(t + hA(5), y + F*hB(:,5));
       
       t = t + hA(6);
       y = y + F*hB(:,6);
       
       
       if n_c==4
           set(h_L1,'Ydata',y(1:N));
           set(h_L0, 'Xdata', [t, t], ...'Ydata', [-maxsig, maxsig],...
             'Color', 'r');    
           n_c=0;
           drawnow; 
           if count~=0
               axes(H_BM);
               title(num2str(count));
           end
       end
       n_c=n_c+1;
        if t>ts
            YA=max(YA,abs(y(1:N)));
            YDFT=YDFT+y(1:N)*exp(im1*t);
%             Ycut=undamp.*nonlin3(y(2*N+1:3*N));
%             YDFTC=YDFTC+Ycut*exp(im1*t);
            count=count+1;
        end
                
end
close(H_FIG);
YDFT=(2*YDFT)/(NuSa);
YDFTC=(2*YDFTC)/(NuSa);
count
if nargout<1
   YDFTa=abs(YDFT);YDFTph=unwrap(angle(YDFT))/pi;
    figure(1)
     clf
      subplot(2,1,1)
       plot(x,YDFTa,'r',x,TWa,'b')
      subplot(2,1,2) 
       plot(x,YDFTph,'r',x,TWph,'b')
        YA=[];YDFT=[];YDFTC=[];
    
end
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%----------------------------UTILITY----------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%-----------------------------------------------------------%%     
function ResetAll

 global BMinput Ginv Damp  stiff  x  
 
 BMinput=[];
 Ginv=[];
 Damp=[];
 stiff=[];
 x=[];
%---------------------------------------
function dXdV = passiveC(t,XV)

  global BMinput Ginv DampSp  stiff  N  x 
  global om om2 fac AM
  
   inp=tanh(t*fac)*om2*AM*cos(om*t);
   X=XV(1:N);
   V=XV(N+1:2*N);

   dV = BMinput*inp-Ginv*(stiff.*X + DampSp*V); 

   dXdV=[V
          dV];

%---------------------------------------
 function dXdVdYdW = activeC(t,XVYW)

global BMinput Ginv DampSp  stiff bigamma  wm2 undamp N  x 
global om om2 fac AM
 
   inp=tanh(t*fac)*om2*AM*cos(om*t);

    X=XVYW(1:N);
    V=XVYW(N+1:2*N);
    Y=XVYW(2*N+1:3*N);
    W=XVYW(3*N+1:4*N);


    Ycut=nonlin(Y); %nonlinear model
    %Ycut=Y; %linear model
    dV = BMinput*inp-Ginv*(stiff.*X + DampSp*V+ undamp.*Ycut); 
    dXdVdYdW=[ V
               dV
                W
                -bigamma.*W - wm2.*Y - dV];


 
