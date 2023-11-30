% Script to read and load the data of one brain section.
% Output are the files with mappings of this section: related regions, related chemicals, 
% bibliographical references and IDs
clear
sectionnumber=2;  % <------------------------------------------------------------ CHANGE SECTION NUMBER ACCORDING TO INPUT FILE LOCATION!!!
sectionnumberchar=num2str(sectionnumber);
path=['/home/lab/Documents/DB/INPUT/ORIGINAL/SECTIONS/',sectionnumberchar, '/'  ];
outpath=[path,'OUT/'];
mkdir (eval('outpath'));

infilename{1}='1.olfactory.bulb_4ML.xlsx';
infilename{2}='2.prefrontal.cortex_4ML.xlsx';
infilename{7}='7.bed.nucleus.of.stria.terminalis_4ML.xlsx';
infilename{10}='10.amygdala_4ML.xlsx';

outreffile='5.OUT_ReferenceList.csv';
outrelatedfile='1.OUT_RelatedRegions.csv';
outrelreffile='3.OUT_RelatedRegionsREFS.csv';
outrelchemfile='2.OUT_RelatedRegionsCHEMS.csv';
outintreffile='4.OUT_IntrinsecREFS.csv';
outidfile='6.OUT_ROI_IDs.csv';

[num, txt, raw]=xlsread([path, infilename{sectionnumber}]);


% Debugging switches
debugintrinsec=0; % set to 1 for debugging mode for intrinsec tables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%					READING DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

flagregions=1; % counter of numerical values in first column
refthresh=500; % threshold value for NOT (if >) considereing a number as reference. If more than refthresh refs are found per table, quit program
flagrefs=1;
condir=-1; % stores the direction of the connection of a related (sub)region
		   % 0 -> efferent (outwards)
		   % 1 -> afferent (inwards)
		   % 2 -> no direction defined	 
j=0;	% counter for the level 1 efferent regions
k=0;	% counter for the level 1 afferent regions
p=0; % counter for rows with level2 efferent and afferent regions


