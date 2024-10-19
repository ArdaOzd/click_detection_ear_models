function [g,shift,M] = nsgcqwin(fmin,fmax,bins,sr,Ls,min_win)

% NSGCQWIN.M
%---------------------------------------------------------------
% [g,shift,M]=nsgcqwin(fmin,fmax,bins,sr,Ls) creates a set of windows whose
% centers correspond to center frequencies to be
% used for the nonstationary Gabor transform with varying Q-factor. 
%---------------------------------------------------------------
%
% INPUT : fmin ...... Minimum frequency (in Hz)
%	      fmax ...... Maximum frequency (in Hz)
%         bins ...... Vector consisting of the number of bins per octave
%         sr ........ Sampling rate (in Hz)
%         Ls ........ Length of signal (in samples)
%         min_win.... Minimum admissible window length (in samples) 
%
% OUTPUT : g ......... Cell array of window functions.
%          shift ..... Vector of shifts between the center frequencies.
%          M ......... Vector of lengths of the window functions.
%
%---------------------------------------------------------------
% If min_win is not specified, it is set to 4. Note that while large 
% values for min_win might lead to changing Q-factors among the lower
% bins, small values significantly increase time aliasing.
%---------------------------------------------------------------
%
% AUTHOR(s) : Monika Dörfler, Gino Angelo Velasco, Nicki Holighaus, 2011
%
% EXTERNALS : firwin 

% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to 
% Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

if nargin < 6
    min_win = 4;
    if nargin < 5
	error('Not enough input arguments');
    end
end

nf = sr/2; 

if fmax > nf
    fmax = nf; 
end

b = ceil(log2(fmax/fmin))+1; 

if length(bins) == 1; 
    bins = bins*ones(b,1);
elseif length(bins) < b
    if size(bins,1) == 1
        bins=bins.'; 
    end
    bins(find(bins<=0)) = 1;
    bins = [bins ; bins(end)*ones(b-length(bins),1)];
end

fbas = []; 

for kk = 1:length(bins); 
    fbas = [fbas;fmin*2.^(((kk-1)*bins(kk):(kk*bins(kk)-1)).'/bins(kk))]; 
end

% 
if fbas(min(find(fbas>=fmax))) >= nf 
    fbas = fbas(1:max(find(fbas<fmax)));    
else
    fbas = fbas(1:min(find(fbas>=fmax)));
end

lbas = length(fbas);
fbas = [0;fbas];
fbas(lbas+2) = nf;
fbas(lbas+3:2*(lbas+1)) = sr-fbas(lbas+1:-1:2);

fbas = fbas*(Ls/sr);

M = zeros(length(fbas),1);
M(1) = 2*fmin*(Ls/sr);
M(2) = (fbas(2))*(2^(1/bins(1))-2^(-1/bins(1)));
for k = [3:lbas , lbas+2]
M(k ) = (fbas(k+1)-fbas(k-1));
end
M(lbas+1) = (fbas(lbas+1))*(2^(1/bins(end))-2^(-1/bins(end)));
M(lbas+3:2*(lbas+1)) = M(lbas+1:-1:2);
M(end) = M(2);
M = round(6*M);% Set to 6*M obtainm Q=9

for ii = 1:2*(lbas+1);
    
    if M(ii) < min_win; 
        M(ii) = min_win;
    end 
    g{ii} = firwin('hann',M(ii))./sqrt(M(ii));
end

for kk = [1,lbas+2]
    if M(kk) > M(kk+1);    
        g{kk} = ones(M(kk),1);     
        g{kk}((floor(M(kk)/2)-floor(M(kk+1)/2)+1):(floor(M(kk)/2)+...
        ceil(M(kk+1)/2))) = firwin('hann',M(kk+1));
        g{kk} = g{kk}./sqrt(M(kk));
    end
end

rfbas = round(fbas);
shift = [mod(-rfbas(end),Ls); diff(rfbas)];