function [Y]=FreqDomain_A(F,AM,plotflag,Fo,alpha,base);
%function FreqDomain_A(F,AM,plotflag,Fo,alpha,base);
%    The equation in the frequency domain is
%*****************************************************************************************
%    ACTIVE CASE  [-omega_2*(G+M)+omega_i*Bh+Bk]*X+undamp*Y=omega_2*Gs; /-omega_2
%                  Y=[omega_2/(-omega_2+omega_i*Th+Tk)]*X;             /-omega_2
%         [(G+M)+Bh/omega_i+Bk/(-omega_2)-undamp/(-omega_2+omega_i*Th+Tk)]*X=-Gs;
%     MATLAB IMPLEMENTATION  FOR SOLVING SYSTEM OF LINEAR EQUATIONS BY DIVISION OF MATRIX
%
%   PARAMETRS:
%                   ****** BM ******
%                 G       .....   Green function
%                 M       .....   mass 
%                 Bh      .....   damping of BM
%                 Bk      .....   stiffnes of BM
%                 undamp  .....   contribution to BM acceleration from OHCs cell motor

%                   ****** TM ******
%                 Da .... contribution to TM acceleration due to BM acceleration
%                 Th .... damping of TM
%                 Tk .... stiffnes of TM





  if nargin<6, base=2.4531;    end
  if nargin<5, alpha=-6.36;  end
  if nargin<4, Fo=2.11e+004; end
  if nargin<3, plotflag=1;  end
  if nargin<2, AM=4e-5;  end
  if nargin<1, F=2600; end


   N=600;
   [x,Gs,G,M,stiff,DampSp,undamp,bigamma,wm2] = alldataNL(N,Fo,alpha,base);
   Gs=AM*Gs(:);

   I=sqrt(-1);
   omega=2*pi*F;
   omega_2=omega*omega;
   Bh=DampSp./omega;
   Bk=diag(stiff./omega_2);

   Th=I*omega*bigamma;
   Tk=wm2;
   TM=diag(undamp./(omega_2-Th-wm2));
   A=G+M-I*Bh-Bk+TM;
   Y=-A\Gs;
   
   if plotflag == 1
  
     cycle=2*pi;
     Ya=abs(Y); Yph=unwrap(angle(Y))/pi;
    
     figure(1)
      subplot(2,1,1)
        plot(x,Ya,'r')
      subplot(2,1,2)
        plot(x,Yph,'r')
     
   
end
if nargout<1
    Y=[];
end