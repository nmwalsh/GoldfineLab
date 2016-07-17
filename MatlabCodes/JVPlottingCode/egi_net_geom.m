function [coords,equivs]=egi_net_geom(netlabel)
% usage: [coords,equivs]=egi_net_geom(netlabel) 
%
% + sets default electrode coordinates
%
% + details
%
% created on 12/14/11, JV, modified by Theresa Teslovich, then by JV
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Write an m-file
%[coords,equivs]=egi_net_geom(netlabel)

%that takes, as argument, a string variable
%netlabel='net64', or 'net128'

%and returns the following:

%coords, for net64, an array of size (65,3) giving the x (L-R), y (A-P), z (top to bottom)
%coordinates of the channels

%equivs is a cell array {65} or {129}, giving the 10-10 equivalent (FP1, ...)
%of each lead.  If no 10-10 equivalent, then equivs{k}=''
%equivs{last}='CZ'

%This will then be used to calculcate head center, add to eegp_defopts,
%and use to create a new "headbox", a 1 x n struct array with fields:
%   name
%   num_leads
%   lead_list
%   plotLocations

%One more thing:  if there is an "official" correspondence between the E-numbers for the 
%64-channel cap and the E-numbers for the 128-channel cap, then this should also be listed 
%in one of the output arguments of the routines we discussed.  I.e., 

%if netlabel='net64', tthen
%[coords,equivs,e128]=egi_net_geom(netlabel)
%should list a 65-element column vector of equivalent numbers in e128

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

coords=[];
equivs=[];

if nargin<1 netlabel='net128'; end

