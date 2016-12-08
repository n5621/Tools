function [zDisplaceFrame1,zDisplaceFrameZ]  = findzdisplaceFrame1nrrd(nrrdmeta)
% function [zDisplaceFrame1,zDisplaceFrameZ]  = findzdisplaceFrame1nrrd(nrrdmeta)

% Finds the z displacement corresponding to the first and last frame of the
% multiframe object nrrdmeta

format = '(%f, %f, %f) (%f, %f, %f) (%f, %f, %f)';
A = textscan(nrrdmeta.spacedirections, format); 

matrix = [A{1,1}, A{1,4}, A{1,7} ;  A{1,2}, A{1,5}, A{1,8}; A{1,3}, A{1,6}, A{1,9}];

format = '(%f, %f, %f)';
A = textscan(nrrdmeta.spaceorigin, format);
B = [matrix, [A{1,1}; A{1,2}; A{1,3}]];
B = [B; [0,0,0,1]];
ImagePositionPatientslice1 = B*[0;0;0;1];
zDisplaceFrame1 = ImagePositionPatientslice1(3,1);


format = '%f %f %f';
SegDims = textscan(nrrdmeta.sizes, format);
ImagePositionPatientsliceZ  = B*[0;0;SegDims{1,3}-1;1];
zDisplaceFrameZ = ImagePositionPatientsliceZ(3,1);

end

