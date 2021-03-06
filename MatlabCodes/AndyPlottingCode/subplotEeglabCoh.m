function subplotEeglabCoh(figuretitle,cohfile1,pathname1,cohfile2,pathname2,coh1label,coh2label,legendon)

%to plot coherences created by Coheeglab
%version 2 2/24/11 - if 2 coherences run, 1. calls two_group_test_coherence, 2. plots *s where
%significant, 3. calculates differences between coherences, 4. calculates p-values from TGT output,
%4. saves the results (p-values and differences) to use for wire map. [x] Also
%need to change the title to be in the figure. [] Also allow to plot 3
%coherences (though may be difficult to interpret)
%version 3 2/25/11 allows to be called from CoheeglabBat assuming 2 at a
%time. 3/12/11 added option to not make figure since huge number of
%coherences.
%[] need to make a new GUI version to plot a subset either by selecting from a list or clicking
%lines on a wire graph OR selecting spacing or sides of the head OR a version that plots
%them all across multiple figures
%v4 3/13/11 makes a GUI if code called on its own to allow selection of
%channels to plot since too many 
%v5 3/20/11 now calculates TGT based on original data rather than data as
%channel pairs and only calculates J once per channel (before was doing for
%each pair = 666x2 times!
%v6 12/21/11 if have accelerometer time series either can't do 1st plot or
%need to place it elsewhere
%4/20/12 v7 changed to use uipickfiles
%4/23/12 turned variables into handles so they don't span the codes and
%this allows the control figure to be saved with all the data in it.
%4/30/12 fixed bug where forgot to put handle for creating TGToutput.f.
%5/9/12 removed manual setting of xticks since wasn't showing any if use
%narrow range.
%8/5/13 AMG version 8 changed the p value calculation to use sigma instead
%of variance (correction like I did with power recently)

%ToDo:
%have it create the Hjorth in the code (rather than having preset list) so
%can see the wiremap. Will need to figure out what to do for Acceleroemters. This is
%low priority.


%%
if nargin<1
    createFigure=1; %to actually make the figure. Suppressed in batch since too many figures
    %load data
    dh.numSpec=input('How many coherences (datasets) to plot (1,2,3)?: ');
    
    dh.legendon=0;
    if dh.numSpec>1
        if strcmpi(input('Legend? (y or Return): ','s'),'y')
            dh.legendon=1;
            dh.coh1label=input('Coherence1 label: ','s');
            dh.coh2label=input('Coherence2 label: ','s');
        end
    end
    % 
    % plotsigfreq=1;
    % if nargin<1 && numSpec==2
    %     if ~isequal(input('Plot Sig Freq plot? (y-yes, otherwise no)','s'),'y')
    %         plotsigfreq=0;
    %     end
    % end
 
    figuretitle=input('Figure Title (or return to auto create): ','s');
    dh.figuretitle=figuretitle;
    pathname=cell(1,dh.numSpec);cohpath=pathname;cohfile=pathname;dh.coh=pathname;%initialize
    for jk=1:dh.numSpec
        prompttext=sprintf('Pick dataset %.0f.',jk);
        pathname{jk}=uipickfiles('type',{'*Coh.mat'},'prompt',prompttext,'output','char');
        [cohpath{jk} cohfile{jk}]=fileparts(pathname{jk});
        if isnumeric(pathname{jk}) || isempty(pathname{jk})
            return
        end
        dh.coh{jk}=load(pathname{jk});
    end
%     [cohfile1, pathname1] = uigetfile('*Coh.mat', 'Select First Dataset');
%         %if load none, it appears as a 0 so this tells the program to end
%     if isempty(cohfile1)
%         return; 
%     else
%          coh{1}=load(fullfile(pathname1,cohfile1));
         if isempty(dh.figuretitle) && dh.numSpec==1
             dh.figuretitle=cohfile{1};
         end
%         coh{1}=load(fullfile(pathname1,cohfile1),'C','ChannelList','f','pairs','params');%3/19/11
%     end;

%     if numSpec>1
%         [cohfile2, pathname2] = uigetfile('*Coh.mat', 'Select Second Dataset');
%          coh{2}=load(fullfile(pathname2,cohfile2));
%         
% %         coh{2}=load(fullfile(pathname2,cohfile2),'C','ChannelList','f','pairs','params');%3/19/11
%              if numSpec==3
%                  [cohfile3,pathname3]=uigetfile('*Coh.mat', 'Select Third Dataset');
%                  coh{3}=load(fullfile(pathname3,cohfile3));
%              end
        if isempty(dh.figuretitle) &&dh.numSpec==2
            dh.figuretitle=[cohfile{1} '_vs_' cohfile{2}];
        elseif isempty(dh.figuretitle) &&dh.numSpec==3
            dh.figuretitle=[cohfile{1} '_vs_' cohfile{2} 'vs' cohfile{3}];
        end
%     end
    
    
    
else %if in batch mode
    createFigure=0;
    dh.figuretitle=figuretitle;
    dh.legendon=legendon;
    dh.numSpec=2;
    dh.coh1label=coh1label;
    dh.coh2label=coh2label;
    dh.coh{1}=load(fullfile(pathname1,cohfile1));
    dh.coh{2}=load(fullfile(pathname2,cohfile2));
end

%%
%need to ensure the same number of datapoints in each (meaning same fpass
%and trial length from Coheeglab, in future can modify this. [] add in for
%3rd at somepoint
if dh.numSpec>1
    if ~isequal(size(dh.coh{1}.C{1},1),size(dh.coh{2}.C{1},1))
        disp('Different number of values in each coherence, could be because of different snippet lengths or different fpass, need to modify code if want to run');
        return
    end

    if ~isequal(length(dh.coh{1}.C),length(dh.coh{2}.C)) %if different number of coherence pairs
        disp('Different number of coherence pairs in each condition, will use pairs from sample one though can modify code');
    end
end

%%
%run two group test if 2 coherences, either pull in a complete one or
%calculate from channel data sent in from Coheeglab or get channel data
%from .set files to use
if dh.numSpec==2
    if nargin<1 && strcmpi(input('Use existing TGToutput (y or Return)?','s'),'y') %want to not do this if running in batch so use &&
%         [TGTfilename, pathname4] = uigetfile('*CohTGTandDiff.mat', 'Select TGToutput File');
        pathname4=uipickfiles('type',{'*CohTGTandDiff.mat','Coh TGT file'},'prompt','Select Coh TGToutput File','num',1,'output','char');
        [TGTpath TGTfilename]=fileparts(pathname4);
         if isempty(dh.figuretitle) %if wasn't filled in above
             dh.figuretitle=TGTfilename(1:end-14);
         end
        TGTfile=load(pathname4);
        dh.TGToutput=TGTfile.TGToutput;

    %first calculate spectra for each channel for each channel and each
    %condition

    %Here's the for loop to calculate two sample test on each cell (channel)
    %from each of the 2 input data. Will need to save the output to a cell
    %array to use for the plotting part next.

    else %whether from batch or called directly, load data from Coh file and calculate TGT and difference
%         if nargin<1 %need to pull in original data again from original files and make channel pairs like in Coheeglab
%              coh{1}.dataByChannel=load(fullfile(pathname1,cohfile1),'dataByChannel');%organized as data x snippet
%              coh{2}.dataByChannel=load(fullfile(pathname2,cohfile2),'dataByChannel');
             
            for cc=1:2 %for each condition calculate the Js for each channel

%                 numChan=size(alleeg.data,1);
                numPoints=size(dh.coh{1}.dataByChannel{1},1);
%                 numSnip=size(alleeg.data,3);
                
                %convert to J here and then send to TGT as pairs.
                tapers=dpss(numPoints,dh.coh{1}.params.tapers(1),dh.coh{1}.params.tapers(2));
                for ij=1:length(dh.coh{1}.ChannelList) %for each channel
                   JByChannel{cc}{ij}=mtfftc(dh.coh{cc}.dataByChannel{ij},tapers,numPoints,dh.coh{1}.params.Fs);%size is numPointsxtapersxtrials
%                    sizeJ=size(JByChannel{cc}{ii});
                   JByChannel{cc}{ij}=reshape(JByChannel{cc}{ij},size(JByChannel{cc}{ij},1), []);%reshape since tapers and trials equivalent
                end
                
%                
%                 
%                 for q=1:size(coh{1}.pairs,1) %for each coherence pair
%                     ChanIndex1=strcmpi(coh{1}.pairs(q,1),ChannelList);
%                     ChanIndex2=strcmpi(coh{1}.pairs(q,2),ChannelList);
%                     coh{cc}.dataAsChannelPairs{q}{1}=dataByChannel{ChanIndex1};
%                     coh{cc}.dataAsChannelPairs{q}{2}=dataByChannel{ChanIndex2};
%                 end
%             end
%             
%         else %if from batch then just use output from Coheeglab
%             %[] need to modify this to take in data by channel and convert
%             %to J, or move code above below and send it data by Channel[]
%             
%     %     data1=load(fullfile(pathname1,cohfile1),'dataAsChannelPairs');
%         coh{1}.dataAsChannelPairs=dataAsChannelPairs1;
%     %     data2=load(fullfile(pathname2,cohfile2),'dataAsChannelPairs');
%         coh{2}.dataAsChannelPairs=dataAsChannelPairs2;
           end
        
        p=0.05;
        
        fprintf('Two Group Test uses dpss tapers calculated with NW=%g and K=%g and p-value=%.3f\n',dh.coh{1}.params.tapers(1),dh.coh{1}.params.tapers(2),p);
        dh.TGToutput=cell(1,length(dh.coh{1}.C)); %to initialize it
        for k=1:length(dh.coh{1}.C) %for each channel pair

            differenceCoh1minusCoh2{k}=dh.coh{1}.C{k}-dh.coh{2}.C{k};
            com=dh.coh{1}.combinations; %matrix listing channel pairs used
            %calculate the spectra. Call J1 and J2 so use Hemant's code

            %here run the two group test. Get dz which is actual difference. vdz is
            %Jackknife variance estimate and Adz is 0/1 for normal variance so not
            %used.
            [dh.TGToutput{k}.dz,dh.TGToutput{k}.vdz,dh.TGToutput{k}.Adz]=two_group_test_coherence(JByChannel{1}{com(k,1)},JByChannel{1}{com(k,2)},JByChannel{2}{com(k,1)},JByChannel{2}{com(k,2)},p,'n');
%             (J{1}{1},J{1}{2},J{2}{1},J{2}{2},p,'n');

            %next need to convert to 1s and 0s based on vdz not normally
            %distributed.
            %calculate the jacknife errors as well
            dh.TGToutput{k}.f=linspace(0,dh.coh{1}.params.Fs,numPoints); %the x-axis of the plot is the
            %frequencies. Frequencies are 0 to frequencyRecorded/2 in divisions of
            %numSamplesPerSnippet. It's actually -frequencyRecorded/2 to
            %+frequencyRecorded/2 and then you plot half of the values.
        %

             %calculate the p-value at each frequency for use in potentially
             %plotting on a wire or for differential thresholding. Can just use
             %this p-value rather than doing AdzJK above! Can just plot below
             %when p<0.05 assuming same f or using it's own f (x-axis). Color to be
             %decided based on which coherence is higher.
             dh.TGToutput{k}.p=(2*(1-normcdf(abs(dh.TGToutput{k}.dz),0,sqrt(dh.TGToutput{k}.vdz))))';%transpose to be a row

        end
        channelPairs=dh.coh{1}.pairs; %for later plotting on wiremap
        differenceF=dh.coh{1}.f; %for plotting since not the same as for TGToutput
        ChannelList=dh.coh{1}.ChannelList;
        params=dh.coh{1}.params;
        TGToutput=dh.TGToutput;%for saving
        save([dh.figuretitle '_CohTGTandDiff'],'TGToutput','channelPairs','differenceCoh1minusCoh2','differenceF','ChannelList','params','numPoints');
    end
%     plottingFreqIndecesTGT=(TGToutput{1}.f>=plottingRange(1) & TGToutput{1}.f<=plottingRange(2));
end


%%
%if creating a figure need a gui to pick the channel pairs to plot
if createFigure
    for cl=1:length(dh.coh{1}.pairs)
        ChannelVsList{cl}=sprintf('%s vs %s',dh.coh{1}.pairs{cl,1},dh.coh{1}.pairs{cl,2});
    end
    listboxFigure=figure;
    set(listboxFigure,'Name',[dh.figuretitle ' Coherence Control'],'Units','normalized','Position',[0.05 0.2 0.3 0.7]);
    h.Listbox = uicontrol('Parent',listboxFigure,'Style', 'listbox','Units','normalized','Position', [.05 .1 .3 .8], 'String', ChannelVsList,'Max',length(ChannelVsList)-1,'Value',[]);
    h.ListboxOne = uicontrol('Parent',listboxFigure,'Style', 'listbox','Units','normalized','Position', [.7 .1 .3 .8], 'String', dh.coh{1}.ChannelList,'Max',1,'Min',1,'Value',1);
    h.checkBox=uicontrol('Style','checkbox','Units','normalized','Position',[0.7 0.9 0.1 0.1]);
    uicontrol('Style','text','String','Frequency Range to plot:','Units','normalized','FontSize',12,'Position',[.35 0.6 0.3 0.1]);
    h.rangeBox1=uicontrol('Parent',listboxFigure,'Style','edit','Units','normalized','FontSize',12,'Position',[0.35 0.5 0.1 0.1],'String','2','BackgroundColor',[1 1 1]);
    h.rangeBox2=uicontrol('Parent',listboxFigure,'Style','edit','Units','normalized','FontSize',12,'Position',[0.5 0.5 0.1 0.1],'String','55','BackgroundColor',[1 1 1]);
    FavoriteNames={'DistributedList'}; %add others within bracket
    h.FavoriteIndeces=([]); %put in here matrix with each row as a favorite list for above cell array
    h.FavoriteBox = uicontrol('Parent',listboxFigure,'Style', 'listbox','Units','normalized','Position', [.35 0.05 .3 .15], 'String', FavoriteNames,'Max',length(ChannelVsList)-1,'Value',[]);
    uicontrol('Units','normalized','Position',[.35 .2 .2 .1],'String','Done','Callback',{@Done_callback,h,dh});
    saveas(listboxFigure,dh.figuretitle,'fig');

   
end

%%
%
function Done_callback(src,eventdata,h,dh)
    
    plottingRange(1)=str2double(get(h.rangeBox1,'String'));
    plottingRange(2)=str2double(get(h.rangeBox2,'String'));
    index_selected = get(h.Listbox,'Value');
    plotIndividual=get(h.checkBox,'Value'); %if 1 then plot from individual list
    if plotIndividual
        channel_selected=get(h.ListboxOne,'Value');
        chanLocation=strcmpi(dh.coh{1}.pairs,dh.coh{1}.ChannelList(channel_selected));%where is that channel in the list
        index_selected=find(sum(chanLocation,2));%find in either column where that channel was, 2 columns so sum
    elseif isempty(index_selected)
            favorite=get(h.FavoriteBox,'Value');
            index_selected=h.FavoriteIndeces(favorite,:);
    else %use main list on left
        disp(['Pairs Chosen: ' index_selected]);
        disp('can add to code as a favorite');
    end
%     goodlist=ChannelList(index_selected);

    subplotCohDo(index_selected,plottingRange,dh)
end


    %%
    %plot with subplot command for number of channels don't forget code to
    %enlarge. also may want to give user option to zoom on f (so may then
    %change batSpectrogram to do all the spectra and decrease the amount you
    %see here).
    function subplotCohDo(index_selected,plottingRange,dh)

    %plot Coherence
    numPlots=length(index_selected)+1;
    %calculate subplot number
    numrows=ceil(sqrt(numPlots));
    numcols=floor(sqrt(numPlots));
    if numrows*numcols<numPlots
        numcols=numcols+1;
    end;
   

    % set(gcf,'Name',savename, 'Position',[1 1 scrsz(3)*0.8 scrsz(4)*0.9]);
  
    figureTitleName=sprintf('%s Coh',dh.figuretitle);
    figureHandle=findobj('name',figureTitleName);
    if isempty(figureHandle) %if figure was closed
         figureHandle=figure;
    else
        figure(figureHandle);
        clf(figureHandle);
    end
    figure(figureHandle);
    set(figureHandle,'Name',figureTitleName);
%     set(figureHandle,'Name',figureTitleName,'Units','normalized','Position',[0 0 .99 .95]);
    
    %plot wiremap showing comparisons performed
    if length(dh.coh{1}.ChannelList)==37
        ChannelOrderHjorth={'Fp1';'F7';'T3';'T5';'O1';'F3';'C3';'P3';'Fz';'Cz';'Fp2';'F8';'T4';'T6';'O2';'F4';'C4';'P4';'FPz';'Pz';'AF7';'AF8';'FC5';'FC6';'FC1';'FC2';'CP5';'CP6';'CP1';'CP2';'PO7';'PO8';'F1';'F2';'CPz';'POz';'Oz'};
        Hjorth=[1,0,0,0,0,-0.218059706639151,0,0,0,0,0,0,0,0,0,0,0,0,-0.389802723555477,0,-0.392137569805372,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,1,0,0,0,-0.270844016815127,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.435735312210910,0,-0.293420670973963,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,1,0,0,0,-0.290465836818808,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.298419668268419,0,0,0,-0.411114494912773,0,0,0,0,0,0,0,0,0,0;0,0,0,1,0,0,0,-0.267375315138502,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.302469838580032,0,0,0,-0.430154846281466,0,0,0,0,0,0;0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.372553979185885,0,0,0,0,-0.257110284225126,-0.370335736588989;0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.185505898658804,0,-0.278268516246153,0,-0.196005713043343,0,0,0,0,0,0,0,-0.340219872051701,0,0,0,0;0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.256890397741414,0,-0.240743394278684,0,-0.258351233565250,0,-0.244014974414652,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,-0.237297265305568,0,0,0,0,0,0,-0.248455721216341,0,-0.262016202004379,0,-0.252230811473712,0,0,0,0,0,0;0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.171356350663202,-0.171356350663202,0,0,0,0,0,0,-0.328643649336798,-0.328643649336798,0,0,0;0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.186977880693012,-0.186977880693012,0,0,-0.189811422610492,-0.189811422610492,0,0,0,0,-0.246421393392993,0,0;0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,-0.218059706639151,0,0,-0.389802723555477,0,0,-0.392137569805372,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,-0.270844016815127,0,0,0,0,0,-0.435735312210910,0,-0.293420670973963,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,-0.290465836818808,0,0,0,0,0,0,-0.298419668268419,0,0,0,-0.411114494912773,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,-0.267375315138502,0,0,0,0,0,0,0,0,0,-0.302469838580032,0,0,0,-0.430154846281466,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.372553979185885,0,0,0,-0.257110284225126,-0.370335736588989;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,-0.185505898658804,0,-0.278268516246153,0,-0.196005713043343,0,0,0,0,0,0,0,-0.340219872051701,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,-0.256890397741414,0,-0.240743394278684,0,-0.258351233565250,0,-0.244014974414652,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,-0.237297265305568,0,0,0,0,0,0,0,-0.248455721216341,0,-0.262016202004379,0,-0.252230811473712,0,0,0,0,0;-0.332679175394473,0,0,0,0,0,0,0,0,0,-0.332679175394473,0,0,0,0,0,0,0,1,0,-0.167320824605527,-0.167320824605527,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,-0.205256951719187,-0.205256951719187,0,0,0,0,-0.265022477726795,-0.324463618834831,0;-0.372639023830853,-0.372938473145979,0,0,0,-0.254422503023168,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,-0.372639023830853,-0.372938473145979,0,0,0,-0.254422503023168,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,-0.419314917909507,-0.302633292473904,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,-0.278051789616589,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.419314917909507,-0.302633292473904,0,0,0,0,0,0,1,0,-0.278051789616589,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,-0.240511156347427,-0.230947606741757,0,0,-0.242912543933471,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,-0.285628692977345,0,0,0,0;0,0,0,0,0,0,0,0,0,-0.242912543933471,0,0,0,0,0,-0.240511156347427,-0.230947606741757,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,-0.285628692977345,0,0,0;0,0,-0.245153593051656,-0.250610896028318,0,0,-0.264731995680004,-0.239503515240022,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,-0.245153593051656,-0.250610896028318,0,0,-0.264731995680004,-0.239503515240022,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,-0.216299465872555,-0.218491281519817,0,-0.227856769280073,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,-0.337352483327556,0,0;0,0,0,0,0,0,0,0,0,-0.227856769280073,0,0,0,0,0,0,-0.216299465872555,-0.218491281519817,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,-0.337352483327556,0,0;0,0,0,-0.372938473145979,-0.372639023830853,0,0,-0.254422503023168,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,-0.372938473145979,-0.372639023830853,0,0,-0.254422503023168,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0;0,0,0,0,0,-0.306578112609383,0,0,-0.322295921381199,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.209757165474835,0,0,0,0,0,0,0,1,-0.161368800534583,0,0,0;0,0,0,0,0,0,0,0,-0.322295921381199,0,0,0,0,0,0,-0.306578112609383,0,0,0,0,0,0,0,0,0,-0.209757165474835,0,0,0,0,0,0,-0.161368800534583,1,0,0,0;0,0,0,0,0,0,0,0,0,-0.238745242012679,0,0,0,0,0,0,0,0,0,-0.216713698261725,0,0,0,0,0,0,0,0,-0.272270529862798,-0.272270529862798,0,0,0,0,1,0,0;0,0,0,0,-0.206384741946864,0,0,0,0,0,0,0,0,0,-0.206384741946864,0,0,0,0,-0.319126865315220,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,-0.268103650791052;0,0,0,0,-0.344604135617391,0,0,0,0,0,0,0,0,0,-0.344604135617391,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.310791728765217,1];
        sp1=1;
    elseif length(dh.coh{1}.ChannelList)==29
        ChannelOrderHjorth={'Fp1';'F7';'T3';'T5';'O1';'F3';'C3';'P3';'Fz';'Cz';'Pz';'Fp2';'F8';'T4';'T6';'O2';'F4';'C4';'P4';'AF7';'AF8';'FC5';'FC6';'FC1';'FC2';'CP5';'CP6';'CP1';'CP2'};
        Hjorth=[1,-0.243615050543552,0,0,0,-0.270301239536486,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.486083709919962,0,0,0,0,0,0,0,0,0;0,1,0,0,0,-0.270844016815127,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.435735312210910,0,-0.293420670973963,0,0,0,0,0,0,0;0,0,1,0,0,0,-0.290465836818808,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.298419668268419,0,0,0,-0.411114494912773,0,0,0;0,0,0,1,-0.274319925105697,0,0,-0.340494145555959,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.385185929338344,0,0,0;0,0,0,-0.322290529143984,1,0,0,-0.357595022656101,0,0,0,0,0,0,0,-0.320114448199915,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,1,0,0,-0.209184027930766,0,0,0,0,0,0,0,0,0,0,-0.222348357215048,0,-0.333534124247993,0,-0.234933490606193,0,0,0,0,0;0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.256890397741414,0,-0.240743394278684,0,-0.258351233565250,0,-0.244014974414652,0;0,0,0,-0.235083752061842,0,0,0,1,0,0,-0.242738717519570,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.254153047447864,0,-0.268024482970723,0;0,0,0,0,0,-0.241714885747272,0,0,1,0,0,0,0,0,0,0,-0.241714885747272,0,0,0,0,0,0,-0.258285114252728,-0.258285114252728,0,0,0,0;0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.248119942702303,-0.248119942702303,0,0,-0.251880057297697,-0.251880057297697;0,0,0,0,0,0,0,-0.243788298237258,0,0,1,0,0,0,0,0,0,0,-0.243788298237258,0,0,0,0,0,0,0,0,-0.256211701762742,-0.256211701762742;0,0,0,0,0,0,0,0,0,0,0,1,-0.243615050543552,0,0,0,-0.270301239536486,0,0,0,-0.486083709919962,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,-0.270844016815127,0,0,0,-0.435735312210910,0,-0.293420670973963,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,-0.290465836818808,0,0,0,0,-0.298419668268419,0,0,0,-0.411114494912773,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,-0.274319925105697,0,0,-0.340494145555959,0,0,0,0,0,0,0,-0.385185929338344,0,0;0,0,0,0,-0.320114448199915,0,0,0,0,0,0,0,0,0,-0.322290529143984,1,0,0,-0.357595022656101,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,-0.209184027930766,0,0,0,0,0,0,0,1,0,0,0,-0.222348357215048,0,-0.333534124247993,0,-0.234933490606193,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,-0.256890397741414,0,-0.240743394278684,0,-0.258351233565250,0,-0.244014974414652;0,0,0,0,0,0,0,0,0,0,-0.242738717519570,0,0,0,-0.235083752061842,0,0,0,1,0,0,0,0,0,0,0,-0.254153047447864,0,-0.268024482970723;-0.372639023830853,-0.372938473145979,0,0,0,-0.254422503023168,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,-0.372639023830853,-0.372938473145979,0,0,0,-0.254422503023168,0,0,0,1,0,0,0,0,0,0,0,0;0,-0.216251958780686,0,0,0,-0.328637245565614,-0.237188250184174,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,-0.217922545469527,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,-0.216251958780686,0,0,0,-0.328637245565614,-0.237188250184174,0,0,0,0,1,0,-0.217922545469527,0,0,0,0;0,0,0,0,0,-0.254994249767126,-0.244854802625282,0,-0.242610703570584,-0.257540244037008,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0;0,0,0,0,0,0,0,0,-0.242610703570584,-0.257540244037008,0,0,0,0,0,0,-0.254994249767126,-0.244854802625282,0,0,0,0,0,0,1,0,0,0,0;0,0,-0.245153593051656,-0.250610896028318,0,0,-0.264731995680004,-0.239503515240022,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,-0.245153593051656,-0.250610896028318,0,0,-0.264731995680004,-0.239503515240022,0,0,0,0,0,0,0,1,0,0;0,0,0,0,0,0,-0.248445904187327,-0.250963467594612,0,-0.261720854652253,-0.238869773565808,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0;0,0,0,0,0,0,0,0,0,-0.261720854652253,-0.238869773565808,0,0,0,0,0,0,-0.248445904187327,-0.250963467594612,0,0,0,0,0,0,0,0,0,1];
        sp1=1;
    elseif length(dh.coh{1}.ChannelList)==35 %this one is for IN316W with AF7 and AF8 missing. Ran cofl_eegp_makemont_demo to creat it after removing nonused channels from eegp_defopts.m
        ChannelOrderHjorth={'FP1';'FP2';'F3';'F4';'C3';'C4';'P3';'P4';'O1';'O2';'F7';'F8';'T3';'T4';'T5';'T6';'FZ';'CZ';'PZ';'F1';'F2';'FC1';'FC2';'CP1';'CP2';'FC5';'FC6';'CP5';'CP6';'PO7';'PO8';'FPZ';'CPZ';'POZ';'OZ'};
        Hjorth=[1,0,-0.268164833627717,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.252464703479449,0,0,0,0,0,0,0,0,0,0,0,-0.479370462892834,0,0,0;0,1,0,-0.268164833627717,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.252464703479449,0,0,0,0,0,0,0,0,0,0,-0.479370462892834,0,0,0;0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.176460936805103,0,0,-0.343998015760184,0,-0.198182357655827,0,0,0,-0.281358689778887,0,0,0,0,0,0,0,0,0;0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-0.176460936805103,0,0,0,-0.343998015760184,0,-0.198182357655827,0,0,0,-0.281358689778887,0,0,0,0,0,0,0,0;0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.240743394278684,0,-0.244014974414652,0,-0.256890397741414,0,-0.258351233565250,0,0,0,0,0,0,0;0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.240743394278684,0,-0.244014974414652,0,-0.256890397741414,0,-0.258351233565250,0,0,0,0,0,0;0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,-0.237297265305568,0,0,0,0,-0.262016202004379,0,0,0,-0.248455721216341,0,-0.252230811473712,0,0,0,0,0;0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,-0.237297265305568,0,0,0,0,0,-0.262016202004379,0,0,0,-0.248455721216341,0,-0.252230811473712,0,0,0,0;0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.372553979185885,0,0,0,-0.257110284225126,-0.370335736588989;0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.372553979185885,0,0,-0.257110284225126,-0.370335736588989;-0.278868075779166,0,-0.346139447029506,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.374992477191328,0,0,0,0,0,0,0,0,0;0,-0.278868075779166,0,-0.346139447029506,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.374992477191328,0,0,0,0,0,0,0,0;0,0,0,0,-0.290465836818808,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-0.298419668268419,0,-0.411114494912773,0,0,0,0,0,0,0;0,0,0,0,0,-0.290465836818808,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-0.298419668268419,0,-0.411114494912773,0,0,0,0,0,0;0,0,0,0,0,0,-0.267375315138502,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-0.302469838580032,0,-0.430154846281466,0,0,0,0,0;0,0,0,0,0,0,0,-0.267375315138502,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,-0.302469838580032,0,-0.430154846281466,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,-0.328643649336798,-0.328643649336798,-0.171356350663202,-0.171356350663202,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,-0.186977880693012,-0.186977880693012,-0.189811422610492,-0.189811422610492,0,0,0,0,0,0,0,-0.246421393392993,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,-0.205256951719187,-0.205256951719187,0,0,0,0,0,0,0,-0.265022477726795,-0.324463618834831,0;0,0,-0.306578112609383,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.322295921381199,0,0,1,-0.161368800534583,-0.209757165474835,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,-0.306578112609383,0,0,0,0,0,0,0,0,0,0,0,0,-0.322295921381199,0,0,-0.161368800534583,1,0,-0.209757165474835,0,0,0,0,0,0,0,0,0,0,0,0;0,0,-0.240511156347427,0,-0.230947606741757,0,0,0,0,0,0,0,0,0,0,0,0,-0.242912543933471,0,-0.285628692977345,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,-0.240511156347427,0,-0.230947606741757,0,0,0,0,0,0,0,0,0,0,0,-0.242912543933471,0,0,-0.285628692977345,0,1,0,0,0,0,0,0,0,0,0,0,0,0;0,0,0,0,-0.216299465872555,0,-0.218491281519817,0,0,0,0,0,0,0,0,0,0,-0.227856769280073,0,0,0,0,0,1,0,0,0,0,0,0,0,0,-0.337352483327556,0,0;0,0,0,0,0,-0.216299465872555,0,-0.218491281519817,0,0,0,0,0,0,0,0,0,-0.227856769280073,0,0,0,0,0,0,1,0,0,0,0,0,0,0,-0.337352483327556,0,0;0,0,-0.328637245565614,0,-0.237188250184174,0,0,0,0,0,-0.216251958780686,0,0,0,0,0,0,0,0,0,0,-0.217922545469527,0,0,0,1,0,0,0,0,0,0,0,0,0;0,0,0,-0.328637245565614,0,-0.237188250184174,0,0,0,0,0,-0.216251958780686,0,0,0,0,0,0,0,0,0,0,-0.217922545469527,0,0,0,1,0,0,0,0,0,0,0,0;0,0,0,0,-0.264731995680004,0,-0.239503515240022,0,0,0,0,0,-0.245153593051656,0,-0.250610896028318,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0;0,0,0,0,0,-0.264731995680004,0,-0.239503515240022,0,0,0,0,0,-0.245153593051656,0,-0.250610896028318,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0;0,0,0,0,0,0,-0.254422503023168,0,-0.372639023830853,0,0,0,0,0,-0.372938473145979,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0;0,0,0,0,0,0,0,-0.254422503023168,0,-0.372639023830853,0,0,0,0,0,-0.372938473145979,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0;-0.401586836883623,-0.401586836883623,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.196826326232754,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.238745242012679,-0.216713698261725,0,0,0,0,-0.272270529862798,-0.272270529862798,0,0,0,0,0,0,0,1,0,0;0,0,0,0,0,0,0,0,-0.206384741946864,-0.206384741946864,0,0,0,0,0,0,0,0,-0.319126865315220,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,-0.268103650791052;0,0,0,0,0,0,0,0,-0.344604135617391,-0.344604135617391,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.310791728765217,1];
        sp1=1;
    else
        fprintf('Unable to match number of channels with channel list for making wiremap\n')
        sp1=0;
        %         return
    end
    
    if sp1
    subplot(numrows,numcols,1);
    opts.headmap_style=0;%plot 2D
    eegp_wireframe(Hjorth,ChannelOrderHjorth,opts);
    set(gca,'YTickLabel',[],'XTickLabel',[]);
    %have the legend put a green line at each connection tested
    wireframe_data.pairlabel=dh.coh{1}.pairs(index_selected,:);
    wireframe_data.paircolor=repmat([0 1 0],size(dh.coh{1}.pairs,1),1); %make same size as number of labels
    wireframe_data.pairwidth=repmat(5,size(dh.coh{1}.pairs,1),1);
    eegp_wireframe_data(wireframe_data,opts); %to put the lines on
    end
    
    if dh.numSpec==2
        plottingFreqIndecesTGT=(dh.TGToutput{1}.f>=plottingRange(1) & dh.TGToutput{1}.f<=plottingRange(2));
    end
    plottingFreqIndeces=(dh.coh{1}.f>=plottingRange(1) & dh.coh{1}.f<=plottingRange(2));%in future may need different one for spectra2 if different snippet lengths or fpass


    for j=2:numPlots
        ii=index_selected(j-1);%the index to use below
        subplot(numrows,numcols,j);
    %     set(gca,'xtick',[0:5:plottingRange(2)]); %this sets the xticks every 5
        grid off; %this turns grid off
        hold('all'); %this is for the xticks and grid to stay on
        fpFI1=dh.coh{1}.f(plottingFreqIndeces); %just to make coding of fill easier, means frequencies at plotting freq indeces for spectra1
        %3/19/11 suppress error bars since not calculated to save time
         errorBars1=fill([fpFI1 fpFI1(end:-1:1)],[dh.coh{1}.Cerr{ii}(1,(plottingFreqIndeces)) fliplr(dh.coh{1}.Cerr{ii}(2,(plottingFreqIndeces)))],'r','HandleVisibility','off');
         set(errorBars1,'linestyle','none','facealpha',0.2); %to make the fill transparent
    %     set(errorBars1,'EdgeColor','r','facealpha',0.2); %for Theresa
        hold on;
        plot(dh.coh{1}.f(plottingFreqIndeces),dh.coh{1}.C{ii}(plottingFreqIndeces),'r','LineWidth',2); 
        if dh.numSpec>1 
             errorBars2=fill([fpFI1 fpFI1(end:-1:1)],[dh.coh{2}.Cerr{ii}(1,(plottingFreqIndeces)) fliplr(dh.coh{2}.Cerr{ii}(2,(plottingFreqIndeces)))],'b','HandleVisibility','off');
              set(errorBars2,'linestyle','none','facealpha',0.2); %to make the fill transparent
    %         set(errorBars2,'EdgeColor','b','facealpha',0); %For Theresa
            plot(dh.coh{2}.f(plottingFreqIndeces),dh.coh{2}.C{ii}(plottingFreqIndeces),'b','LineWidth',2); 
            if dh.legendon
                legend(dh.coh1label,dh.coh2label);
            end
            if dh.numSpec==2 %put if TGT is <0.05                 
                plot(dh.TGToutput{ii}.f(plottingFreqIndecesTGT),(.15*(dh.TGToutput{ii}.p(plottingFreqIndecesTGT)<=0.05))-.1,'k*','MarkerSize',12); 
            end
            if dh.numSpec==3
              errorBars3=fill([fpFI1 fpFI1(end:-1:1)],[dh.coh{3}.Cerr{ii}(1,(plottingFreqIndeces)) fliplr(dh.coh{3}.Cerr{ii}(2,(plottingFreqIndeces)))],'g','HandleVisibility','off');
              set(errorBars3,'linestyle','none','facealpha',0.2); %to make the fill transparent
              plot(dh.coh{3}.f(plottingFreqIndeces),dh.coh{3}.C{ii}(plottingFreqIndeces),'g','LineWidth',2);
            end
        end
        axis([plottingRange(1) plottingRange(2) 0 1]);
%         set(gca,'xtick',(plottingRange(1):5:plottingRange(2))); 
        set(gca,'FontSize',12); %for paper figure
        axis manual;
        graphtitle=sprintf('%s vs %s',dh.coh{1}.pairs{ii,1},dh.coh{1}.pairs{ii,2});
        text('Units','normalized','Position',[.5 .9],'string',graphtitle,'FontSize',14,'HorizontalAlignment','center');
    %     title(graphtitle,'FontSize',14); %not good since gets hidden by
    %     x-axis above

    end

        allowaxestogrow;
    %%  
%     saveFigureAs=sprintf('%s _Coh',figuretitle);
%     saveFigureAs(saveFigureAs==' ')=[]; % to remove spaces in the filename of the figure
%     saveas(Cohfigure,saveFigureAs,'fig');%to save the figure
    end
end