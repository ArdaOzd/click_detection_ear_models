%   ICASSP13_ERBLET_FIG1 computes the iterative NSG conjugate gradients reconstruction 
%   and extended convergence plots corresponding to Fig. 1 of Necciari et al.
% 
%   NOTE: The auditory modeling toolbox (http://amtoolbox.sourceforge.net/)
%       and the linear time-frequency analysis toolbox version 1.2.0 and above
%       (http://ltfat.sourceforge.net/) are required to run this code.
% 
%   AUTHOR(s) : Nicki Holighaus, 2012
% 
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to 
% Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

clc
disp('This might take a few minutes');

fac = [8/9, 2/3, 1/2, 1/3, 3/11]; %Set downsampling factors

% Initialize variables

dat = cell(5,2);
red = zeros(5,1);
time = zeros(5,2);
rel_err = zeros(5,2);

% Load test signal
[f,SR,~] = wavread('Manowar_Heart_chorus-fullband-short.wav');
L = length(f);

% Alternatively, generate a random test signal 
% L = 263614;
% f = rand(L,1)+i*rand(L,1);

norm_f = norm(f,2);

% Compute reconstruction for all cases

for jj = 0:1    % 0: no preconditioning, 1: with preconditioning
    for kk = 1:5    % cases ordered by redundancy
        
        [g,shift,N] = erbletwin(1,44100,L);
        if kk == 1
            red0 = sum(N)/length(f);
        end
        N = round(fac(kk)*N); % Use only a factor of the atoms necessary for 'painless'
        red(kk)=sum(N)/length(f);
        coef = nsgt(f,g,shift,N); % Compute the coefficients
        NSG_frame = frame('nsdgt',g,shift,N);
        
        tic; %  Start timing
        if jj > 0 % Conjugate gradients reconstruction 
            [x,rr,it,dat{kk,jj+1}] = frsyniter(NSG_frame,coef,'pcg','tol',10^-15);
        else
            [x,rr,it,dat{kk,jj+1}] = frsyniter(NSG_frame,coef,'cg','tol',10^-15);
        end
        rel_err(kk,jj+1) = norm(x-f,2)/norm_f; % Relative reconstruction error
        dat{kk,jj+1} = dat{kk,jj+1}/norm_f; % Absolute to relative residual norm
        time(kk,jj+1) = toc; % Stop timing
    end
end
    
% Convergence plot without preconditioning

figure(1);
hold off
semilogy([0:length(dat{1,1})],[1;dat{1,1}],'k-x')
axis([0,5*ceil(length(dat{5,1})/5),10^-15,1])
hold on
semilogy([0:length(dat{2,1})],[1;dat{2,1}],'k-s')
semilogy([0:length(dat{3,1})],[1;dat{3,1}],'k-*')
semilogy([0:length(dat{4,1})],[1;dat{4,1}],'k-o')
semilogy([0:length(dat{5,1})],[1;dat{5,1}],'k-v')
legend(['Redundancy ',num2str(red(1),3)],['Redundancy ',num2str(red(2),3)],...
     ['Redundancy ',num2str(red(3),3)],['Redundancy ',num2str(red(4),3)],...
     ['Redundancy ',num2str(red(5),3)]);
title('Convergence of the CG iteration (no preconditioning)');
ylabel('Relative reconstruction error');
xlabel('Number of iterations');
shg

% Convergence plot with preconditioning

figure(2);
hold off
semilogy([0:length(dat{1,2})],[1;dat{1,2}],'k-x')
axis([0,5*ceil(length(dat{5,1})/5),10^-15,1])
hold on
semilogy([0:length(dat{2,2})],[1;dat{2,2}],'k-s')
semilogy([0:length(dat{3,2})],[1;dat{3,2}],'k-*')
semilogy([0:length(dat{4,2})],[1;dat{4,2}],'k-o')
semilogy([0:length(dat{5,2})],[1;dat{5,2}],'k-v')
legend(['Redundancy ',num2str(red(1),3)],['Redundancy ',num2str(red(2),3)],...
     ['Redundancy ',num2str(red(3),3)],['Redundancy ',num2str(red(4),3)],...
     ['Redundancy ',num2str(red(5),3)]);
title('Convergence of the CG iteration (with preconditioning)');
ylabel('Relative reconstruction error');
xlabel('Number of iterations');
shg

% Print computation times
disp('Computation time')
disp('(Columns: without/with preconditioning)')
disp('(Rows: Redundancies from high to low)')
time

% Print relative errors
disp('Relative error')
disp('(Columns: without/with preconditioning)')
disp('(Rows: Redundancies from high to low)')
rel_err