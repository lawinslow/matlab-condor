%% Prepare input structure for condor

in.data = importdata('spk_interactions_all_order_uncertain.csv');
x = in.data;

xFTIT = cell(length(x)-1,4);
for i=2:length(x)
    xFTIT(i-1,:) = regexp(x{i},',','split');
end

xFromTo = xFTIT(:,1:2);
nodeNames = unique(vertcat(xFromTo(:,1),xFromTo(:,2)));
%nodeNames = {'Lepomis', 'Crayfish','Odonate','Ephemeroptera','Trichoptera','Gastropod','Diptera','Amphipoda','Macrophyte','Bass'};

%Importance key:
% major = 0
% minor = 1
% unknown = 2
%Type Key:
% Predator-prey = 0
% Negative      = 1
% Habitat       = 2
% Competition   = 3
% limiting      = 4

xImportType = ones(size(xFromTo,1),2,'int8')*-9;
xImportType(strcmpi(xFTIT(:,3),'major'),1) = 0;
xImportType(strcmpi(xFTIT(:,3),'minor'),1) = 1;
xImportType(strcmpi(xFTIT(:,3),'unknown'),1) = 2;

xImportType(strcmpi(xFTIT(:,4),'predator-prey'),2) = 0;
xImportType(strcmpi(xFTIT(:,4),'negative'),2) = 1;
xImportType(strcmpi(xFTIT(:,4),'habitat'),2) = 2;
xImportType(strcmpi(xFTIT(:,4),'competition'),2) = 3;
xImportType(strcmpi(xFTIT(:,4),'limiting'),2) = 4;

unkI = find(xImportType(:,1) == 2);
nruns = 2^length(unkI);

nCondRuns = ceil(nruns/1e7);
input = cell(nCondRuns,1);


for i=1:nCondRuns
    input{i} = in;
    input{i}.start = (i-1)*1e7+1;
    input{i}.end = i*1e7;
    if(input{i}.end>nruns)
        input{i}.end = nruns;
    end
end

%% Prep condor runs
cRunName = 'test1';

condorPrepCode('specInteractionMod',cRunName);

cIds = condorChunkAndRun(input,cRunName);



%% Compile results
clc;
[~,running] = condorJobStatus(cIds);
while(running > 0)
    [~,running] = condorJobStatus(cIds);
    disp('waiting....');
    pause(60);
    fprintf('\b\b\b\b\b\b\b\b\b\b\b\b')
end

files = dir([cRunName '/done-*.mat']);

load([cRunName '/' files(1).name]);
nodeNames = output.nodeNames;
macValSum =  zeros(length(nodeNames));
cobbValSum =  zeros(length(nodeNames));

for i=1:length(files)
    load([cRunName '/' files(i).name]);
    if(~all(strcmpi(nodeNames,output.nodeNames)))
        error('argh');
    end
    
    macValSum = macValSum + output.mac;
    cobbValSum = cobbValSum + output.cobb;
end
disp('results compiled');

%% output results to files
fid = fopen('macrophyteValid.csv','w+');
fprintf(fid,' ,');

for i=1:length(nodeNames)
    fprintf(fid,'%s,',nodeNames{i});
end
fprintf(fid,'\n');


for i=1:length(nodeNames)
    fprintf(fid,'%s,',nodeNames{i});
    fprintf(fid,repmat('%i,',1,length(nodeNames)),macValSum(i,:));
    fprintf(fid,'\n');
    
end

% do cobble
fclose(fid);

fid = fopen('cobbleValid.csv','w+');
fprintf(fid,' ,');

for i=1:length(nodeNames)
    fprintf(fid,'%s,',nodeNames{i});
end
fprintf(fid,'\n');


for i=1:length(nodeNames)
    fprintf(fid,'%s,',nodeNames{i});
    fprintf(fid,repmat('%i,',1,length(nodeNames)),cobbValSum(i,:));
    fprintf(fid,'\n');
    
end

fclose(fid);