%set default electrode coordinates and 10-10 equivs for 64-channel net, unless otherwise specified
switch netlabel
    case {'net64','net64t'}
    net64.EGI001 = [4.82147, -8.46376, 0.0639843];
    net64.EGI002 = [3.44999, 9.06441, 2.97064];
    net64.EGI003 = [1.90275, 7.64198, 6.40285];
    net64.EGI004 = [0, 5.21914, 8.1954];
    net64.EGI005 = [-1.72628, 2.48578, 8.55637];
    net64.EGI006 = [1.59679, 10.5184, 0.515771];
    net64.EGI007 = [0, 9.909, 4.03918];
    net64.EGI008 = [-1.90275, 7.64198, 6.40285];
    net64.EGI009 = [-3.4491, 4.88753, 7.22782];
    net64.EGI010 = [0, 10.2056, -1.61817];
    net64.EGI011 = [-1.59679, 10.5184, 0.515771];
    net64.EGI012 = [-3.44999, 9.06441, 2.97064];
    net64.EGI013 = [-4.77336, 6.69969, 4.57236];
    net64.EGI014 = [-4.82147, 8.46376, -0.0639843];
    net64.EGI015 = [-6.08393, 6.13847, 1.57273];
    net64.EGI016 = [-6.3032, 3.70148, 4.22719];
    net64.EGI017 = [-5.2874, 1.30272, 6.65006];
    net64.EGI018 = [-2.89239, -1.49571, 8.18118];
    net64.EGI019 = [-6.49644, 4.76669, -1.9182];
    net64.EGI020 = [-7.25734, 2.59912, 0.903444];
    net64.EGI021 = [-7.34336, 0.287481, 3.19674];
    net64.EGI022 = [-5.94121, -2.42769, 5.97948];
    net64.EGI023 = [-6.70321, 2.34743, -5.19168];
    net64.EGI024 = [-7.64626, -1.18501, 0.271229];
    net64.EGI025 = [-7.24521, -2.89502, 2.68804];
    net64.EGI026 = [-7.06353, -3.2423, -2.70838];
    net64.EGI027 = [-6.78539, -4.619, -0.234471];
    net64.EGI028 = [-5.98166, -5.75781, 2.97462];
    net64.EGI029 = [-3.3831, -5.87378, 6.25655];
    net64.EGI030 = [0, -4.05271, 8.13937];
    net64.EGI031 = [-5.64139, -6.07135, -3.5143];
    net64.EGI032 = [-4.88083, -7.67925, -0.352208];
    net64.EGI033 = [-3.16769, -8.12261, 3.13635];
    net64.EGI034 = [0, -7.14834, 5.87509];
    net64.EGI035 = [-4.27348, -6.69422, -6.35512];
    net64.EGI036 = [-3.08195, -8.59131, -3.53248];
    net64.EGI037 = [-1.79973, -9.42935, -0.256676];
    net64.EGI038 = [0, -8.99684, 2.56482];
    net64.EGI039 = [0, -9.12413, -3.87835];
    net64.EGI040 = [1.79973, -9.42935, -0.256676];
    net64.EGI041 = [3.16769, -8.12261, 3.13635];
    net64.EGI042 = [3.3831, -5.87378, 6.25655];
    net64.EGI043 = [2.89239, -1.49571, 8.18118];
    net64.EGI044 = [3.08195, -8.59131, -3.53248];
    net64.EGI045 = [4.88083, -7.67925, -0.352208];
    net64.EGI046 = [5.98166, -5.75781, 2.97462];
    net64.EGI047 = [5.94121, -2.42769, 5.97948];
    net64.EGI048 = [5.64139, -6.07135, -3.5143];
    net64.EGI049 = [6.78539, -4.619, -0.234471];
    net64.EGI050 = [7.24521, -2.89502, 2.68804];
    net64.EGI051 = [7.06353, -3.2423, -2.70838];
    net64.EGI052 = [7.64626, -1.18501, 0.271229];
    net64.EGI053 = [7.34336, 0.287481, 3.19674];
    net64.EGI054 = [5.2874, 1.30272, 6.65006];
    net64.EGI055 = [1.72628, 2.48578, 8.55637];
    net64.EGI056 = [7.25734, 2.59912, 0.903444];
    net64.EGI057 = [6.3032, 3.70148, 4.22719];
    net64.EGI058 = [3.4491, 4.88753, 7.22782];
    net64.EGI059 = [6.70321, 2.34743, -5.19168];
    net64.EGI060 = [6.49644, 4.76669, -1.9182];
    net64.EGI061 = [6.08393, 6.13847, 1.57273];
    net64.EGI062 = [4.77336, 6.69969, 4.57236];
    net64.EGI063 = [3.82315, 7.90175, -7.06073];
    net64.EGI064 = [-3.82315, 7.90175, -7.06073];
    net64.EGI065 = [0, 0, 8.94282];    
    
    coords=net64;
       

    case {'net128','net128t'}
    %set default electrode coordinates for 128-channel net, unless otherwise specified
	net128.EGI001 = [5.787677636, 5.520863216, -2.577468644];
	net128.EGI002 = [5.291804727, 6.709097557, 0.307434896];
	net128.EGI003 = [3.864122447, 7.63424051, 3.067770143];
	net128.EGI004 = [2.868837559, 7.145708546, 4.989564557];
	net128.EGI005 = [1.479340453, 5.68662139, 6.812878187];
	net128.EGI006 = [0, 3.806770224, 7.891304964];
	net128.EGI007 = [-1.223800252, 1.558864431, 8.44043914];
	net128.EGI008 = [4.221901505, 7.998817387, -1.354789681];
	net128.EGI009 = [2.695405558, 8.884820317, 1.088308144];
	net128.EGI010 = [1.830882336, 8.708839134, 3.18709115];
	net128.EGI011 = [0, 7.96264703, 5.044718001];
	net128.EGI012 = [-1.479340453, 5.68662139, 6.812878187];
	net128.EGI013 = [-2.435870762, 3.254307219, 7.608766206];
	net128.EGI014 = [1.270447661, 9.479016328, -0.947183306];
	net128.EGI015 = [0, 9.087440894, 1.333345013];
	net128.EGI016 = [0, 9.076490798, 3.105438474];
	net128.EGI017 = [0, 9.271139705, -2.211516434];
	net128.EGI018 = [-1.830882336, 8.708839134, 3.18709115];
	net128.EGI019 = [-2.868837559, 7.145708546, 4.989564557];
	net128.EGI020 = [-3.825797111, 5.121648995, 5.942844877];
	net128.EGI021 = [-1.270447661, 9.479016328, -0.947183306];
	net128.EGI022 = [-2.695405558, 8.884820317, 1.088308144];
	net128.EGI023 = [-3.864122447, 7.63424051, 3.067770143];
	net128.EGI024 = [-4.459387187, 6.021159964, 4.365321482];
	net128.EGI025 = [-4.221901505, 7.998817387, -1.354789681];
	net128.EGI026 = [-5.291804727, 6.709097557, 0.307434896];
	net128.EGI027 = [-5.682547954, 5.453384344, 2.836565436];
	net128.EGI028 = [-5.546670402, 4.157847823, 4.627615703];
	net128.EGI029 = [-4.762196763, 2.697832099, 6.297663028];
	net128.EGI030 = [-3.695490968, 0.960411022, 7.627828134];
	net128.EGI031 = [-1.955187826, -0.684381878, 8.564858511];
	net128.EGI032 = [-5.787677636, 5.520863216, -2.577468644];
	net128.EGI033 = [-6.399087198, 4.127248875, -0.356852241];
	net128.EGI034 = [-6.823959684, 2.968422112, 2.430080351];
	net128.EGI035 = [-6.414469893, 1.490027747, 4.741794544];
	net128.EGI036 = [-5.47913021, 0.284948655, 6.38332782];
	net128.EGI037 = [-3.909902609, -1.519049882, 7.764134929];
	net128.EGI038 = [-6.550732888, 3.611543152, -3.353155926];
	net128.EGI039 = [-7.191620108, 0.850096251, -0.882936903];
	net128.EGI040 = [-7.391919265, 0.032151584, 2.143634599];
	net128.EGI041 = [-6.905051715, -0.800953972, 4.600056501];
	net128.EGI042 = [-5.956055073, -2.338984312, 6.00361353];
	net128.EGI043 = [-6.518995129, 2.417299399, -5.253637073];
	net128.EGI044 = [-6.840717711, 1.278489412, -3.5553823];
	net128.EGI045 = [-7.304625099, -1.866238006, -0.629182006];
	net128.EGI046 = [-7.312517928, -2.298574078, 2.385298838];
	net128.EGI047 = [-6.737313764, -3.011819533, 4.178390203];
	net128.EGI048 = [-5.934584124, 2.22697797, -7.934360742];
	net128.EGI049 = [-6.298127313, 0.41663451, -6.069156425];
	net128.EGI050 = [-6.78248072, -4.023512045, -0.232191092];
	net128.EGI051 = [-6.558030032, -4.667036048, 2.749989597];
	net128.EGI052 = [-5.831241498, -4.494821698, 4.955347697];
	net128.EGI053 = [-4.193518856, -4.037020083, 6.982920038];
	net128.EGI054 = [-2.270752074, -3.414835627, 8.204556551];
	net128.EGI055 = [0, -2.138343513, 8.791875902];
	net128.EGI056 = [-6.174969392, -2.458138877, -5.637380998];
	net128.EGI057 = [-6.580438308, -3.739554155, -2.991084431];
	net128.EGI058 = [-6.034746843, -5.755782196, 0.051843011];
	net128.EGI059 = [-5.204501802, -6.437833018, 2.984444293];
	net128.EGI060 = [-4.116929504, -6.061561438, 5.365757296];
	net128.EGI061 = [-2.344914884, -5.481057427, 7.057748614];
	net128.EGI062 = [0, -6.676694032, 6.465208258];
	net128.EGI063 = [-5.333266171, -4.302240169, -5.613509789];
	net128.EGI064 = [-5.404091392, -5.870302681, -2.891640039];
	net128.EGI065 = [-4.645302298, -7.280552408, 0.130139701];
	net128.EGI066 = [-3.608293164, -7.665487704, 3.129931648];
	net128.EGI067 = [-1.844644417, -7.354417376, 5.224001733];
	net128.EGI068 = [-3.784983913, -6.401014415, -5.260040689];
	net128.EGI069 = [-3.528848027, -7.603010836, -2.818037873];
	net128.EGI070 = [-2.738838019, -8.607966849, 0.239368223];
	net128.EGI071 = [-1.404967401, -8.437486994, 3.277284901];
	net128.EGI072 = [0, -7.829896826, 4.687622229];
	net128.EGI073 = [-1.929652202, -7.497197868, -5.136777648];
	net128.EGI074 = [-1.125731192, -8.455208629, -2.632832329];
	net128.EGI075 = [0, -8.996686498, 0.487952047];
	net128.EGI076 = [1.404967401, -8.437486994, 3.277284901];
	net128.EGI077 = [1.844644417, -7.354417376, 5.224001733];
	net128.EGI078 = [2.344914884, -5.481057427, 7.057748614];
	net128.EGI079 = [2.270752074, -3.414835627, 8.204556551];
	net128.EGI080 = [1.955187826, -0.684381878, 8.564858511];
	net128.EGI081 = [0, -7.85891896, -4.945387489];
	net128.EGI082 = [1.125731192, -8.455208629, -2.632832329];
	net128.EGI083 = [2.738838019, -8.607966849, 0.239368223];
	net128.EGI084 = [3.608293164, -7.665487704, 3.129931648];
	net128.EGI085 = [4.116929504, -6.061561438, 5.365757296];
	net128.EGI086 = [4.193518856, -4.037020083, 6.982920038];
	net128.EGI087 = [3.909902609, -1.519049882, 7.764134929];
	net128.EGI088 = [1.929652202, -7.497197868, -5.136777648];
	net128.EGI089 = [3.528848027, -7.603010836, -2.818037873];
	net128.EGI090 = [4.645302298, -7.280552408, 0.130139701];
	net128.EGI091 = [5.204501802, -6.437833018, 2.984444293];
	net128.EGI092 = [5.831241498, -4.494821698, 4.955347697];
	net128.EGI093 = [5.956055073, -2.338984312, 6.00361353];
	net128.EGI094 = [3.784983913, -6.401014415, -5.260040689];
	net128.EGI095 = [5.404091392, -5.870302681, -2.891640039];
	net128.EGI096 = [6.034746843, -5.755782196, 0.051843011];
	net128.EGI097 = [6.558030032, -4.667036048, 2.749989597];
	net128.EGI098 = [6.737313764, -3.011819533, 4.178390203];
	net128.EGI099 = [5.333266171, -4.302240169, -5.613509789];
	net128.EGI100 = [6.580438308, -3.739554155, -2.991084431];
	net128.EGI101 = [6.78248072, -4.023512045, -0.232191092];
	net128.EGI102 = [7.312517928, -2.298574078, 2.385298838];
	net128.EGI103 = [6.905051715, -0.800953972, 4.600056501];
	net128.EGI104 = [5.47913021, 0.284948655, 6.38332782];
	net128.EGI105 = [3.695490968, 0.960411022, 7.627828134];
	net128.EGI106 = [1.223800252, 1.558864431, 8.44043914];
	net128.EGI107 = [6.174969392, -2.458138877, -5.637380998];
	net128.EGI108 = [7.304625099, -1.866238006, -0.629182006];
	net128.EGI109 = [7.391919265, 0.032151584, 2.143634599];
	net128.EGI110 = [6.414469893, 1.490027747, 4.741794544];
	net128.EGI111 = [4.762196763, 2.697832099, 6.297663028];
	net128.EGI112 = [2.435870762, 3.254307219, 7.608766206];
	net128.EGI113 = [6.298127313, 0.41663451, -6.069156425];
	net128.EGI114 = [6.840717711, 1.278489412, -3.5553823];
	net128.EGI115 = [7.191620108, 0.850096251, -0.882936903];
	net128.EGI116 = [6.823959684, 2.968422112, 2.430080351];
	net128.EGI117 = [5.546670402, 4.157847823, 4.627615703];
	net128.EGI118 = [3.825797111, 5.121648995, 5.942844877];
	net128.EGI119 = [5.934584124, 2.22697797, -7.934360742];
	net128.EGI120 = [6.518995129, 2.417299399, -5.253637073];
	net128.EGI121 = [6.550732888, 3.611543152, -3.353155926];
	net128.EGI122 = [6.399087198, 4.127248875, -0.356852241];
	net128.EGI123 = [5.682547954, 5.453384344, 2.836565436];
	net128.EGI124 = [4.459387187, 6.021159964, 4.365321482];
	net128.EGI125 = [6.118458137, 4.523870113, -4.409174427];
	net128.EGI126 = [3.743504949, 6.649204911, -6.530243068];
	net128.EGI127 = [-3.743504949, 6.649204911, -6.530243068];
	net128.EGI128 = [-6.118458137, 4.523870113, -4.409174427];
	net128.EGI129 = [0, 0, 8.899186843];

	coords=net128;
    
