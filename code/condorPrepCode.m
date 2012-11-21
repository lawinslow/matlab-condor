%CONDORPREPCODE Prepares the designated function and run for HTCondor
%   
%   DESCRIPTION:
%       A function which creates wrapper code for the supplied function
%       for running on a Condor pool. The code is compiled and organized
%       for later job submission.
%
%   USAGE:
%       condorPrepCode('functionName','usersRunName')
%
%   INPUT:
%       funName - The name of a function with a single input and output to
%       be run on each condor node. It can encapsulate code of great
%       complexity. See testCondorFunction for a simple example.
%       runName - The name to be used to track this run. A directory of
%       that name will be created to encapsulate input and output from the
%       runs.
%
%   Author:
%   Luke Winslow
%   Limnology and Oceanography PhD Student
%   University of Wisconsin - Madison
%   USA, 2012
%
%   lawinslow@gmail.com
function condorPrepCode(funName,runName)

    % First, create the function that will be run for each condor job
    fid = fopen('condorFun.m','w+');
    fprintf(fid,'function output = condorFun()\n');
    fprintf(fid,'try\n');
    fprintf(fid,'%%There should be one *.mat file in the current directory\n');
    fprintf(fid,'in = dir(''*.mat'');\n');
    fprintf(fid,'load(in(1).name);\n');
    fprintf(fid,'runNum = in(1).name(1:end-4);\n');
    fprintf(fid,'%%The mat file must contain a variable called ''data''\n');
    fprintf(fid,'output = %s(data);\n',funName);
    fprintf(fid,'save([''done-'' runNum ''.mat''],''output'');\n');
    fprintf(fid,'catch err\n');
    fprintf(fid,'save([''err-'' runNum ''.mat'']);\n');
    fprintf(fid,'end\n');
    fprintf(fid,'end\n');
    fclose(fid);


    % Compile that function
    mcc -m -v -R -singleCompThread -R nojvm -R nodesktop -R nosplash condorFun.m

    if(~exist(runName,'dir'))
        mkdir(runName);
    end

    % Move it into the job's directory
    movefile('condorFun.exe',[runName '/condorFun.exe']);
    % Delete some extra files generated that are not needed.
    delete('mccExcludedFiles.log');
    delete('readme.txt');
    delete('condorFun.m');

end