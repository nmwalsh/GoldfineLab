function batSpectrogram(varargin)

%[] set defaults for params and moving win. Fs is important here.
%1. load in crx file (can set this to run on multiple at once, can do with
%multiselect on rather than creating a loop)
%2. montage crx files
%3. loop to run spectrogram on each channel across all the datasets with
%averaging
%4. plot (may want this to be a separate code called subplotSpectrogram)
%
%add savename for plot later
%
%This code requires all data to be the same length. So would need to
%reexport datasets if they were used with different length cuts.


%%
%set defaults
% Set params for mtspecgramc 
 params.tapers=[3 5];
 fpassInHz=[0 100];
 params.pad=-1;
%  params.Fs=1; %need to define this from data later in code
 params.err=[2 0.05];
 params.trialave=1; %can change to 0 to look at one snippet at a time.
 movingwinInSec=[1 0.05];

 disp('Would you like to use default parameters for mtspecgram?');
 disp(params);
 fprintf('    fpass (in Hz): [%.0f %.0f]\n',fpassInHz(1), fpassInHz(2));
 fprintf('    movingwin (in sec): [%.2f %.2f]\n',movingwinInSec(1), movingwinInSec(2));
 default = input('Return for yes (or n for no): ','s');
 if strcmp(default,'y') || isempty(default)
 else
     disp('define params (Return leaves as default)');
     p.tapers1=input('NW:');
     if ~isempty(p.tapers1)
         params.tapers(1)=p.tapers1;
     end
     p.tapers2=input('K:');
     if ~isempty(p.tapers2)
        params.tapers(2)=p.tapers2;
     end
     p.pad=input('pad:');
     if ~isempty(p.pad)
         params.pad=p.pad;
     end
     p.err1=input('error type (1 theoretical, 2 jacknife):');
     if ~isempty(p.err1)
         params.err(1)=p.err1;
     end
     p.err2=input('p-value:');
     if ~isempty(p.err2)
         params.err(2)=p.err2;
     end
     fpass1=input('starting frequency of fpass:');
     if ~isempty(fpass1)
         fpassInHz(1)=fpass1;
     end
     fpass2=input('ending frequency of fpass:');
     if ~isempty(fpass2)
         fpassInHz(2)=fpass2;
     end
     p.mwinsec=input('moving win (in seconds in brackets like [1 0.1]):');
     if ~isempty(p.mwinsec)
         movingwinInSec=p.mwinsec;
     end
     fprintf('\nparams are now:\n');
     disp(params);
     fprintf('movingwin (in sec): [%.2f %.2f]\n',movingwinInSec(1), movingwinInSec(2));
 end


%%
%choose crxfiles and montage(s)

[crxfiles, pathname1] = uigetfile('*.crx', 'Select crx files to analyze','MultiSelect','on'); %this will load the crx's to a cell array
%though they all need to be in the same path since it only produces one
%path name.