end
switch netlabel
    
    case 'net64'
    %10-10 equivs
    etable=egi_equivtable;
    for k=1:65
        equivs{k}=' ';
    end
    for m=1:size(etable,1)
        k=str2num(strrep(etable{m,1},'EGI',''));
        if (k>0)
            if isempty(deblank(equivs{k}))
                equivs{k}=etable{m,2};
            end
        end
    end

    case 'net128'
    %10-10 equivs
    etable=egi_equivtable;
    for k=1:129
        equivs{k}=' ';
    end
    for m=1:size(etable,1)
        k=str2num(strrep(etable{m,3},'EGI',''));
        if (k>0)
            if isempty(deblank(equivs{k}))
                equivs{k}=etable{m,2};
            end
        end
    end

    case 'net64t'
    %10-10 equivs
    equivs64{1} = 'AF8';
    equivs64{2} = 'AF4';
    equivs64{3} = 'F2';
    equivs64{4} = 'FCZ';
    equivs64{5} = 'C1';
    equivs64{6} = 'FP2';
    equivs64{7} = 'AFZ';
    equivs64{8} = 'F1';
    equivs64{9} = 'FC1';
    equivs64{10} = ' ';
    equivs64{11} = 'FP1';
    equivs64{12} = 'AF3';
    equivs64{13} = 'F3';
    equivs64{14} = 'AF7';
    equivs64{15} = 'F7';
    equivs64{16} = 'FC5';
    equivs64{17} = 'C3';
    equivs64{18} = 'CP1';
    equivs64{19} = 'F9';
    equivs64{20} = 'FT7';
    equivs64{21} = 'C5';
    equivs64{22} = 'CP3';
    equivs64{23} = 'T9';
    equivs64{24} = 'TP7';
    equivs64{25} = 'CP5';
    equivs64{26} = ' ';
    equivs64{27} = 'P7';
    equivs64{28} = 'P5';
    equivs64{29} = 'P1';
    equivs64{30} = 'CPZ';
    equivs64{31} = 'P9';
    equivs64{32} = 'PO7';
    equivs64{33} = 'PO3';
    equivs64{34} = 'PZ';
    equivs64{35} = ' ';
    equivs64{36} = ' ';
    equivs64{37} = 'O1';
    equivs64{38} = 'POZ';
    equivs64{39} = ' ';
    equivs64{40} = 'O2';
    equivs64{41} = 'PO4';
    equivs64{42} = 'P2';
    equivs64{43} = 'CP2';
    equivs64{44} = ' ';
    equivs64{45} = 'PO8';
    equivs64{46} = 'P6';
    equivs64{47} = 'CP4';
    equivs64{48} = 'P10';
    equivs64{49} = 'P8';
    equivs64{50} = 'CP6';
    equivs64{51} = ' ';
    equivs64{52} = 'TP8';
    equivs64{53} = 'C6';
    equivs64{54} = 'C4';
    equivs64{55} = 'C2';
    equivs64{56} = 'FT8';
    equivs64{57} = 'FC6';
    equivs64{58} = 'FC2';
    equivs64{59} = 'T10';
    equivs64{60} = 'F10';
    equivs64{61} = 'F8';
    equivs64{62} = 'F4';
    equivs64{63} = ' ';
    equivs64{64} = ' ';
    equivs64{65} = 'CZ';   
    equivs=equivs64;    
    
    case 'net128t'
    %10-10 equivs
    equivs128{1} = 'F10';
    equivs128{2} = 'AF8';
    equivs128{3} = 'AF4';
    equivs128{4} = 'F2';
    equivs128{5} = ' ';
    equivs128{6} = 'FCZ';
    equivs128{7} = ' ';
    equivs128{8} = ' ';
    equivs128{9} = 'FP2';
    equivs128{10} = ' ';
    equivs128{11} = 'FZ';
    equivs128{12} = ' ';
    equivs128{13} = 'FC1';
    equivs128{14} = ' ';
    equivs128{15} = ' ';
    equivs128{16} = 'AFZ';
    equivs128{17} = ' ';
    equivs128{18} = ' ';
    equivs128{19} = 'F1';
    equivs128{20} = ' ';
    equivs128{21} = ' ';
    equivs128{22} = 'FP1';
    equivs128{23} = 'AF3';
    equivs128{24} = 'F3';
    equivs128{25} = ' ';
    equivs128{26} = 'AF7';
    equivs128{27} = 'F5';
    equivs128{28} = 'FC5';
    equivs128{29} = 'FC3';
    equivs128{30} = 'C1';
    equivs128{31} = ' ';
    equivs128{32} = 'F9';
    equivs128{33} = 'F7';
    equivs128{34} = 'FT7';
    equivs128{35} = ' ';
    equivs128{36} = 'C3';
    equivs128{37} = 'CP1';
    equivs128{38} = 'FT9';
    equivs128{39} = ' ';
    equivs128{40} = 'T7';
    equivs128{41} = 'C5';
    equivs128{42} = 'CP3';
    equivs128{43} = ' ';
    equivs128{44} = 'T9';
    equivs128{45} = ' ';
    equivs128{46} = 'TP7';
    equivs128{47} = 'CP5';
    equivs128{48} = ' ';
    equivs128{49} = ' ';
    equivs128{50} = ' ';
    equivs128{51} = ' ';
    equivs128{52} = 'P5';
    equivs128{53} = ' ';
    equivs128{54} = ' ';
    equivs128{55} = 'CPZ';
    equivs128{56} = ' ';
    equivs128{57} = 'TP9';
    equivs128{58} = 'P9';
    equivs128{59} = 'P7';
    equivs128{60} = 'P3';
    equivs128{61} = 'P1';
    equivs128{62} = ' ';
    equivs128{63} = ' ';
    equivs128{64} = ' ';
    equivs128{65} = 'PO7';
    equivs128{66} = ' ';
    equivs128{67} = 'PO3';
    equivs128{68} = ' ';
    equivs128{69} = ' ';
    equivs128{70} = 'O1';
    equivs128{71} = ' ';
    equivs128{72} = 'POZ';
    equivs128{73} = ' ';
    equivs128{74} = ' ';
    equivs128{75} = 'OZ';
    equivs128{76} = ' ';
    equivs128{77} = 'PO4';
    equivs128{78} = 'P2';
    equivs128{79} = ' ';
    equivs128{80} = ' ';
    equivs128{81} = ' ';
    equivs128{82} = ' ';
    equivs128{83} = 'O2';
    equivs128{84} = ' ';
    equivs128{85} = 'P4';
    equivs128{86} = ' ';
    equivs128{87} = 'CP2';
    equivs128{88} = ' ';
    equivs128{89} = ' ';
    equivs128{90} = 'PO8';
    equivs128{91} = 'P8';
    equivs128{92} = 'P6';
    equivs128{93} = 'CP4';
    equivs128{94} = ' ';
    equivs128{95} = ' ';
    equivs128{96} = 'P10';
    equivs128{97} = ' ';
    equivs128{98} = 'CP6';
    equivs128{99} = ' ';
    equivs128{100} = 'TP10';
    equivs128{101} = ' ';
    equivs128{102} = 'TP8';
    equivs128{103} = 'C6';
    equivs128{104} = 'C4';
    equivs128{105} = 'C2';
    equivs128{106} = ' ';
    equivs128{107} = ' ';
    equivs128{108} = ' ';
    equivs128{109} = 'T8';
    equivs128{110} = ' ';
    equivs128{111} = 'FC4';
    equivs128{112} = 'FC2';
    equivs128{113} = ' ';
    equivs128{114} = 'T10';
    equivs128{115} = ' ';
    equivs128{116} = 'FT8';
    equivs128{117} = 'FC6';
    equivs128{118} = ' ';
    equivs128{119} = ' ';
    equivs128{120} = ' ';
    equivs128{121} = 'FT10';
    equivs128{122} = 'F8';
    equivs128{123} = 'F6';
    equivs128{124} = 'F4';
    equivs128{125} = ' ';
    equivs128{126} = ' ';
    equivs128{127} = ' ';
    equivs128{128} = ' ';
    equivs128{129} = 'CZ';
    
    equivs=equivs128;
    
end

if (isempty(equivs) | isempty(coords))
    warning('net label unknown, electrode coordinates cannot be determined.');
end
return