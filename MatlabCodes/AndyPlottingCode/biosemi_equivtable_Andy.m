function etable=biosemi_equivtable_bAndy

%3/6/14 bAMG - modified the EGI one to work with the biosemi based on info
%supplied by Kristen
%9/3/13 bAMG
%based on JVs egi_equivtable. First column is EGI64, then second column is
%the output names, third column is EGI128, and fourth column is EGI33 that
%I came up with. Note that I have not checked EGI64 and EGI129 columns for
%accuracy with the way I import the data.

%%
etable={'bA1','Cz';...
    'bA3','CPz';...
    'bA10','PO7';...
    'bA15','O1';...
    'bA19','Pz';...
    'bA21','POz';...
    'bA23','Oz';...
    'bA25','Iz';...
    'bA28','O2';...
    'bB7','PO8';...
    'bB11','P8';...
    'bB14','TP8';...
    'bB20','C2';...
    'bB22','C4';...
    'bB24','C6';...
    'bB26','T8';...
    'bB27','FT8';...
    'bC7','F8';...
    'bC8','AF8';...
    'bC16','Fp2';...
    'bC17','Fpz';...
    'bC19','AFz';...
    'bC21','Fz';...
    'bC23','FbCz';...
    'bC29','Fp1';...
    'bC30','AF7';...
    'bD7','F7';...
    'bD8','FT7';...
    'bD14','C1';...
    'bD19','C3';...
    'bD21','C5';...
    'bD23','T7';...
    'bD24','TP7';...
    'bD31','P7'};
% etable={
%'E34','PZ','E62','E19';...
%'E39','OZ','E75','E20';...
%'E0','P3','E52','E7';...
%'E0','P4','E92','E8';...
%'E24','T3','E45','E13';...
%'E27','T5','E58',[];...
%'E52','T4','E108','E14';...
%'E49','T6','E96',[];...
%'E10','FPZ','E15','E27';...
%'E0','FZ','E11','E17';...
%'E12','bAF3','E23',[];...
%'E2','bAF4','E3',[];...
%'E14','bAF7','E26',[];...
%'E1','bAF8','E2',[];...
%'E7','bAFZ','E16',[];...
%'E5','bC1','E30',[];...
%'E55','bC2','E105',[];...
%'E17','bC3','E36','E5';...
%'E54','bC4','E104','E6';...
%'E21','bC5','E41',[];...
%'E53','bC6','E103',[];...
%'E18','bCP1','E37',[];...
%'E43','bCP2','E87',[];...
%'E22','bCP3','E42',[];...
%'E47','bCP4','E93',[];...
%'E25','bCP5','E47',[];...
%'E50','bCP6','E98',[];...
%'E30','bCPZ','E55',[];...
%'bCz','bCZ','bCz','bCz';...%bAndy changed the 1st and third from E65 and E129
%'E8','F1','E19',[];...
%'E60','F10','E1',[];...
%'E3','F2','E4',[];...
%'E13','F3','E24','E3';...
%'E62','F4','E124','E4';...
%'E0','F5','E27',[];...
%'E0','F6','E123',[];...
%'E15','F7','E33','E11';...
%'E61','F8','E122','E12';...
%'E19','F9','E32',[];...
%'E9','FbC1','E13',[];...
%'E58','FbC2','E112',[];...
%'E0','FbC3','E29',[];...
%'E0','FbC4','E111',[];...
%'E16','FbC5','E28',[];...
%'E57','FbC6','E117',[];...
%'E4','FbCZ','E6','E28';...
%'E11','FP1','E22','E1';...
%'E6','FP2','E9','E2';...
%'E20','FT7','E34',[];...
%'E56','FT8','E116',[];...
%'E0','FT9','E38',[];...
%'E0','FT10','E121',[];...
%'E37','O1','E70','E9';...
%'E40','O2','E83','E10';...
%'E29','P1','E60',[];...
%'E48','P10','E95',[];...
%'E42','P2','E85',[];...
%'E28','P5','E51',[];...
%'E46','P6','E97',[];...
%'E27','P7','E58','E15';...
%'E49','P8','E96','E16';...
%'E31','P9','E64',[];...
%'E33','PO3','E67',[];...
%'E41','PO4','E77',[];...
%'E32','PO7','E65',[];...
%'E45','PO8','E90',[];...
%'E38','POZ','E72',[];...
%'E59','T10','E114',[];...
%'E0','T11','E45',[];...
%'E0','T12','E108',[];...
%'E23','T9','E44',[];...
%'E0','TP9','E57',[];...
%'E0','TP10','E100',[];...
%'E24','TP7','E46',[];...
%    'E52','TP8','E102',[]};
return