% catdata.m
% main script to process output of load1section.m
% here te data of several/all sections is read and formatted to the final format to be input in the database tables.
% Final formatting is not done in load1section.m due to keep resilience of code and bugtracking to original data (.docx file)
clear
% SECTIONS TO BE LOADED:
sections=[1;2;7;10]; % Give  the data in the for of a column array (; separated elements) of integers corresponding to the main sections of original document: 1,2,3,4,...21 or just the desired sections
rootpath='/home/diego/Development/DB/INPUT/ORIGINAL/SECTIONS';
% Cell array with all input paths (output of load1section.m):
for i=1:length(sections)
	paths{i,1}=[rootpath,num2str(sections(i)),'/OUT/'];
end

outpath=['/home/diego/Development/DB/INPUT/ORIGINAL/SECTIONS/II.CAT_RESTRUCT/OUT/'];
mkdir(outpath)
outl1file='1.L1_RegionsList.csv';
outl2file='2.L2_RegionsList.csv';
outconnecfile='3.Connections.csv';
outreffile='4.References.csv';
outchemfile='5.Chemicals.csv';
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% READING 6.OUT_ROI_IDs  FILES (roi-id roi-name  roi-abbs OF ALL SELECTED SECTIONS AND ASSIGNMENT OF GLOBAL ID FOR ROIs:

roidtable=readtable([paths{1,1},'6.OUT_ROI_IDs.csv']);
% Reading and catenation:
for i=2:length(sections)
	roidtable=union( roidtable, readtable([paths{i,1},'6.OUT_ROI_IDs.csv']) );
end

% Assignment of global index:

newRoiID=[1:1:size(roidtable,1)]'; % new ROI IDs
RoiID=roidtable{:,1};			% old ROI IDs

T1=table(newRoiID, RoiID);

roidtable=join(T1, roidtable, 'Keys', 'RoiID'); % addition of new IDs column to roidtable
%roidcell=table2cell(roidtable);

% Separate L1 and L2 ROIs in different tables:
il1=0;
il2=0;
for i=1:size(roidtable,1)
	if mod(roidtable{i,2},10000)==0
		il1=il1+1;
		l1table(il1,:)=roidtable(i,:);
	else
		il2=il2+1;
		l2table(il2,:)=roidtable(i,:);
	end
end

% Reindex each table separately

newL1ID=[1:1:size(l1table,1)]'; % new L1 IDs
newL2ID=[1:1:size(l2table,1)]'; % new L2 IDs

newRoiID=l1table{:,1};			% new ROI IDs
T1=table(newL1ID, newRoiID);
l1table=join(T1, l1table, 'Keys', 'newRoiID'); % addition of new IDs column to roidtable

newRoiID=l2table{:,1};			% new ROI IDs
T1=table(newL2ID, newRoiID);
l2table=join(T1, l2table, 'Keys', 'newRoiID'); % addition of new IDs column to roidtable


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% READ FILES 1.OUT_RelatedRegions.csv FOR LOADED SECTIONSTO GET A COMPLETE BUT REDUNDANT TABLE (WITH REPETITIONS) OF L2 REGIONS
% Load one section at a time to temporal cell array and write to table. Do not overload memory buddy!

l1cell=table2cell(l1table);
l2cell=table2cell(l2table);
lastl2=size(l2cell,1);

n=0;
for i=1:length(sections)			
	temptable=readtable([paths{i,1},'1.OUT_RelatedRegions.csv']);
	tempcell=table2cell(temptable);
	for j=1:size(tempcell,1)
		for k=1:size(l2cell,1)
			if strcmp(tempcell{j,3}, l2cell{k,4})==false
				%j
				%k
				%tempcell{j,2}
				n=n+1;
				l2cell{lastl2+n,1}=lastl2+n; % New index for all L2 sections
				l2cell{lastl2+n,4}=tempcell{j,2}; % Name
				l2cell{lastl2+n,5}=tempcell{j,3}; % Abbreviation
				l2cell{lastl2+n,6}=tempcell{j,4}; % containing L1 region
				break

			end
		end
	end
end

%l2redundtable=cell2table(l2cell, 'VariableNames', {'L2regionID';'L1L2regionID';'IDasROI';'regionNAME';'regionABBREVIATION';'containedinL1'}); % Write to table format to export easily to file

% Writing name of containing L1 region for L2 regions found as ROIs:

i=1;
while isempty(l2cell{i,3})==false
	inl1id=10000*round(l2cell{i,3}/10000);
	%rem(l2cell{i,3},10000)
	for j=1:size(l1cell,1)
		if inl1id==l1cell{j,3}
			l2cell{i,6}=l1cell{j,4};
			break	
		end
	end
	i=i+1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Now that there are:
% L1 table: all regions found as ROIs in the loaded sections. No repeated regions regions are expected here because each row from ROI data (original document sections)
% L2 table: found as ROIs and also as related regions to ROIs. Repeated regions are expected here because the same region can be related to different ROIs. 

% MAKE L2 TABLE WITH NO REDUNDANCY: redundancy is tested by comparing region abbreviations (only). Comparing strings with names is rather difficult because the same region has been named in slightly different ways including sometimes commas, etc. The first entry found will be kept as the name for the given L2 region.




l2abbs=l2cell(:,5); % copy only abbs
[l2unqabbs, il2abbs, il2unqabbs ]=unique(l2abbs); % find unique elements (with no repetitions) in abbs and their indices in l2cell (il2abbs)

% Make l2unqcell with only the unique regions (non-repeated ones):
for i=1:length(il2abbs)
	%disp( [num2str(i),' ',num2str(il2abbs(i))] )
	out.cells.l2unqcell(i,:)=l2cell(il2abbs(i),:);
end
out.cells.l2unqcell(:,4)=upper(out.cells.l2unqcell(:,4)); % set all L2 names to upper case
out.cells.l2unqcell(:,6)=upper(out.cells.l2unqcell(:,6)); % set all names of L1 containing regions to upper case

% Get rid of words like definite article 'THE' and empty unseen spaces. AIM: get rid of syntax in names!!!
for i=1:size(out.cells.l2unqcell, 1)
	temp=strsplit(out.cells.l2unqcell{i,6});
	if length(temp)>1
		out.cells.l2unqcell{i,6}=temp{1};
		for j=2:length(temp)
			if strcmp(temp{j},'THE')==0 & isempty(temp{j})==0
				out.cells.l2unqcell{i,6}=[out.cells.l2unqcell{i,6}, ' ',temp{j}];
			end
		end
	else
		out.cells.l2unqcell{i,6}=temp{1}; 
	end
end

% Treat some special specific cases:
% 1. 'OTHER BRAIN REGION' and 'OTHER BRAIN REGIONS': this is taken as the same and name used will be in plural

for i=1:size(out.cells.l2unqcell, 1)
	if strcmp(out.cells.l2unqcell{i,6}, 'OTHER BRAIN REGION')
		out.cells.l2unqcell{i,6}='OTHER BRAIN REGIONS';
	end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% L1 TABLE WITH UNIQUE REGIONS (found as ROIs or related regions):

% Now from table with L2 tables with unique values, together with the table for L1 ROIs, a list of the all the used L1 regions in document is done and each unique one gets one unique index, in the same fashion as done for L2 regions:

% From L1-ROIs table:
l1cell(:,4)=upper(l1cell(:,4));
% From L2 table:
l1inl2=out.cells.l2unqcell(:,6);
% Cat entries from both sources:
l1inl2=cat(1, l1cell(:,4), l1inl2);

out.cells.l1unqcell=unique(l1inl2); % get rid of exact redundancy
out.cells.l1unqcell=upper(out.cells.l1unqcell); % set all names to upper case
out.cells.l1unqcell=unique(out.cells.l1unqcell); % get rid of redundancy in upper case



% Get rid of words like definite article 'THE' and empty unseen spaces. AIM: get rid of syntax in names!!!
for i=1:size(out.cells.l1unqcell, 1)
	temp=strsplit(out.cells.l1unqcell{i,1});
	if length(temp)>1
		out.cells.l1unqcell{i,1}=temp{1};
		for j=2:length(temp)
			if strcmp(temp{j},'THE')==0 & isempty(temp{j})==0
				out.cells.l1unqcell{i,1}=[out.cells.l1unqcell{i,1}, ' ',temp{j}];
			end
		end
	else
		out.cells.l1unqcell{i,1}=temp{1}; 
	end
end

out.cells.l1unqcell=unique(out.cells.l1unqcell); % get rid of redundancy in upper case and poor syntax list

% Treat some special specific cases:
% 1. 'OTHER BRAIN REGION' and 'OTHER BRAIN REGIONS': this is taken as the same and name used will be in plural

for i=1:size(out.cells.l1unqcell, 1)
	if strcmp(out.cells.l1unqcell{i,1}, 'OTHER BRAIN REGION')
		out.cells.l1unqcell{i,1}='OTHER BRAIN REGIONS';
	end
end

out.cells.l1unqcell=unique(out.cells.l1unqcell); % get rid of redundancy in upper case and poor syntax list and of specific cases

% Set a unique index for unique L1 regions:
temp=num2cell([1:size(out.cells.l1unqcell,1)]'); % create a cell array with the unique indexes

out.cells.l1unqcell=cat(2, temp, out.cells.l1unqcell); % cat indexes to list of unique L1 regions

% Add abbreviations and ROI IDs in L1 table for L1-ROIs:

for i=1:size(l1cell, 1)
	for j=1:size(out.cells.l1unqcell, 1)
		if strcmp(l1cell{i,4}, out.cells.l1unqcell{j,2})
			out.cells.l1unqcell{j,3}=l1cell{i,5}; % Abbreviation
			out.cells.l1unqcell{j,4}=l1cell{i,3}; % ROI ID
			break
		end
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% INDEXING L1 CONTAINING REGIONS IN L2 TABLE: 

% Now that L1 and L2 names are all in upper case and list with unique elements have been obtained, containing L1 regions in L2 table are marked wit the corresponding index of L1 table

for i=1:size(out.cells.l2unqcell, 1)
	found=0;
	for j=1:size(out.cells.l1unqcell, 1)
		if strcmp(out.cells.l2unqcell{i,6}, out.cells.l1unqcell{j,2})
			out.cells.l2unqcell{i,7}=out.cells.l1unqcell{j,1};
			found=1;
			break
		end
	end
	if j==size(out.cells.l1unqcell, 1) & found==0
		disp(['WARNING:			no L1 region found for L2 region in l2unqcell at row ', num2str(i) ])
	end
end

% Set a unique index for unique L1 regions:
temp=num2cell([1:size(out.cells.l2unqcell,1)]'); % create a cell array with the unique indexes

out.cells.l2unqcell=cat(2, temp, out.cells.l2unqcell); % cat indexes to list of unique L1 regions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% WRITE L1 AND L2 TABLES WITH UNIQUE ELEMENTS TO MATLAB TABLES AND TO FILES:

out.cells.l2unqcellheader={'uniqueID';'allL2ID';'RoiID';'RoiInSection';'ShortName';'Abbreviation';'FoundInL1name';'FoundInL1ID'};
out.l2=cell2table(out.cells.l2unqcell, 'VariableNames', out.cells.l2unqcellheader); % Write to table format to export easily to file
writetable(out.l2, [outpath, outl2file]) % Write to file

out.cells.l1unqcellheader={'uniqueID'; 'Name'; 'Abbreviation'; 'RoiInSection'};
out.l1=cell2table(out.cells.l1unqcell, 'VariableNames', out.cells.l1unqcellheader); % Write to table format to export easily to file
writetable(out.l1, [outpath, outl1file]) % Write to file

%clear outl1 outl2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% READING LISTS OF REFERENCES FOR ALL SECTIONS, GETTING RID OF REDUNDANCY AND REINDEXING TO GLOBAL INDEX 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Catenation of the references list of all sections: (this list might be redundant)
in.refslists=readtable([paths{1,1},'5.OUT_ReferenceList.csv']);
in.refslistsflags(1)=size(in.refslists,1);
f=2;
for i=2:length(sections)			
	tempreflist=readtable([paths{i,1},'5.OUT_ReferenceList.csv']);
	in.refslists=union(in.refslists, tempreflist);
	in.refslistsflags(f)=size(in.refslists,1);
	f=f+1;
end

% Get rid of redundancy: identify unique entries by exact name of paper and authors ("bib-entry")and map to 
papers=in.refslists(:,2);
[papersunq, ixpapers, uniqueID]=unique(papers);

for i=1:size(papersunq,1)
	out.refslists(i,:)=in.refslists(ixpapers(i),:); % the unique entries recognized by unique are used to copy whole row to new cell array out.refslists. THis means only one bib-entry of the several with the same bib-entry are kept. This leaves many refs. of related regions orphan because bib-entry matches but location (subsection roiID) does not!!!!!!!!!! However this information is still available in in.refslists
end

% Appending unique index to table:
unqID=array2table([1:size(out.refslists,1)]', 'VariableNames', {'uniqueID'} );
out.refslists=[unqID out.refslists];   									% TABLES CATENATION

% % Write unique IDs to redundant table:
in.refslists=[array2table(uniqueID) in.refslists];   									% TABLES CATENATION

%return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REWRITING OF L2 RELATED REGIONS TABLE BASED IN UNIQUE INDICES FOR L2 AND L1 REGIONS, REFERENCES AND CHEMICALS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

jcum=0;
for i=1:length(sections)			

	%temptrr=readtable([paths{i,1},'1.OUT_RelatedRegions.csv']);
	%temptrrref=readtable([paths{i,1},'3.OUT_RelatedRegionsREFS.csv']);
	%temptrrchem=readtable([paths{i,1},'2.OUT_RelatedRegionsCHEMS.csv']);

	temprr=table2cell(readtable([paths{i,1},'1.OUT_RelatedRegions.csv']));
	temprrref=table2cell(readtable([paths{i,1},'3.OUT_RelatedRegionsREFS.csv']));
	temprrchem=table2cell(readtable([paths{i,1},'2.OUT_RelatedRegionsCHEMS.csv']));
	
	if i>1
		out.cells.sectionflags(i)=out.cells.sectionflags(i-1)+size(temprrref,1);
	elseif i==1
		out.cells.sectionflags(i)=size(temprrref,1);
	end

	for j=1:size(temprr,1)
		
		% ROI ID:
		for k=1:size(roidtable, 1)
			if temprr{j,1}==roidtable{k,2}
				roi=roidtable{k,4};
				break
			end
		end
		
		% RR (RELATED REGION) ID:
		for k=1:size(out.cells.l2unqcell, 1)
			if strcmp(temprr{j,3}, out.cells.l2unqcell{k,6})
				rr=out.cells.l2unqcell{k,6};
				break
			end
		end
		
		% CONNECTION DIRECTION:
		if temprr{j,5}==0
			fromr=roi; % from region = ROI
			tor=rr;	 % to region = related region
		elseif temprr{j,5}==1
			fromr=rr; % from region = ROI
			tor=roi;	 % to region = related region

		end
		
		% write a table with roiIDs of every connection (useful when reindexing refs and chems)
		out.roids(j+jcum,1)=temprr{j,1};

		% Write table with connections: 
		out.cells.connections{j+jcum,1}=j+jcum; 	% sequential indexes
		out.cells.connections{j+jcum,2}=fromr; 	% from-region column
		out.cells.connections{j+jcum,3}=tor;	% to-region column
		out.cells.connections{j+jcum,4}=j+jcum;	% chemical index
		out.cells.connections{j+jcum,5}=j+jcum;	% reference index   THE ORDER OF CHEMS AND REFS TABLES IS SEQUENTIAL READ-ORDER AND THEREFORE CUMMULATED COUNTER IS THE INDEX !!!

		% Write references and chemicals:
		out.cells.references{j+jcum, 1}=j+jcum; 			 % sequential indexes
		out.cells.chemicals{j+jcum, 1} = out.cells.references{j+jcum, 1}; % sequential indexes

		for k=1:size(temprrref, 2)
			
			out.cells.references{j+jcum, k+1}=temprrref{j, k}; 
			
			% Get rid of NaNs:
			if isnumeric(out.cells.references{j+jcum, k+1})
				if isnan(out.cells.references{j+jcum, k+1})
					%disp('nan')
					%out.cells.references{j+jcum, k+1}
					out.cells.references{j+jcum, k+1}=int16.empty;
				end

			end
		end
		
	
		for k=1:size(temprrchem, 2)
			out.cells.chemicals{j+jcum, k+1}=temprrchem{j, k};
		end
		
	end
	jcum=jcum+j;
end

clear temprr

% Set empty references to NUMERICAL ZERO: zero reference means empty reference. This allows efficient use of data types and therefore of memory. Using negative values or "out of range" values does not.
emptyrefs=cellfun(@isempty, out.cells.references); % Get bolean matrix with answers to isempty() for each cell
out.cells.references(emptyrefs)={0};	% Set cell value to zero	
% out.cells.references(emptyrefs)={0}; % This eliminates empty cells, i.e. the cell array gets smaller and in case of multidim, unidim... not good in this case	


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OVERWRITE REFERENCE NUMBERS NATIVE TO EACH SECTION WITH CORRESPONDING GLOBAL INDEXES FOR ALL LOADED SECTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp(['Total references: (empty and not empty )',num2str((size(out.cells.references,2)-2)*size(out.cells.references,1))])
matchcount=0;
match=zeros(size(out.cells.references,1), size(out.cells.references,2)-2);
pstart=1;
for i=1:size(out.cells.references,1) % loop on regions references rows
	%i
	for j=3:size(out.cells.references,2) % loop on regions references columns
		for k=1:length(out.cells.sectionflags)		
			if i<=out.cells.sectionflags(k)			
				currsection=sections(k);
				break
			end
		end
		
		%currsection=floor(out.roids(i)/1e4);
		currsubsection=out.roids(i); % subsection of document where connection found
		out.refslists = sortrows(out.refslists,'roiID','ascend'); % sort roiID ascending for search efficiency 
		in.refslists = sortrows(in.refslists,'SectionGlobalIndex','ascend'); % sort roiID ascending for search efficiency 
		

		for n=1:size(out.refslists,1) % loop over the list of unique references (many orphan references are not directly listed here but can be found in in.refslists)		

			if out.cells.references{i,j} > 0 %& floor(out.refslists{n,5}/1e4)==currsection	% not empty related-region refs & in current section
							
				if out.roids(i) == out.refslists{n,5} % if subsection match (connection-reflist)
										
					for p=1:size(in.refslists,1) 	% loop over list of references with same bib-entry in redundant list
				
						if in.refslists{p,4}==out.refslists{n,4} & in.refslists{p,5}==out.roids(i)	% SectionGlobalIndex match & subsection match
							%('SUBSECTION match')
							%i
							%j
							%n
							%p
							out.cells.references{i,j}=in.refslists{p,1}; % overwrite SectionGlobalIndex with uniqueID 
							match(i,j-2)=1;
							matchcount=matchcount+1;
							disp(['matches=',num2str(matchcount)]) 
				 			%pstart=p+1;
							break
						end
					end
				end
				
			end
		end
	end
end
%disp(['match=',num2str(match),' out of ',num2str((size(out.cells.references,2)-2)*size(out.cells.references,1))])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WRITE OUTPUT TABLES:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONNECTIONS:
out.cells.connectionsheader={'uniqueID';'FROMregion'; 'TOregion';'CHEMICALSkey'; 'REFERENCESkey'};
out.connections=cell2table(out.cells.connections, 'VariableNames', out.cells.connectionsheader); % Write to table format to export easily to file
writetable(out.connections, [outpath, outconnecfile]) % Write to file


% REFERENCES:
colstartrefs=3; % column number at which numerical references start
for i=colstartrefs:size(out.cells.references, 2)
	newrefixs{i+1-colstartrefs,1}=['Reference',num2str(i+1-colstartrefs)];
end

out.cells.referencesheader=[{'uniqueID'; 'OriginalReferences'}; newrefixs];
out.references=cell2table(out.cells.references, 'VariableNames', out.cells.referencesheader); % Write to table format to export easily to file
writetable(out.references, [outpath, outreffile]) % Write to file

% CHEMICALS:
colstartchems=3; % column number at which individual references start
for i=colstartchems:size(out.cells.chemicals, 2)
	newchemixs{i+1-colstartchems,1}=['Chemical',num2str(i+1-colstartchems)];
end

out.cells.chemicalsheader=[{'uniqueID'; 'OriginalChemicals'}; newchemixs];
out.chemicals=cell2table(out.cells.chemicals, 'VariableNames', out.cells.chemicalsheader); % Write to table format to export easily to file
writetable(out.chemicals, [outpath, outchemfile]) % Write to file


%outconnecfile='3.Connections';
%outreffile='4.References';
%outchemfile='5.Chemicals';