%To choose montage (allows one montages)
[montagelist, pathname2] = uigetfile('*.xml', 'Select montage name from folder','C:\Documents and Settings\Andrew Goldfine\My Documents\EEGResearch\Build112_19Oct2009\ndb\XML\Config XML\Montage\EEG\');
montagelist=montagelist(1:end-4); %if use more montages will need to make this a loop

%if load none, it appears as a 0 so this tells the program to end
if ~iscell(crxfiles)&&~ischar(crxfiles)
    return; 
end;

%if only 1 crx or montagelist, it gets loaded as a string and need to convert to a cell for
%later
if ~iscell(crxfiles);
    crxfiles=cellstr(crxfiles);
end;

% if ~iscell(montagelist);
%     montagelist=cellstr(montagelist);
% end;


    

%%
%Run spectrogram with loop being per crxfile and within need loop for each
%channel.

for crx=1:length(crxfiles)
    
    %load the crx file and montage it
    sPath=fullfile(pathname1,crxfiles{crx});
    [hdr oRetVal] = ReadChronuxFormatCrxData('Read_header',sPath, 1); % browser >115 needs this to be 1.
    if ~oRetVal 
    s = sprintf('Error in getting crx header for %s.', sPath);             
    display (s);
    end

    %Here define the montage type to use
    montage.Type=montagelist;
%     if nargin>1
%              montage.Type=varargin{2}; %AG - this means you define the montage when you call the code with the 2nd input variable
%     else
%          montage.Type = 'LaplacianEKDB12'; %AG - here can define montage type if not sent in by batCrxULT_UI or in command
%          fprintf('montage %s used, ensure correct for headbox.\n',montage.Type);
%     end;

%     snipCount              = 1; %don't see why this is necessary, may be
%     able to delete
    data=cell(1,hdr.Specific.Info.Count); %this preallocates cells but need to preallocate contents if possible
    
    for snipCount = 1:hdr.Specific.Info.Count %AG - this is a loop so reads all snippets
         [crxData oRetVal]     = ReadChronuxFormatCrxData('Read_Data', hdr, snipCount); %data changed to crxData
         hdr                = crxData.aux;   
         %ncon('get','mont','GETGROUPDETAILSFORSELECTEDMONTAGESCHEMA',selMontageType, selMontageSchema, Hdr);

         montage.Schema = montage.Type; %some of the default montages have schema. Not any that we created

         [oMontageGroupData oRetVal] = ncon('get','mont','GETGROUPDETAILSFORSELECTEDMONTAGESCHEMA',montage.Type, montage.Schema, hdr);
         % Get the channel combos   
         [oData oRetVal] = ncon('get','mont','GETCHNLCOMBOFROMGROUPDETAILS',oMontageGroupData.MontageGroupDetails, hdr);
         tm              = []; %AG - time samples, [] means take all samples like in browser
         tr              = 1; %AG - number of trials, always 1 for xltek like in browser

         %AG - here you choose the channels from the montage you want
         %to run on. 
         ch = oData.ChnlComboList.Label; %AG added this line to run on all channels, though could choose subset (i.e. for coherence)
         
         %to ensure you exported all the channels
         if length(ch)<3
             if ~strcmp(input('Crx file has <3 channels, would you like to continue? (y-yes)','s'),'y')
                 return
             end
         end
         
         [dat retval] = ncon('load', 'dat', hdr, tm, tr, ch, montage);   %AG - this reads the crxData from the crx based on the montage           
            %[dat oRetVal]          = ReadChronuxFormatCrxData('Read_Data', hdr, tm, tr, ch, montage); % the 1 indicates the snippet number. 
         if ~oRetVal 
            s = sprintf('Error in loading crx snippet(%d)data.', snipCount);             
            display (s);
         end


         data(snipCount) = dat.modData; %initially had {snipCount} in {} but put a cell in a cell. With (snipCount) is 1 layer cell. This is 
         %different from batCrxULT! But confirmed that it comes out the
         %same.
         
         frequencyRecorded=dat.aux.Common.Fs; %define frequency recorded from data
         clear dat %to open up memory

    end;
    
    %detrend the data to remove running line fit
    for id=1:length(data)
        data{id}=detrend(data{id}); %won't preallocate since already exists and just changing
    end;
    
    
%%
    %next make the matrices organized by channel rather than by snippet so
    %can run mtspecgramc on each channel.
    
    %put in code to calculate min num samples. determine num rows in each
    %cell of data, see if can do all at once or else need to do as loop,
    %then assign min to a variable and put that variable below where 3000
    %is. Do this in batSpectra and possibly batCrxULT as well!
    
    numdatapoints=cell(1,length(data));
    for is=1:length(data)
        numdatapoints{is}=size(data{is},1);
    end
    minnumdatapoints=min(cell2mat(numdatapoints)); % to ensure all data same num samples below
    
    numChannels=size(data{1},2);
    dataByChannel{1}=zeros(size(data{1},1),length(data)); %preallocate contents of cell
    dataByChannel=repmat(dataByChannel,1,numChannels); %preallocate all the cells
    
    for i=1:numChannels %for each channel (columns of data)
        for j=1:length(data); %for each equal length snippet (cells of data)
            dataByChannel{i}(1:minnumdatapoints,j)=data{j}(1:minnumdatapoints,i); %if error occurs here, ensure all data are same length
        end
    end  
    clear data

    
    params.Fs=frequencyRecorded;
    movingwin=movingwinInSec; %is in units of sec since Fs is in Hz
    params.fpass=fpassInHz; %since Fs is in Hz, this is also in Hz
    disp('Running mtspecgramc');                                

    %need mtspegramc to run for each channel, then when done, be run for each
    %crx file separately. don't want to end up with no memory since running on
    %multiple crx files. so can move this to a new code with UI at the end but
    %then need to pass params.
    
    for ic=1:numChannels
        [S{ic},t{ic},f{ic},Serr{ic}]=mtspecgramc(dataByChannel{ic},movingwin,params);
    end
    
    if strcmp(montagelist,'AvgRefEKDB12') || strcmp(montagelist,'LaplacianEKDB12');
    ChannelList={'Fp1','Fp2','AF7','AF8','F7','F3','Fz','F4','F8','FC5','FC1','FC2','FC6','T3','C3','Cz','C4','T4','CP5','CP1','CP2','CP6','T5','P3','Pz','P4','T6','O1','O2'};
    elseif strcmp(montagelist,'AvgRefEMU40') || strcmp(montagelist,'LaplacianEMU40');
    ChannelList={'FPz','Fp1','Fp2','AF7','AF8','F7','F3','F1','Fz','F2','F4','F8','FC5','FC1','FC2','FC6','T3','C3','Cz','C4','T4','CP5','CP1','CPz','CP2','CP6','T5','P3','Pz','P4','T6','PO7','O1','POz','Oz','O2','PO8'};
    else
    ChannelList=ch;
    end
    
    savefilename=sprintf('%s_%s_SG',crxfiles{crx}(1:end-4),montagelist);
    save (savefilename,'S','t','f','Serr','ChannelList','params','movingwinInSec');
    
    clear S t f Serr dataByChannel ChannelList


end


