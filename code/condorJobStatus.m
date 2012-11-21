%CONDORJOBSTATUS Returns the number of running or finished jobs in a run.
%   
%   DESCRIPTION:
%       Queries the condor system and determines which jobs are still
%       queued, running, and finished. The output 'running' bundles both
%       jobs that are actively running and jobs that are waiting to be run.
%       Jobs listed as done may also have failed.
%
%   USAGE:
%       [done,running] = condorJobStatus('testRun');
%
%   INPUT:
%       runName - The name of the previously created run.
%
%   OUTPUT:
%       done - The number of jobs that have finished or failed.
%       running - The number of jobs that are running or waiting to run.
%
%   TODO: Deliniate between done and failed jobs.
%
%   Author:
%   Luke Winslow
%   Limnology and Oceanography PhD Student
%   University of Wisconsin - Madison
%   USA, 2012
%
%   lawinslow@gmail.com
function [done,running] = condorJobStatus(runName)

if(~exist([runName '/runIds.mat'],'file'))
    error('Either that run name doesn''t exist or no jobs were successfully started');
end

tmp = load([runName '/runIds.mat']);
runIds = tmp.runIds;

done = 0;
running = 0;

for i=1:length(runIds)
    [~,out] = system(sprintf('condor_q %s',runIds{i}));
    tmp = regexp(out,'\n','split');
    
    if(length(tmp(~strcmpi(tmp,''))) > 2)
        running = running + 1;
    else
        done = done + 1;
    end    
end

end