for i=1:size(raw,1) % GOING DOWN THE FIRST COLUM OF THE RAW CELL ARRAY:
	% GETTING NAMES OF CURRENT REGION AND SUBREGIONS:
	% no need to treat main region as special region for identification purposes
	% indexing numbers of word document converted manually to integer in excel and multiplied by 1000. This has changed,see PREPARE_DATA.txt !!!
	if isnumeric(raw{i,1}) && raw{i,1} > 999
		region.regionids.val{flagregions,1}=raw{i,1};
		region.regionids.val{flagregions,2}=raw{i,3};
		roil1=region.regionids.val{1,1};
		disp(['ROI L1 = ',num2str(roil1)])
		if mod(region.regionids.val{flagregions,1},1000)~=0
			roil2=region.regionids.val{flagregions,1};
			disp(['ROI L2 = ',num2str(roil2)])
		end
		flagregions=flagregions+1;
		% Copy region names and ids to cell arrays with reference tables and related regions tables:
		region.references.subregion=region.regionids.val;
	
	% GET REFERENCES (PAPERS) This is only the list of references, the references for each subregion are not loaded in this section:
	%elseif isnumeric(raw{i,1}) && raw{i,1} > refthresh-100 % not more than 200 references are expected
	%	disp('WARNING: TOO MANY REFERENCES !!!')

	elseif isnumeric(raw{i,1}) && raw{i,1} > refthresh % something strange is happening
		disp(['ERROR? SEQUENCE TERMINATED. REFERENCES EXCEED ', num2str(refthresh), 'entries'])
		return;
	elseif isnumeric(raw{i,1}) && raw{i,1} < refthresh % this should be a real reference
		%disp('got in reference')
		%disp(num2str(flagregions))
		% it is assumed that ALWAYS one subregion is recognized and then its references are stored. No checking of right assignment of references to subgroup is done!!! VALIDATE VISUALLY!!!

			region.references.temp{flagrefs,1}=raw{i,1};
			region.references.temp{flagrefs,2}=raw{i,2};
			flagrefs=flagrefs+1;

		
	elseif ischar(raw{i,1})

		% Read regions' abbreviations:
		if length(strfind(raw{i,1},'Abbreviations regions'))>0 % DETECT KEYWORD
		
			i=i+1;
			counter=0;
			while strcmpi( raw{i,1}, 'EOF' )==false & strcmpi( raw{i,1}, 'EOT' )==false
				counter=counter+1; 

				temp1=strsplit(raw{i,1}); % get rid of blank spaces if any in region abbreviation
				if length(temp1)>1 % catenation of single string like this repeats string twice!!!
					region.abbs.vals{counter,1}=[temp1{1}, temp1{end}]; % write the IN regions in 2nd column
				else
					region.abbs.vals{counter,1}=raw{i,1}; % region abbreviation
				end
				
				region.abbs.vals{counter,2}=raw{i,2}; % original region name
				i=i+1;
				clear temp1
			end
			
		% Read chemicals' abbreviations:
		elseif length(strfind(raw{i,1},'Abbreviations chemicals'))>0 % DETECT KEYWORD
		
			i=i+1;
			counter=0;
			while strcmpi( raw{i,1}, 'EOF' )==false & strcmpi( raw{i,1}, 'EOT' )==false
				counter=counter+1; 
				chem.abbs.vals{counter,1}=raw{i,1};
				chem.abbs.vals{counter,2}=raw{i,2};
				i=i+1;
			end

		% DETECT EFFERENT REGIONS (OUT) each one with all the corresponding values for all attributes:	
		elseif length(strfind(raw{i,1},'EFFERENTS/OUTPUT'))>0 % DETECT KEYWORD
			%disp(['found OUT at line ', num2str(i)])
			condir=0;
		
			%j=j+1;
			%disp(['input i=',num2str(i)])
			%while strcmpi( raw{i,1}, 'EOT' )==false
				i=i+1; %%%%no ;
				while true(isnan( [raw{i,2}, raw{i,3}, raw{i,4}] )) & strcmpi( raw{i,1}, 'EOF' )==false & strcmpi( raw{i,1}, 'EOT' )==false & length(strfind(raw{i,1},'AFFERENTS/INPUT'))==0 & length(strfind(raw{i,1},'Table'))==0% L1 related regions
					%disp(['In L2 efferent. i=',num2str(i)])
					j=j+1;
					region.related.level1.names{j,1}=raw{i,1};
					i=i+1;
					while ischar(raw{i,2}) & ischar(raw{i,4}) & length(strfind(raw{i,1},'AFFERENTS/INPUT'))==0  & length(strfind(raw{i,1},'EOT'))==0% L2 related regions
						p=p+1;
						region.related.level2.names{p,2}=raw{i,1}; % related region name
						region.related.level2.names{p,3}=raw{i,2};	% abbreviation
						region.related.level2.names{p,4}=region.related.level1.names{j,1};	% belongs to ROI L1:													
						region.related.level2.names{p,1}=roil2;	% L2 ROI							
						region.related.level2.names{p,5}=condir; %efferent or afferent
						region.related.level2.names{p,6}=raw{i,3};	% transmitter
						region.related.level2.chems{p,1}=raw{i,3};	% transmitter
						region.related.level2.names{p,7}=raw{i,4};	% references original format: [1,3-5, 9]
						region.related.level2.refs{p,1}=raw{i,4};	% references original format: [1,3-5, 9]
						splitreferences;	% references translation from original format to several columns
						splitchemicals;	% chemicals translation from original format to several columns
						i=i+1;
					end
				
				end
			
		% DETECT AFFERENT REGIONS (IN) each one with all the corresponding values for all attributes:
		elseif length(strfind(raw{i,1},'AFFERENTS/INPUT'))>0 % DETECT KEYWORD
			disp(['found IN at line ', num2str(i)])
			condir=1;
		
			%j=j+1;
			%disp(['input i=',num2str(i)])
			%while strcmpi( raw{i,1}, 'EOT' )==false
				i=i+1; %%%%no ;
				while true(isnan( [raw{i,2}, raw{i,3}, raw{i,4}] )) & strcmpi( raw{i,1}, 'EOF' )==false & strcmpi( raw{i,1}, 'EOT' )==false & length(strfind(raw{i,1},'EFFERENTS/OUTPUT'))==0 & length(strfind(raw{i,1},'Table'))==0% L1 related regions
					%disp(['In L2 afferent. i=',num2str(i)])
					j=j+1;
					region.related.level1.names{j,1}=raw{i,1};
					i=i+1;
					while ischar(raw{i,2}) & ischar(raw{i,4}) & length(strfind(raw{i,1},'AFFERENTS/INPUT'))==0  & length(strfind(raw{i,1},'EOT'))==0% L2 related regions
						p=p+1;
						region.related.level2.names{p,2}=raw{i,1}; % related region name
						region.related.level2.names{p,3}=raw{i,2};	% abbreviation
						region.related.level2.names{p,4}=region.related.level1.names{j,1};	% belongs to ROI L1 (location):													
						region.related.level2.names{p,1}=roil2;	% related to given roi L2							
						region.related.level2.names{p,5}=condir; %efferent or afferent
						region.related.level2.names{p,6}=raw{i,3};	% transmitter 	
						region.related.level2.chems{p,1}=raw{i,3};	% transmitter						REPLACE THIS WITH NEWE GLOBAL IDENTIFIER!!!!!!!!!!!!
						region.related.level2.names{p,7}=raw{i,4};	% references original format: [1,3-5, 9] 	REPLACE THIS WITH NEWE GLOBAL IDENTIFIER!!!!!!!!!!!!
						region.related.level2.refs{p,1}=raw{i,4};	% references original format: [1,3-5, 9]
						splitreferences;	% references translation from original format to several columns
						splitchemicals;	% chemicals translation from original format to several columns
						i=i+1;
					end
				
				end

		% DETECT AFFERENT REGIONS (IN) each one with all the corresponding values for all attributes:
		elseif length(strfind(raw{i,1},'O/I'))>0 % DETECT KEYWORD
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			makeintrinsec					% Call to script makeintrinsec.m to make intrinsic table of section.
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		end	% end if ischar(raw{i,1})
	
	end % end main if

