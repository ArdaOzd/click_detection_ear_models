%   AUTHOR(s) : Thibaud Necciari, 2012
% 
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to 
% Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
% 

function plot_erblets(g,shift,varargin)

%   Usage:  plot_erblets(g,shift)
%           plot_erblets(g,shift,sr)
%           plot_erblets(g,shift,wintyp)
%           plot_erblets(g,shift,sr,wintyp)
% 
% Optional arguments are:
%   sr     : sampling rate in Hz
%   wintyp : string that specifies which windows are plotted (for display only)
%       'analysis'
%       'duals'

wintyp = 'ERBlets';
sr = 0;
if ~isempty(varargin)
    if length(varargin) == 1
        tmp = varargin{1};
        if ischar(tmp)
            wintyp = {wintyp; tmp};
        end
        if isnumeric(tmp)
            sr = tmp;
        end
    elseif length(varargin) == 2
        sr = varargin{1};
        tmp = varargin{2};
        if ischar(tmp)
            wintyp = {wintyp; tmp};
        end
    else
        error('%s: Too many input parameters.',upper(mfilename));
    end
end
K = length(g);
a1 = cumsum(shift)-shift(1);
xaxistxt = 'Frequency (Hz)';
if ~isscalar(sr) || sr <= 0
    sr = a1(end);
    xaxistxt = 'Frequency index';
end
df = sr/a1(end);
figure
color = ['b', 'r'];
for ii = 1:K
    j = rem(ii,2)+1;
    plot((a1(ii)-1-floor(length(g{ii})/2)+(1:length(g{ii}))).*df, fftshift(g{ii}), color(j));
    hold on;
end
hold off;
xlabel(xaxistxt), ylabel('Amplitude'), title(wintyp)
