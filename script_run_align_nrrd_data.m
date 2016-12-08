clear; clc;
%load 139_vol
segs = [1:6];    
studies='all';
%studies={41;98;140;201;366}; % testing - convert 5 random datasets
%volPath = '/home/nduggan/matlab_exper/QIN_experiments/PET_data';
volPath = 'C:\temp\QIN-HEADNECK-JustPET-MODIFIED';
%segBasePath = '/home/nduggan/matlab_exper/QIN_experiments/SEG_data/TCIA_new';
segBasePath = 'C:\temp\QIN-HEADNECK-TCIA-SEG-MODIFIED';
segIndicesPath = 'C:\temp\SEG-Indices';
%nrrdPath = '/home/nduggan/matlab_exper/QIN_experiments/nrrd_data';
nrrdPath = 'C:\Users\nduggan\nrrd_data';
debug = 1;

% load image data
%dicom_directory = '/home/nduggan/matlab_exper/QIN_experiments/PET_data';

studies='all';
%studies={140;157};

%align_nrrd_data(volPath, segBasePath, segIndicesPath, nrrdPath, studies, segs)

align_nrrd_data_lesionbylesion(volPath, segBasePath, segIndicesPath, nrrdPath, studies, segs)