end % end for

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Call to script formatroinames.m to format the names of the level2 ROIs:
formatroinames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Call to script (is not a function!!!) to organize table with all references of the section and reindexing:
refindexing 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Call to script  (is not a function!!!) to overwrite all original indexes in related-regions references' table with the new ones calculated after reindexing references' table:
refoverwrite
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% WRITE TABLE WITH RELATED-REGION DATA (except chemicals and references) TO FILE:
region.related.level2.namesheader=[{'RoiID';'RelatedL2Region';'L2RegionAbbreviation';'L2RBelongsToL1Region';'DirectionZEROOUTonein';'Chemicals';'BiblioReferences'}];
outrelated=cell2table(region.related.level2.names, 'VariableNames', region.related.level2.namesheader); % Write to table format to export easily to file
writetable(outrelated, [outpath, outrelatedfile]) % Write to file



% WRITE TABLE WITH REFERENCES OF RELATED REGIONS AND THEIR DATA TO FILE:
for i=2:size(region.related.level2.refs,2)
	newrefixs{i-1,1}=['Reference',num2str(i-1)];
end

region.related.level2.refsheader=[{'OriginalReference'}; newrefixs];
outrelref=cell2table(region.related.level2.refs, 'VariableNames', region.related.level2.refsheader); % Write to table format to export easily to file
writetable(outrelref, [outpath, outrelreffile]) % Write to file
%clear outref
clear newrefixs;

% WRITE TABLE WITH CHEMICALS OF RELATED REGIONS AND THEIR DATA TO FILE:
for i=2:size(region.related.level2.chems,2)
	newrefixs{i-1,1}=['Chemical',num2str(i-1)];
end

region.related.level2.chemsheader=[{'OriginalChems'}; newrefixs];
outrelchem=cell2table(region.related.level2.chems, 'VariableNames', region.related.level2.chemsheader); % Write to table format to export easily to file
writetable(outrelchem, [outpath, outrelchemfile]) % Write to file
clear newrefixs;


% WRITE TABLE WITH INTRINSEC REGION (SECTION) REFERENCE DATA TO FILE:

if size(region.intrinsec.val,2) >= 4 % if there are non-empty intrinsic references
	for i=4:size(region.intrinsec.val,2)
		newrefixs{i-3,1}=['Reference',num2str(i-3)];
	end
	region.intrinsec.valheader=[{'OUTPUT'; 'INPUT'; 'OriginalReference'}; newrefixs];
else
	region.intrinsec.valheader=[{'OUTPUT'; 'INPUT'; 'OriginalReference'}];
end
outintref=cell2table(region.intrinsec.val, 'VariableNames', region.intrinsec.valheader); % Write to table format to export easily to file
writetable(outintref, [outpath, outintreffile]) % Write to file
clear newrefixs;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% WRITE TABLE WITH ROIs IDs and NAMES TO FILE:

% WRITE TABLE WITH ABBREVIATIONS OF REGIONS ACCORDING TO TABLE OF ABBREVIATIONS IN LOADED SECTION:
%region.abbs.header={'Abbreviation'; 'RegionName'};
%region.abbs.table=cell2table(region.abbs.vals, 'VariableNames', region.abbs.header);

% Write abbreviations to table of regionIDs:
for i=1:size(region.regionids.new,1)
	for j=1:size(region.abbs.vals,1)
		wherefind=char(region.abbs.vals{j,2});
		whichfind=char(region.regionids.new{i,2});
		if length( findstr(wherefind, whichfind) )==1 | strcmpi(wherefind, whichfind)%
			region.regionids.new{i,3}=region.abbs.vals{j,1}; % write abb to column cell array
			break
		end
	end
end

% WRITE TABLE WITH ROIs IDs and NAMES TO FILE:
region.regionids.header={'RoiID';'RoiNAME';'Abbreviation'};
outid=cell2table(region.regionids.new, 'VariableNames', region.regionids.header); % Write to table format to export easily to file
writetable(outid, [outpath, outidfile]) % Write to file

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

