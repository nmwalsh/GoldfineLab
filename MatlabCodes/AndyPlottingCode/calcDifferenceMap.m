function calcDifferenceMap(savename,PSfilename1,pathname1,PSfilename2,pathname2,TGTfilename, TGTpathname)

%loads in mat file containing a variable which is spectraByChannel as
%created by batCrxSpectra (already converted to dB). Calculates difference
%at each frequency between two conditions. Then shuffles the conditions
%(always the same number in each group) and calcaultes the difference at
%each shuffle. p-value is calculated by ranking the actual compared to the
%shuffled differences. 
%
%to plot the results, use plotDifferenceMap
%
%version 2 9/2/10 allows for calcDifferenceMapBat
%version 3 3/21/11 uses p-value from TGT rather than recalculating
%[] might want to put this code into PSeeglab so runs automatically
%version 4 7/27/11 saves a different f for the p-value since is different
%when from the TGT. Previously was wrong but found by Bardin.
%version 5 12/5/11 [x] change f to be regular f since no longer using ULT;
%[x] use S instead of spectraByChannel; %[] have this called by
%subplotEeglabSpectra and save in the TGToutput file to make it run
%automatically (requires giving code an output!; %[]modify plotDifferenceMap to be able to call the TGToutput
%file instead of the diff file. 

if nargin<1
    savename=input('Savename: ','s');

    [PSfilename1, pathname1] = uigetfile('*PS.mat', 'Select 1st power spectra data');
    [PSfilename2, pathname2] = uigetfile('*PS.mat', 'Select 2nd power spectra data',pathname1);
    [TGTfilename, TGTpathname] = uigetfile('*sList.mat', 'Select TGT output',pathname1);
end
%3/21/11 spectrabyChannel was calculated by batCrxSpectra using mtspectrumc which
%has tapers of -1 so not the same as S. Requires fMtSpectrumc but at least
%should line up with the TGT output f!
PS1=load(fullfile(pathname1,PSfilename1),'S','f','numChannels','ChannelList','frequencyRecorded','params');
PS2=load(fullfile(pathname2,PSfilename2),'S','f','numChannels','ChannelList','frequencyRecorded','params');
TGT=load(fullfile(TGTpathname,TGTfilename),'TGToutput');
TGToutput=TGT.TGToutput;

if ~isequal(size(PS1.S,1),size(PS2.S,1)) %if different number of frequencies used
    disp('spectra have different number of frequency points, may have been calculated with different fpass or on different length swatches of data, need to modify code to work');
    return
end
%%
%this is to cut out the extra channels if one is 37 and other is 29.
%Don't need to fix alignment of frequencies if all data are calculate with
%fpass 0 to 100
%copied from subplotSpectra with the additional lines modifying
%spectraByChannel which weren't modified for that code.
if ~isequal(PS1.numChannels,PS2.numChannels)
%     unequal=1; 
    disp('Different number of channels in the spectra, will change the one with 37 to be 29 like the other');
    if PS1.numChannels==29 %PS1 is "correct" so reorder PS2
        PS2.numChannels=29;
        ChannelList=PS1.ChannelList;
        for io=1:length(ChannelList) %for each channel in right one, ChannelList is 1x29
            orderIndex=strcmpi(PS1.ChannelList{io},PS2.ChannelList); %find Channel of PS1 in PS2, gives logical vector, may need to transpose below
%             PS2.S_ro(:,io)=PS2.S(:,orderIndex); %dataxchannel
%             PS2.Serr_ro(:,:,io)=PS2.Serr(:,:,orderIndex); %2xdataxchannel
%             PS2.dataCutByChannel_ro{io}=PS2.dataCutByChannel{orderIndex}; %cell, not used yet, will need to modify batTGT
            PS2.S_ro(:,io)=PS2.S(:,orderIndex);
        end
%         PS2.S=PS2.S_ro;
%         PS2.Serr=PS2.Serr_ro;
%         PS2.dataCutByChannel=PS2.dataCutByChannel_ro;
        PS2.S=PS2.S_ro;
    else %if PS2 is 29 channels (correct one)
        PS1.numChannels=29;
        ChannelList=PS2.ChannelList;
        for io=1:length(PS2.ChannelList) %for each channel in wrong one, ChannelList is 1x29
            orderIndex=strcmpi(PS2.ChannelList{io},PS1.ChannelList); %gives logical vector, need to transpose below
%             PS1.S_ro(:,io)=PS1.S(:,orderIndex); %dataxchannel
%             PS1.Serr_ro(:,:,io)=PS1.Serr(:,:,orderIndex); %2xdataxchannel
%             PS1.dataCutByChannel_ro{io}=PS1.dataCutByChannel{orderIndex}; %cell
            PS1.S_ro(:,io)=PS1.S(:,orderIndex);
        end
%         PS1.S=PS1.S_ro;
%         PS1.Serr=PS1.Serr_ro;
%         PS1.dataCutByChannel=PS1.dataCutByChannel_ro;
        PS1.S=PS1.S_ro;
    end
end

%%

    %spectraByChannel's length is number of channels not number of snippets.
    %Tags needs to be number of snippets
    numChan=size(PS1.S,2);
    numFreq=size(PS1.S,1);

    actualDiff=cell(1,numChan); %partway initialized
    p_value=cell(1,numChan);

    for s=1:numChan %for each Channel
        actualDiff{s}=PS1.S(:,s)-PS2.S(:,s);
%         actualDiff{s}=mean(PS1.spectraByChannel{s},2)-mean(PS2.spectraByChannel{s},2);
        p_value{s}=(2*(1-normcdf(abs(TGToutput{s}.dz),0,TGToutput{s}.vdz)))';
       
    end

    %%
    %save results, include freq, fMtSpectrumc, actual and shuffled Diff
     freqRecorded=PS1.frequencyRecorded;
    f=PS1.f;
    f_pvalue=TGToutput{1,1}.f;
    ChannelList=PS1.ChannelList;
    params=PS1.params;
    save([savename '_Diff.mat'],'params','actualDiff','f','f_pvalue','freqRecorded','p_value','ChannelList')


    



        