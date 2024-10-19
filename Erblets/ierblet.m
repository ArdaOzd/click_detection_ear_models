%   IERBLET Computes the inverse ERBlet transform
% 
%   Usage:  f_r = ierblet(coef,g,shift,N,L)
% 
%   IERBLET(coef,g,shift,N,L) inverses the ERBlet transform provided in
%       'coef' and reconstructs the signal 'f_r'. If the system is painless 
%       then duals are easily computed by inverting the frame operator. If
%       the system is not painless then iterative reconstrcution is achieved 
%       using a CG algorithm.
% 
%   Input arguments:
%       coef  : cell-array of ERBlet coefficients
%       g     : cell-array of analysis ERBlets
%       shift : vector array of shifts between center frequencies (in
%               samples)
%       N     : vector array of number of time samples in each channel (N_k)
%       L     : signal length in samples [integer]
%
%   Output argument:
%       f_r   : reconstructed and re-scaled time signal
% 
%   NOTE: The auditory modeling toolbox (http://amtoolbox.sourceforge.net/)
%       and the linear time-frequency analysis toolbox version 1.2.0 and above
%       (http://ltfat.sourceforge.net/) are required to run this code.
% 
% AUTHOR(s) : Thibaud Necciari, Nicki Holighaus, 2012
%
%   See also:  demo_erblet, erblet, frame, nsdgt, insdgt
% 
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to 
% Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

function f_r = ierblet(coef,g,shift,N,L)

% Check input parameters
if nargin < 5
  error('%s: Too few input parameters.',upper(mfilename));
end
if ~iscell(coef)
  error('%s: coefficients must be provided as a cell array.',upper(mfilename));
end;
if ~iscell(g)
  error('%s: windows must be provided as a cell array.',upper(mfilename));
end;
if ~isnumeric(shift) || ~isnumeric(N) || ~isnumeric(L)
  error('%s: at least one input argument is not numeric.',upper(mfilename));
end;

if nargin > 5
        error('%s: Too many input parameters.',upper(mfilename));
end

if all(cellfun(@length,g) <= N)
%     Painless case
    gd = nsgabdual(g,shift,N,L);
    % Plot dual windows
%     plot_erblets(gd,shift,'Dual windows');
    F_r = insdgt(coef,gd,shift,L);
    F_r = F_r*L;% Re-scale the signal (inverse normalization)
    f_r = ifft(F_r);
else
%     Iterative reconstruction
    NSG_frame = frame('nsdgt',g,shift,N);
    F_r = frsyniter(NSG_frame,framenative2coef(NSG_frame,coef),'cg','tol',10^-15);
    F_r = F_r*L;% Re-scale the signal (inverse normalization)
    f_r = ifft(F_r);
end
% eof