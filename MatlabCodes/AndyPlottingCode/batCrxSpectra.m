function [spectraByChannel,fMtSpectrumc,dataCutByChannel,neighborTag] = batCrxSpectra(varargin)

%type batCrxSpectra('file.crx','montagename','SaveNameForTheOutput',flagToSkipCrxInpu)
%will take snippets from a .crx, cut them to length in seconds defined by cutLength (cropping off any additional), 
% and produce variables with each cut datastrip ordered by channel (for two sample test) and 10log10(spectra) ordered by 
%channel (for Fisher discriminant). Output is saved as a .mat file in the
%current folder.
%
%This code is called by batCrxULT which allows to run on multiple spectra
%via call from batCrxULT_UI. Enter data from batCrxULT as 4th variable so this program wont run again.
%
%Next step is to create a new UI version that will allow me to run this on
%multiple .crx files. Or just call this from within batCrxULT.
%Either will need to define montage in that version, or have the program look at the value of headbox or freq recorded and pick the corect laplacian
%from the data.
%
%This program originally created by Ravi so some of his code that isn't
%relevant still here. 
%
%
%version 1 1/7/10 created, updated with code for two_sample_test on 1/12/10. Based on batCrxULT 
%version 1.1 2/8/10 adding code to create tag (neighborTag) signifying which cuts are
                    %neighbors (from same snippet) for use in fisherdisc
%version 1.2 2/17/10 added line to detrend the data to make results from
             %this (two group test and fisher) compatible with mtspectrumc_ULT which
             %detrends the data.
%version 1.3 2/18/10 removing option to get data directly from
             %batCrxULT since doesn't save much time. And now gets params
             %from batCrxULT and runs mtspectrumc manually using them so
             %don't have to modify in the browser
%v 1.4 reverting to taking data in matrix format so can run from
            %eeglabSpectra
            
            
%%

      %read data in from crx      
 if (nargin < 1)
     fprintf('need to give the pathname for a .crx file to work\n')
     return
 else 
     sPath              = varargin{1};
 end     
         
 if nargin>5
     data=varargin{6}; %take data from batCrxULT as a cell array with 1 cell per channel
     frequencyRecorded=varargin{7};
 else
    [hdr oRetVal]          = ReadChronuxFormatCrxData('Read_header',sPath, 1); % browser >115 needs this to be 1.
    if ~oRetVal 
    s = sprintf('Error in getting crx header for %s.', sPath);             
    display (s);
    end

     %Here define the montage type to use
     if nargin>1
             montage.Type=varargin{2}; %AG - this means you define the montage when you call the code with the 2nd input variable
         else
         montage.Type = 'LaplacianEKDB12'; %AG - here can define montage type if not sent in by batCrxULT_UI or in command
         fprintf('montage %s used, ensure correct for headbox.\n',montage.Type);
      end;

     snipCount              = 1;

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
         %ch{1}           = 'Fp1-F3'; %this is an example of picking
         %two channels, or can put (1:2) at end above for debugging
         %ch{2}           = 'F3-C3';
         [dat retval] = ncon('load', 'dat', hdr, tm, tr, ch, montage);   %AG - this reads the crxData from the crx based on the montage           
            %[dat oRetVal]          = ReadChronuxFormatCrxData('Read_Data', hdr, tm, tr, ch, montage); % the 1 indicates the snippet number. 
         if ~oRetVal 
            s = sprintf('Error in loading crx snippet(%d)data.', snipCount);             
            display (s);
         end


         data(snipCount) = dat.modData; %initially had {snipCount} in {} but put a cell in a cell. With (snipCount) is 1 layer cell. This is 
         %different from batCrxULT! But confirmed that it comes out the
         %same.
         frequencyRecorded=dat.aux.Common.Fs; %AG - also used for plotting in subplotSpectra
     end;
 end

%%
% detrend the data which means to remove a running line fit. This can be a
% demeaning of the data (the mean is 0) but if the data moves along a line
% it will remove the line fit. This is performed in
% mtspectrumc_unequal_length_trials. It's especially necessary for EMU32
% headbox.

for i=1:length(data)
    data{i}=detrend(data{i});
end;

