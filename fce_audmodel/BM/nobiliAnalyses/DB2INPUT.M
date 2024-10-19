function input = db2input(dB);

%	rescales dB SPL into corresponding input values for human cochlea  



AMo=3e-6;
input = AMo*10.^(dB/20);
