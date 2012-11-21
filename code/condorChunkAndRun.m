%CONDORCHUNKANDRUN Breaks up the input data and submits jobs to Condor.
%   
%   DESCRIPTION:
%       Function that accepts input to a named run, separates that input
%       into single condor jobs, and submits them to the condor pool. The
%       run code must have already been prepared by the condorPrepCode
%       function.
%
%   USAGE:
%       runIds = condorChunkAndRun(inputData,'runName');
%
%   INPUT:
%       in - The prepared input data in a cell array. Each cell will 
%       turn into one condor job.
%       runName - The run name to run the input against. The run defines
%       the input data and code.
%
%   OUTPUT:
%       runIds - The Condor job ids. Optional as they're also persisted
%       with the run.
%
%   Author:
%   Luke Winslow
%   Limnology and Oceanography PhD Student
%   University of Wisconsin - Madison
%   USA, 2012
%
%   lawinslow@gmail.com

function [runIds] = condorChunkAndRun(inData,runName)

%inData needs to be cell array of whatever. Each cell is considered one run
cd(runName);

runIds = cell(length(inData),2);
try
    
    for i=1:length(inData)
        data = inData{i};

        save([num2str(i) '.mat'],'data');
        condorCreateSubmit('sbm.cmd',[num2str(i) '.mat']);
        [status,out] = system('condor_submit sbm.cmd');
        tmp = regexp(out,'submitted to cluster (?<num>\d+).','tokens');
        runIds{i,1} = tmp{1}{1};
        runIds{i,2} = i;
        
    end

    %Save the runids for later use
    save('runIds.mat','runIds');
    
    cd('..');

catch e
    disp(getReport(e,'extended'));
    cd('..');
end

end


function condorCreateSubmit(loc,matName)

fid = fopen(loc,'w+');

fprintf(fid,'universe = vanilla\n');
fprintf(fid,'executable = condorFun.exe\n');
fprintf(fid,'requirements = (TARGET.OpSys == "WINNT61")\n');
fprintf(fid,'should_transfer_files = YES\n');
fprintf(fid,'transfer_input_files = %s\n', matName);

fprintf(fid,'when_to_transfer_output = ON_EXIT\n');
fprintf(fid,'notification = never\n');
fprintf(fid,'queue');

fclose(fid);


end
