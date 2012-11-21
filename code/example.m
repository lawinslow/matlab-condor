% Example of how to setup and run a job with matlab-condor.

%Decide on run name (unique tracker of jobs) and prep code (compile
%basically)
runName = 'test';
condorPrepCode('testCondorFunction',runName);

%Setup input for jobs. You have to decide how to break up the jobs yourself

inputs = ones(100,1);
inputs = inputs.*1000;

%Input array must be in the form of cells. Each cell is a single job.
%Anything can be in the cell, it will be passed directly to the function
%you specified in "condorPrepCode" above. 
inputs = num2cell(inputs);

%Submit input to condor
condorChunkAndRun(num2cell(inputs),runName);


%Determine jobs status and wait until finished
[done,running] = condorJobStatus(runName);

while(running ~= 0)
    pause(10); %Wait 10 seconds to requery status
    [done,running] = condorJobStatus(runName);
end

disp('Jobs done!');
%You can now collect the results.
