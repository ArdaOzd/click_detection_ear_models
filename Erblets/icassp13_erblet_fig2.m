%   ICASSP13_ERBLET_FIG2 compares the ERBlet, NSG constant-Q, and gammatone
%   filterbank representations as in Fig. 2 of Necciari et al.
% 
%   The following implementations are used:
%   Constant-Q transform: G. A. Velasco, N. Holighaus, M. D�orfler, and T. Grill,
%       "Constructing an invertible constant-Q transform with nonstationary Gabor frames�,
%       in Proceedings of the 14th International Conference on Digital Audio Effects (DAFx-11),
%       Paris, France, September 19�23 2011, pp. 93�99. Code available at: http://www.univie.ac.at/nonstatgab/cqt/
% 
%   Linear gammatone filterbank: V. Hohmann, �Frequency analysis and synthesis using a
%       gammatone filterbank,� Acta Acust. united Ac., vol. 88, no. 3, pp. 433�442, 2002.
%       Code included in the AM Toolbox.
% 
%   FIGURE 1 : ERBlets: Analysis windows
% 
%   FIGURE 2 : ERBlet representation
% 
%   FIGURE 3 : ERBlets: Dual windows
%
%   FIGURE 4 : Constant-Q representation
% 
%   FIGURE 5 : Gammatone representation
% 
%   NOTE: The auditory modeling toolbox (http://amtoolbox.sourceforge.net/)
%       and the linear time-frequency analysis toolbox version 1.2.0 and above
%       (http://ltfat.sourceforge.net/) are required to run this code.
% 
%   AUTHOR(s) : Thibaud Necciari, Nicki Holighaus, 2012
% 
% This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
% To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to 
% Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.

% Load test signal
[f,SR,~] = wavread('Manowar_Heart_chorus-fullband-short.wav');
L = length(f);

% % Compute ERBlet transform
disp('---- ERBlet ----');
V = 3;
[c_erblet,erblets,a,N,~] = erblet(f,SR,V);
% Reconstruction
f_r1 = ierblet(c_erblet,erblets,a,N,L);
rec_err1 = norm(f-f_r1)/norm(f);
fprintf('Relative error of reconstruction using ERBlet: %e \n',rec_err1);


% Compute constant-Q transform
fmin = 50;
fmax = 22050;
bins = 24;
disp('---- NSG constant-Q ----');
[g,shift,M] = nsgcqwin(fmin,fmax,bins,SR,L);
[A,B] = nsgabframebounds(g,shift,L);
fprintf('Frame bound ratio: %f \n', B/A);
fprintf('Redundancy of constant-Q transform in this case: %f \n',sum(M)/L);
gd = nsgabdual(g,shift,M,L);
c_cq = nsdgt(fft(f)./L,g,shift,M);
c_cq_disp2 = nsdgt(fft(f)./L,g,shift,repmat(2048,size(M)));% Uniform filterbank for display only
% Compute center frequencies for the plot
K = numel(g)/2;
c_cq_disp1 = cell(K,1);
centfreqs = zeros(K,1);
for k=2:K-1
   centfreqs(k) = fmin*2^((k-1)/bins); 
end
centfreqs(K) = fmax;
% Restore coefficient matrix to correct orientation for plotting
for k=1:K
    c_cq_disp1{k} = flipud(c_cq{k});
    c_cq_disp2{k} = flipud(c_cq_disp2{k});
end
figure
% plotfb(c_cq_disp(1:K),round(L/2048),centfreqs,SR,'audtick');% Display uniform
%coef_disp,L./N(1:K),fc,sr,'audtick','dynrange',60);
plotfilterbank(c_cq_disp1,round(L./M(1:K)),centfreqs,SR,'audtick','dynrange',60);% Display non-uniform
colormap(jet), %caxis([-60 0])
ylim([1 K])
title(['NSG constant-Q coefficients, ',num2str(bins),' bins/oct., K=',num2str(K),' (squared modulus, dB)'])

% Reconstruction
F_r2 = insdgt(c_cq,gd,shift,L);
F_r2 = F_r2*L;% Re-scale the signal (inverse normalization)
f_r2 = ifft(F_r2);
rec_err2 = norm(f-f_r2)/norm(f);
fprintf('Relative error of reconstruction using NSG constant-Q: %e \n',rec_err2);

% Compute linear gammatone filterbank
base_frequency_hz = 0;
fb_delay_sec = 0.016;
fb_delay_samples = round(fb_delay_sec*SR);
filter_order = 4;
bandwidth_factor = 1.0;
disp('---- Gammatone filterbank ----');
disp('Building analysis filterbank');
analyzer = gfb_analyzer_new(SR, 0, base_frequency_hz, fmax, V, filter_order, bandwidth_factor);
disp(['Building synthesizer for an analysis-synthesis delay of ', ...
      num2str(fb_delay_sec), ' seconds']);
synthesizer = gfb_synthesizer_new(analyzer, fb_delay_sec);
[analyzed_sig, analyzer] = gfb_analyzer_process(analyzer, f);
[f_r3, synthesizer] = gfb_synthesizer_process(synthesizer, analyzed_sig);
fprintf('Redundancy of gammatone filterbank: %f \n',numel(analyzed_sig)/L);
% Plot result
c_gfb = analyzed_sig(:,1:100:end);% Down-sample to reduce the matrix size
Kgfb = size(c_gfb,1);
figure
plotfilterbank(c_gfb',1,analyzer.center_frequencies_hz,SR/100,'audtick','dynrange',60);
ylim([1 Kgfb])
colormap(jet), %caxis([-60 0])
title(['Linear gammatone filterbank, V=',num2str(V),', K=',num2str(Kgfb),' (squared modulus, dB)'])
% Account for filterbank delay (no automatic re-scaling in filterbank implementation)
fp = [f; zeros(fb_delay_samples,1)];
f_r3 = [f_r3(fb_delay_samples+1:end)'; zeros(2*fb_delay_samples,1)];
rec_err3 = norm(fp-f_r3)/norm(fp);
fprintf('Relative error of reconstruction using gammatone filterbank: %e \n',rec_err3);

% eof