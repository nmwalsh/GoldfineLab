function etable=egi_equivtable
% etable=egi_equivtable() returns a 3-column cell array in which the first column is a
% 64-channel EGI designation, second channel is 10-10, third is 128-channel EGI designation
% per text table and headmaps from Vanessa Vogel
%
% a 0 value means equiv does not exist
% more than one 10-10 electrode may be mapped to one EGI electrode, but in
% egi_net_geom, only the first one is used
%
% created from 64_128_correspondences.txt via 64_128_correspondences.xls
%  and adding and modifying several entries based on HydroCelGSN_10-20.pdf
%
%  See also:  EGI_NET_GEOM, EGI_EEGP_DEFOPTS.
etable={
'EGI0034','PZ','EGI0062';...%added by JV
'EGI0039','OZ','EGI0075';... %added by JV
'EGI0000','P3','EGI0052';... %added by JV
'EGI0000','P4','EGI0092';... %added by JV
'EGI0024','T3','EGI0045';... %added by JV (T3=T7)
'EGI0027','T5','EGI0058';... %added by JV (T5=P7)
'EGI0052','T4','EGI0108';... %added by JV (T4=T8)
'EGI0049','T6','EGI0096';... %added by JV (T6=P8)
'EGI0010','FPZ','EGI0015';... %added by JV
'EGI0000','FZ','EGI0011';... %added by JV
'EGI0012','AF3','EGI0023';...
'EGI0002','AF4','EGI0003';...
'EGI0014','AF7','EGI0026';...
'EGI0001','AF8','EGI0002';...
'EGI0007','AFZ','EGI0016';...
'EGI0005','C1','EGI0030';...
'EGI0055','C2','EGI0105';...
'EGI0017','C3','EGI0036';...
'EGI0054','C4','EGI0104';...
'EGI0021','C5','EGI0041';...
'EGI0053','C6','EGI0103';...
'EGI0018','CP1','EGI0037';...
'EGI0043','CP2','EGI0087';...
'EGI0022','CP3','EGI0042';...
'EGI0047','CP4','EGI0093';...
'EGI0025','CP5','EGI0047';...
'EGI0050','CP6','EGI0098';...
'EGI0030','CPZ','EGI0055';...
'EGI0065','CZ','EGI0129';...
'EGI0008','F1','EGI0019';...
'EGI0060','F10','EGI0001';...
'EGI0003','F2','EGI0004';...
'EGI0013','F3','EGI0024';...
'EGI0062','F4','EGI0124';...
'EGI0000','F5','EGI0027';... %added by JV
'EGI0000','F6','EGI0123';... %added by JV
'EGI0015','F7','EGI0033';...
'EGI0061','F8','EGI0122';...
'EGI0019','F9','EGI0032';...
'EGI0009','FC1','EGI0013';...
'EGI0058','FC2','EGI0112';...
'EGI0000','FC3','EGI0029';...%added by JV
'EGI0000','FC4','EGI0111';...%added by JV
'EGI0016','FC5','EGI0028';...
'EGI0057','FC6','EGI0117';...
'EGI0004','FCZ','EGI0006';...
'EGI0011','FP1','EGI0022';...
'EGI0006','FP2','EGI0009';...
'EGI0020','FT7','EGI0034';...
'EGI0056','FT8','EGI0116';...
'EGI0000','FT9','EGI0038';...%added by JV
'EGI0000','FT10','EGI0121';...%added by JV
'EGI0037','O1','EGI0070';...
'EGI0040','O2','EGI0083';...
'EGI0029','P1','EGI0060';... %was 0061, changed by JV
'EGI0048','P10','EGI0095';...%was 0096, changed by JV
'EGI0042','P2','EGI0085';... %was 0078, changed by JV
'EGI0028','P5','EGI0051';... %was 0051, changed by JV
'EGI0046','P6','EGI0097';... % was 0092, changed by JV
'EGI0027','P7','EGI0058';... %was 0057, changed by JV
'EGI0049','P8','EGI0096';... %was 0091, changed by JV
'EGI0031','P9','EGI0064';... %was 0058,changed by JV
'EGI0033','PO3','EGI0067';...
'EGI0041','PO4','EGI0077';...
'EGI0032','PO7','EGI0065';...
'EGI0045','PO8','EGI0090';...
'EGI0038','POZ','EGI0072';...
'EGI0059','T10','EGI0114';...
'EGI0000','T11','EGI0045';...%added by JV
'EGI0000','T12','EGI0108';...%added by JV
'EGI0023','T9','EGI0044';...
'EGI0000','TP9','EGI0057';...%added by JV
'EGI0000','TP10','EGI0100';...%added by JV
'EGI0024','TP7','EGI0046';...
'EGI0052','TP8','EGI0102'};
return