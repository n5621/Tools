function align_nrrd_data_lesionbylesion(volPath, segBasePath, segIndicesBasePath, nrrdBasePath, studies, segs)

% function [ output_args ] = align_nrrd_data(volPath, segBasePath, segIndicesBasePath, nrrdBasePath, studies, segs)
% Function converts segmentations multiframe images stored as 
% nrrd files to aligned segmentations saved as MAT-files.
% NOTE: This version of the file DOES NOT split out segmentations on a
% lesion-by-lesion basis.
% Input: 
%      nrrd_path - a path to a directory of TCIA studies, which
%                  each contain subdirectories containing nrrd files 
%                  for each manual segmentation and 
%      destpath -  path where aligned segmentations will be stored.
%
%      segselection - can be a string 'all'; meaning all trials (all users) or numeric i.e. a matrix or scalar
%
%      studies - can be string: 'all' meaning all data in volpath or
%                 numeric - i.e. a vector or scalar referring to a list of
%                 studies or 1 specific study:

if isunix
    addpath(genpath('/home/nduggan/matlab_exper/QIN_experiments/Qin_tools'));
else
    addpath(genpath('C:\Users\nduggan\Documents\matlab_exper\QIN_experiments\Qin_tools'));
end
%addpath(genpath('../code_wc'));

% 
% load 139_vol
% segs = [1:6];    
% studies=139;
% volPath = '/home/nduggan/matlab_exper/QIN_experiments/PET_data';
% segBasePath = '/home/nduggan/matlab_exper/QIN_experiments/SEG_data/TCIA_new';
% segIndicesBasePath = '/home/nduggan/matlab_exper/QIN_experiments/SEG_data/';
% nrrdBasePath = '/home/nduggan/matlab_exper/QIN_experiments/nrrd_nrrdpathdata';
 debug = 0;
% 
% % load image data
% dicom_directory = '/home/nduggan/matlab_exper/QIN_experiments/PET_data';
  dicom_fields = {...
        'Filename',...
        'Height', ...
        'Width', ...
        'Rows',...
        'Columns', ...
        'PixelSpacing',...
        'SliceThickness',...
        'SliceLocation',...
        'SpacingBetweenSlices'...
        'ImagePositionPatient',...
        'ImageOrientationPatient',...
        'FrameOfReferenceUID',...
        'SOPInstanceUID',...
        };



% check studynum:
if ischar(studies)
    studies = dir(segBasePath);
    studies = {studies.name}.';
    Studyindices= find(~cellfun(@isempty,cellfun(@(x) find(~isequal(x,'.')& ~isequal(x,'..')&~ isequal(x,'readme.txt')),studies,'UniformOutput',false))); % remove the '.',  '..' files, and 'readme.txt''
    studies = studies(Studyindices); % remove the '.' and '..' files
    number_studies = length(studies);
    start_study_idx= 1;
else
    number_studies = length(studies);
    start_study_idx = 1;
end

% check segs
if ischar(segs)
    number_segs= 6;
    start_seg_idx= 1;
else
    number_segs= length(segs);
    start_seg_idx = segs(1);
end


 
 for i=start_study_idx:number_studies
     
     if ischar(studies{1,1})
        study_string = studies{i,1};
     else
         study_string = sprintf('QIN-HEADNECK-01-0%03d',studies{i,1});
     end
     
%      if number_studies == length(studies);
%         dicom_directory = [volPath filesep studies{i}];
%      else
         dicom_directory = [volPath filesep study_string];
    % end
     
     % find directory with 'hasSEG' suffix
     dicom_directory_contents = dir(dicom_directory);
     dicom_directory_contents = {dicom_directory_contents.name}.';
     % find index of cell containing 'hasSEG'
     relevantIdx= find(~cellfun(@isempty,cellfun(@(x) strfind(x,'hasSEG'),dicom_directory_contents,'UniformOutput',false))); % remove the '.',  '..' files, and 'readme.txt''
     dicom_directory = [volPath filesep study_string filesep cell2mat(dicom_directory_contents(relevantIdx))];
     