%%

     %Next cut the snippet data to all the same length and
     %discard remainder

     
     if nargin>4
         cutLength=varargin{5}; %assigns the moving window in sec from batCrxULT
     else
         cutLength=3; %for cutting all to same length
     end
     dataCut=[]; %so that starting columnsInData is 0
     nt=1; %so starting neighbortag index is 1
     numChannels=size(data{1},2);

     for i=1:length(data) %for each snippet, each in a different cell of data
         cellsInDatacut=size(dataCut,2); %gives the number of cells (as columns) already created to use to add to next cell, starts at 0
         neighborTag{nt}=[];

         if length(data{i})/frequencyRecorded<cutLength %this ensures that all snippets are longer than required
             fprintf('snippet %g is less than the cutLength\n',i)
             %return % return would exit the program but probably not necessary
             nt=nt-1; %since this doesn't create a dataCut so don't want to end up with a []
         elseif length(data{i})/frequencyRecorded>cutLength %for those too long, remove the extra, reshape and then reassign to datacut
             numberOfCuts=floor(length(data{i})/(cutLength*frequencyRecorded)); 
             dataShortened=[]; %since will reuse each time

             dataShortened=data{i}(1:cutLength*numberOfCuts*frequencyRecorded,:); %now have divisible data that can resize. creates a matrix so need to assign to a cell

             dataShortenedReshaped=reshape(dataShortened',numChannels,cutLength*frequencyRecorded,numberOfCuts); %this makes each cut into a 3D plane 
             %where it becomes channels x cutLength of data x number of cuts.
             %Reshape needs to be run on transposed data since it works columnwise. (takes
             %end of column and puts next to previous column).

              for j=1:numberOfCuts
                   dataCut{cellsInDatacut+j}=dataShortenedReshaped(:,:,j)'; %note here it's transposed back to be datapointsxchannels. 
                   %We're using one z-axis plane at a time.    
                   neighborTag{nt}=[neighborTag{nt} cellsInDatacut+j]; %starts empty each time then first entry to cell is total number of cuts +1
              end;                        
         elseif length(data{i})/frequencyRecorded==cutLength
             dataCut{cellsInDatacut+1}=data{i}; %this dataCut can be used for Hemant's two sample test code as well though need to change to by channel
             neighborTag{nt}=cellsInDatacut+1; %to assign it this one value though actually not necessary
         end              
         nt=nt+1; % to increase the index for neighborTag
     end
             
%%
 %next we'll convert dataCut to dataCutByChannel to use for
 %two_sample_test

 for i=1:numChannels %for each channel
   for j=1:length(dataCut); %for each cut equal length snippet
    dataCutByChannel{i}(:,j)=dataCut{j}(:,i);
   end
 end  
             
%%
%next loop is calculate spectra and assign output to spectraByCut and/or
%spectraByChannel.
            
params=varargin{4};
params.err(1)=0; %since don't need error bars for batFisher
for i=1:length(dataCut)
    [S{i} f{i}]=mtspectrumc(dataCut{i},params);
    spectraBySnippet{i}=10*log10(S{i});
end
fMtSpectrumc=f{1};             
%%

%here convert spectra to by channel for JVictor's Fisher
%discriminant analysis
         
for i=1:numChannels %for each channel
   for j=1:length(spectraBySnippet); %for each snippet
    spectraByChannel{i}(:,j)=spectraBySnippet{j}(:,i); %changed from original version which was .channel{i}):,j)=...
   end
end  

%%
%these are all defined to be the same as the browser exports
%so subplotSpectra can read them in directly

%               params=oRoutineDetails.Input.Params(1,2).DataValue; %AG - this is a structure
fprintf('cut spectra created with %d tapers and %d sec cutlength from %g to %g Hz\n',params.tapers(2),cutLength,frequencyRecorded*params.fpass(1),frequencyRecorded*params.fpass(2));
if nargin>2 && isnumeric(varargin{3}) %don't need variables below if called from batCrxULT
    return %exit this code at this point and return to batCrxULT

    if nargin <7 %if data from batCrxULT
        channelFormulas=ch; %AG - this is direcly used in subplotSpectra. Here used for Laplacian to show formulas
        channellist=montage.Type; %AG - in subplotSpectra this can be used
        if strcmp(channellist,'LaplacianEKDB12') %to create a list of names for easier plotting later
          channellabels={'Fp1','Fp2','AF7','AF8','F7','F3','Fz','F4','F8','FC5','FC1','FC2','FC6','T3','C3','Cz','C4','T4','CP5','CP1','CP2','CP6','T5','P3','Pz','P4','T6','O1','O2'};
        elseif strcmp(channellist,'LaplacianEMU40')
          channellabels={'FPz','Fp1','Fp2','AF7','AF8','F7','F3','F1','Fz','F2','F4','F8','FC5','FC1','FC2','FC6','T3','C3','Cz','C4','T4','CP5','CP1','CPz','CP2','CP6','T5','P3','Pz','P4','T6','PO7','O1','POz','Oz','O2','PO8'};
        end;

f{1,1}=f{1}; %f from first cut


    end          
              
%              
%%
%save only if 3rd input isn't a number (if it's a number, (e.g. set as 0 from
%batCrxULT) then end the program and just give up the variables to calling
%funciton.

              if nargin>2 && isnumeric(varargin{3}) %this will happen for eeglabSpectra too
                return
              elseif nargin>2
                  savename=varargin{3};
                  save(savename,'params','channellabels','channelFormulas','fMtSpectrumc','channellist','frequencyRecorded','spectraByChannel','dataCutByChannel');
              else
                  savename=[varargin{1}(1:end-4) '_spectraByLaplacianChannel'];
                  save(savename,'params','channellabels','channelFormulas','fMtSpectrumc','channellist','frequencyRecorded','spectraByChannel','dataCutByChannel');
              end
                  
%               save(savename,'params','channelLabels','channelFormulas','f','channellist','frequencyRecorded','spectraByChannel','dataCutByChannel')
%              %this save doesn't save spectrabysnippet though could add it
%              if useful
             
             
end              
                    
           
          