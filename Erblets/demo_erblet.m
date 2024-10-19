%   DEMO_ERBLET provides an example for computing the ERBlet transform of
%       a signal. The defaut parameters are:
% 
%       Fmin = 0 Hz,
%       Fmax = sr/2 (sr = sampling frequency),
%       V = 1 filter/ERB,
%       D = 0 (painless system) and D = 3 (non-painless).
%
%   This script achieves the full ERBlet analysis-synthesis of a test signal.
%   It computes the ERBlets (analysis + duals), the ERBlet coefficients, 
%   and reconstruct the signal.
%
%   FIGURE 1 time-frequency representation "painless" (squared modulus of ERBlet coefficients in dB)
% 
%   FIGURE 2 anaylsis ERBlets (identical for both painless and non-painless
%   systems)
% 
%   FIGURE 3 dual ERBlets "painless"
% 
%   FIGURE 4 time-frequency representation "non-painless" (squared modulus of ERBlet coefficients in dB)
% 
%   NOTE: The auditory modeling toolbox (http://amtoolbox.sourceforge.net/)
%       and the linear time-frequency analysis toolbox version 1.2.0 and above
%       (http://ltfat.sourceforge.net/) are required to run this code.
%
%   SEE ALSO:  ERBLET, IERBLET, NSDGT, INSDGT
% 
%   AUTHOR(s) : Thibaud Necciari, Nicki Holighaus, 2012
% 
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to 
% Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
clear all, close all, clc
filename = 'pulse_44100.wav';
[f,SR] = audioread(filename);
f = f(1:35280);
f = f(:, 1);
L = length(f);
V = 1;
D = 3;

%% Painless case
disp('---- ERBlet transform: Painless case. ----');
% Computes and displays windows and ERBlet transform
disp('---- Analysis. ----');
[c1,erblets1,shift1,N1,~] = erblet(f,SR,V);
% plot_erblets(erblets1,shift1,SR,'Analysis windows');
disp('---- Synthesis. ----');
f_r1 = ierblet(c1,erblets1,shift1,N1,L);
% Print relative error of reconstruction.
rec_err1 = norm(f-f_r1)/norm(f);
fprintf('Relative error of reconstruction: %e \n',rec_err1);

% return

%% Non-painless case
disp('---- ERBlet transform: Non-painless case. ----');
% Computes windows and ERBlet transform
disp('---- Analysis. ----');
[c2,erblets2,shift2,N2,~] = erblet(f,SR,V,D);
% return
disp('---- Iterative Synthesis. ----');
f_r2 = ierblet(c2,erblets2,shift2,N2,L);

% Print relative error of reconstruction.
rec_err2 = norm(f-f_r2)/norm(f);
fprintf('Relative error of reconstruction: %e \n',rec_err2);

% eof