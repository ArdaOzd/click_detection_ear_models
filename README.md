# click_detection_ear_models

Data & Matlab codes for 
"Performance Evaluation of Perceptible Impulsive Noise Detection Methods based on Auditory Models"

Paper submitted to EURASIP Journal on Audio, Speech, and Music Processing, 2024

Authors: Arda Ozdogru, Frantisek Rund, Karel Fliegel 
FEE CTU 2024

Can be found at https://mmtg.fel.cvut.cz/click-detection/
MATLAB Version: v9.14 (R2023a)
 
computer specifications: on Linux machines. The codes were run on a distributed computing infrastructure managed by MetaCentrum Virtual Organization
            https://metavo.metacentrum.cz/en/index.html

Some codes and materials are parts of JAES21:
F. Rund, V. Vencovsk˝, and M. Semansk˝, An Evaluation of Click Detection Algorithms Against the Results of Listening Tests,î J. Audio Eng. Soc., vol. 69, no. 7/8, pp. 586-593, (2021 July.). https://doi.org/10.17743/jaes.2021.0020


Content of the folder (files and folders marked by ! are parts of other toolboxes and should be downloaded as specified):

--- experiment files ---

* bash_par/             contains the bash codes to run the related algorithms on Linux server in parallel (FOR PARALLEL COMPUTING).
* par_results/             results of the parallel computing. (.txt files are just for debugging)
* runX_lthY_BM_0.m files    X = randomization number, Y = listening threshold, Z => 1 = Vencovsky's model, 0 = others (was necessary for timing)
* mX / mx_BM .m files        codes called by the above codes.
* test_run.m             to run after the training. needs to have par_results folder complete
* test_run.mat             workspace after the test_run.m is completed. (final results are contained here) Ap error plot generation is in the second part of the code.
* other_analysis.m        Analysis codes required for generated plots, ROC curve, logarithmic time comparison and ERBletHF parameter sweep results.
* best_param_extract_heatmap.py    creates a heatmap of optimum parameters resulting in best A' scores over the experiments


--- common files --- 
* ScratchStimuliTest/           folder with the 90 wav files (44.1 kHz, 16 bit), 800 ms long,  provided by gzmedia company. Taken from 3 vinyls, containing clicks due to manufacturing.   - part of JAES21

* subj_results.mat              results of the listening tests as .mat file (Matlab)  - part of JAES21
 
* IR/                           folder with the "impulse responses" of the used hearing models - response of the model to a click
* ! Aud_tbx/                    M. Slaney Auditory Toolbox to download from https://engineering.purdue.edu/~malcolm/interval/1998-010/ (tested at ver 2) - necessary for Lyon's and Senef's models based algorithms
 
* evaluation.m                  Matlab function for calculation of the comparison criteria (depreciated)
 
--- DRNL ---
* JAES_DRNL.m                   Matlab function for click detection using DRNL filter bank ear model based algorithm
* ! DRNL_MAP1_14                Matlab function for DRNL model, part of MAP toolbox, should be downloaded from https://github.com/rmeddis/MAP 
* run_detect_DRNL.m             Matlab script - run detection on the set of stimuli and compare it with the subjective results.
* Test_DRNL.m                   Matlab script - run run_detect_DRNL.m 10x to calculate average time elapsed for DRNL filter bank ear model based algorithm

--- Lyon --- 
* JAES_lyon.m           Matlab function for click detection using Lyon's model based algorithm  (requires M. Slaney Auditory Toolbox in folder Aud_tbx)
* ! Aud_tbx/                    M. Slaney Auditory Toolbox to download from https://engineering.purdue.edu/~malcolm/interval/1998-010/ (tested at ver 2) - necessary for Lyon's and Senef's models based algorithms
* run_detect_Lyon.m     Matlab script - run detection on the set of stimuli and compare it with the subjective results.                
* Test_Lyon.m           Matlab script - run run_detect_Lyon.m 10x to calculate average time elapsed for Lyon's ear model based algorithm  

--- Seneff ---
* JAES_seneff.m         Matlab function for click detection using Seneff's model based algorithm  (requires M. Slaney Auditory Toolbox in folder Aud_tbx)
* ! Aud_tbx/                    M. Slaney Auditory Toolbox to download from https://engineering.purdue.edu/~malcolm/interval/1998-010/ (tested at ver 2) - necessary for Lyon's and Senef's models based algorithms
* run_detect_Seneff.m   Matlab script - run detection on the set of stimuli and compare it with the subjective results. 
* Test_Seneff.m         Matlab script - run run_detect_Seneff.m 10x to calculate average time elapsed for Seneff's ear model based algorithm 

--- Erblet ---
* JAES_erblet.m         Matlab function for click detection using Erblet based algorithm  (requires Erblets functions and AMT installed)
* ! Erblets/            Folder with Matlab functions for Erblet transform to download from http://www.kfs.oeaw.ac.at/ICASSP2013_ERBlets - Need also AMT (https://www.amtoolbox.org/ , tested full 1.0.0 and 0.9.9 - ) - installed somewhere and then run amt_start.m
* run_detect_erblet.m   Matlab script - run detection on the set of stimuli and compare it with the subjective results.
* Test_erblet.m         Matlab script - run run_detect_erblet.m 10x to calculate average time elapsed for Erblet based algorithm 


* runAnalysisAR_JAES_f.m      Matlab script - testing of the AR model based click detection method using the samples in * ScratchStimuliTest folder, including the performance (hits, false alarms, d') calculation - JAES21
* fce_AR/             folder with functions for AR model based click detection method implementation JAES21

* runAnalysismatch_JAES_f.m   Matlab script - testing of the matched filter based click detection method using the samples in ScratchStimuliTest folder, including the performance (hits, false alarms, d') calculation  JAES21
* fce_matched/           folder with functions for matched filter based click detection method implementation JAES21

* runAnalysisWavelet_JAES_f.m Matlab script - testing of the wavelet transform based click detection method using the samples in ScratchStimuliTest folder, including the performance (hits, false alarms, d') calculation JAES21
* fce_wavelet/       folder with functions for wavelet transform based click detection method implementation and evaluation. JAES21

* runBMmodelTEST_JAES_2.m     Matlab script - testing of the Vencovsky's peripheral-ear model based click detection method using the samples in ScratchStimuliTest folder, including the performance (hits, false alarms, d') calculation JAES21
* fce_audmodel/              folder with the functions for pheripheral-ear model click detection. JAES21


