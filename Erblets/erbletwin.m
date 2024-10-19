function [g,shift,M] = erbletwin(V,sr,L)

% ERBLETWIN.M
%---------------------------------------------------------------
% [g,shift,M]=erbletwin(V,sr,L) creates a set of windows for the 
% ERBlet nonstationary Gabor transform. 
%---------------------------------------------------------------
%
% INPUT : V ......... Voices per ERB
%	      sr ........ Sampling rate (in Hz)
%         L ......... Length of signal (in samples)
%
% OUTPUT : g ......... Cell array of window functions.
%          shift ..... Vector of shifts between the center frequencies.
%          M ......... Vector of lengths of the window functions.
% 
%   NOTE: The auditory modeling toolbox (http://amtoolbox.sourceforge.net/)
%       and the linear time-frequency analysis toolbox version 1.2.0 and above
%       (http://ltfat.sourceforge.net/) are required to run this code.
%
% AUTHOR(s) : Thibaud Necciari, Nicki Holighaus, 2012
%
% EXTERNALS : pgauss

% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to 
% Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.


df = sr/L; % frequency resolution in the FFT

fmin = 0;
fmax = sr/2;
Nf = V*ceil(freqtoerb(fmax)-freqtoerb(fmin));% Number of freq. channels
fc = erbspace(fmin,fmax,Nf)';
fc = [fc ; flipud(fc(2:end-1))];% Concatenate "virtual" frequency positions of negative-frequency windows
gamma =  audfiltbw(fc);% ERB scale
g = cell(2*Nf-2,1);% Cell array of analysis windows

% Compute lengths in samples
a1 = round(fc/df);% Positions of center frequencies in samples
a1(Nf+1:end) = L-a1(Nf-1:-1:2)+1;% Extension to negative freq.
shift = [mod(-a1(end),L); diff(a1)];% Hop sizes in samples 
Lwin = 4*round(gamma/df);
% Set all odd Lwin values to even numbers (to avoid indexing errors in windows computation)
ind = find(mod(Lwin,2)~=0);
Lwin(ind) = Lwin(ind)+1;
M = Lwin;

% shift = shift(1:end-1);
% M = M(1:end-1);

% Compute windows for [fmin; SR]
for k=1:2*Nf-2
    gt = pgauss(Lwin(k),'width',round((1/.79)*gamma(k)/df));
    g{k} = normalize(gt,'2');
end

g{1}=1/sqrt(2)*g{1};
g{end}=1/sqrt(2)*g{end};
