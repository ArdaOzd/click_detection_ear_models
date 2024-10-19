%   ERBLET Computes the ERBlet transform of signal 'f' using 'V' filters per
%   ERB and down-sampling factor 'D' and returns the coefficients in 'coef'
% 
%   Usage:  [coef,g,shift,N,L] = erblet(f,sr,V)
%           [coef,g,shift,N,L] = erblet(f,sr,V,D)
% 
%   ERBLET(f,sr,V) performs the ERBlet analysis of signal f using V
%       filters per ERB and returns the coefficients in coef. In this case
%       the system is painless. The number of time samples in each channel 
%       (parameter N below) equals the supports of the ERBlets in samples. 
%       The corresponding down-sampling factors are L/N_k, k being the 
%       channel index.
% 
%   ERBLET(f,sr,V,D) does the same as ERBLET(f,sr,V) but uses less time
%   samples than the supports of the ERBlets in samples, i.e., the system
%   is not painless. In other words, the painless system is down-sampled by
%   the factor D. The total down-sampling factors are L*D/N_k.
% 
%   Input arguments:
%       f   : time signal to analyze [vector array]
%       sr  : sampling frequency in Hz [integer]
%       V   : number of filters per ERB [integer]
%       D     : down-sampling factor [optional, >1]
%
%   Output argument:
%       coef  : cell-array of ERBlet coefficients
%       g     : cell-array of analysis ERBlets
%       shift : vector array of shifts between center frequencies (in
%               samples)
%       N     : vector array of number of time samples in each channel (N_k)
%       L     : signal length in samples [integer]
% 
%   NOTE: The auditory modeling toolbox (http://amtoolbox.sourceforge.net/)
%       and the linear time-frequency analysis toolbox version 1.2.0 and above
%       (http://ltfat.sourceforge.net/) are required to run this code.
% 
%   AUTHOR(s) : Thibaud Necciari, Nicki Holighaus, 2012
%
%   See also:  demo_erblet, ierblet, nsdgt, insdgt
% 
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to 
% Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

function [coef,g,shift,N,L] = erblet(f,sr,V,varargin)

% Check input parameters
if nargin < 3
  error('%s: Too few input parameters.',upper(mfilename));
end
if ~isnumeric(f)
  error('%s: signal must feature numeric values.',upper(mfilename));
end;
if ~isnumeric(sr) || ~isscalar(sr) || sr<=0
  error('%s: fs must be a positive scalar.',upper(mfilename));
end;
if ~isnumeric(V) || ~isscalar(V) || V<1
  error('%s: V must be a positive scalar.',upper(mfilename));
end;
D = 0;
if ~isempty(varargin)
    if length(varargin) == 1
        D = varargin{1};
    else
        error('%s: Too many input parameters.',upper(mfilename));
    end
end
% Initialization
L = length(f);
F = fft(f)./L;
[g,shift,I] = erbletwin(V,sr,L);% I contains the window supports in samples
% Plot analysis windows
% plot_erblets(g,shift,sr,'Analysis windows');
if D == 0
%     Painless case
%     [A,B] = nsgabframebounds(g,shift,L);% For LTFAT version < 1.4.2
%      [A,B] = nsgabframebounds(g,shift,I);% For LTFAT version 1.4.2
%     fprintf('Frame bound ratio: %f \n', B/A); 
    N = I;% set N=max(I)*ones(size(I)) if a uniform FB is needed.
    coef = nsdgt(F,g,shift,N);
else
%     Down-sampling by D such that N_k = N_painless * D
    N = ceil(I/D);
    coef = nsdgt(F,g,shift,N);
end

% Plot spectrogram
% Because we apply fft twice, coef contains time-reversed versions of signal f
K = (length(g)+2)/2;% Number of positive frequency channels
% coef_disp = cell(K,1);
% for k=1:K
%     coef_disp{k} = flipud(coef{k});
% end
% fc = erbspace(0,sr/2,K);
% figure
% plotfilterbank(coef_disp,L./N(1:K),fc,sr,'audtick','dynrange',60);
% ylim([1 K]), colormap(jet)
% title(['ERBlet coefficients, V=',num2str(V),', K=',num2str(K-1),' (squared modulus, dB)'])

% Compute and display redundancy
red = sum(N)/L;
% fprintf('Redundancy of ERBlet in this case: %f \n',red);
% eof