[vol, slice_data, image_meta_data] = ...
        dicom23Dmodified(dicom_directory, dicom_fields);
    segPath = [segBasePath filesep study_string filesep 'Original'];
    segdirectory = dir(segPath); %get files matching pattern
    segdirectories = {segdirectory.name}.'; %get only directories names
    
    format = 'User%dtrial%d';
    data= cellfun(@(x) textscan(x,format,...
    'CollectOutput',1),segdirectories); % returns cell array of vectors which are empty if string does not contain characters in 'User%dtrial%d' (it also returns 'SemiAuto')
    segindices= find(~cellfun(@isempty,cellfun(@(x) find(~isempty(x) & all(x,2)),data,'UniformOutput',false))); % find indices of cells matching 'format' exactly (i.e. exclude 'SemiAuto')

    % find out how many lesions have been segmented
    nrrdpathcontents = dir([nrrdBasePath filesep study_string filesep segdirectories{segindices(segs(1)),1}]);
    nrrdpathcontents = {nrrdpathcontents.name}.';
    relindices= find(~cellfun(@isempty,cellfun(@(x) find(~isequal(x,'.')& ~isequal(x,'..')&~ isequal(x,'readme.txt') & strfind(x,'.nrrd')),nrrdpathcontents,'UniformOutput',false))); % remove the '.',  '..' files, and 'readme.txt'' % find indices of cells matching 'format' exactly (i.e. exclude 'SemiAuto')
    nrrdpathcontents = nrrdpathcontents(relindices);
    nrrdpathcontents = sort_nat(nrrdpathcontents);
    number_lesions = length(nrrdpathcontents);
    
    
    for j=1:number_segs 
        nrrdpath = [nrrdBasePath filesep study_string filesep segdirectories{segindices(segs(j)),1} ];
        
      for k=1:number_lesions
        
        
                  
        
        % load nrrd object (for meta data)   
        [segData, nrrdmeta] = nrrdread([nrrdpath filesep nrrdpathcontents{k,1}]);

        % consolidate it
        %segData = false(size(nrrddata));
        %segData  = consolidateNRRD(nrrdpath);

   
        % %--------------- Main part of code: -------------------------%%
        seg = false(size(vol));

         % extract ordered list of 'z displacements' from  image volume( for information 
         % See Image Position Patient Tag (0020,0032)
        SortedImagePositionPatient = {slice_data.ImagePositionPatient}.';
        z_displacement = cellfun(@(v) v(3), SortedImagePositionPatient);

        % find z displacement of first and last frame in nrrd data
        zDisplaceSlice1nnrd = findzdisplaceFrame1nrrd(nrrdmeta);
        [zDisplaceFrame1,zDisplaceFrameZ]  = findzdisplaceFrame1nrrd(nrrdmeta);

        % find the indices of the corresponding z displacements in Volume data:
        [val, Idx_1] = min(abs(abs(z_displacement) - abs(zDisplaceFrame1)));

        [val, Idx_N] = min(abs(abs(z_displacement) - abs(zDisplaceFrameZ)));

        seg(:,:,Idx_1:Idx_1 + size(segData,3)-1) = segData; % confirm that this is correct
        
        % -- save data -- %
        SegIndices = [Idx_1,Idx_1 + size(segData,3)-1];
        SEGdirname = segdirectories{segindices(segs(j))};
        alignedSegPath = [segBasePath filesep study_string filesep 'Aligned' filesep 'MAT-files' filesep 'SplitOut' filesep SEGdirname ];
        if ~exist(alignedSegPath,'dir')
            mkdir(alignedSegPath)
        end
        SEGfilename = sprintf('Seg%d',k);
        
        
        save([alignedSegPath filesep SEGfilename],'seg');
        
        % save indices:
        if debug==1
            alignedSegIndicesPath = [segIndicesBasePath filesep 'SEGIndices' filesep study_string];
            if ~exist(alignedSegIndicesPath,'dir')
                mkdir(alignedSegIndicesPath)
            end
            SEGindicesfilename = [segdirectories{segindices(segs(j))}];
            save([alignedSegIndicesPath filesep SEGindicesfilename],'SegIndices');
        end
        
%         % dicomwrite(alignedSeg, 'alignedSegcase139User1trial1');
%         % Test:
%         figuretitle = 'AXIAL';
%         directions = {'R';'L';'A';'P'};
%         for i=Idx_1:Idx_N
%             drawboundary_qin_mod(vol(:,:,i), seg(:,:,i),'directions',directions,'figuretitle',figuretitle)
%         end

      end
    end


 end
