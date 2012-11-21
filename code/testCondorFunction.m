%TESTCONDORFUNCTION A simple test function provided as an example.
%   
%   DESCRIPTION:
%   This is a simple example of the function structure required for use
%   with the matlab-condor library. Input and output must be collapsed into
%   a single value. Beyond that, the structure of those inputs and outputs
%   can be anything.
%
%   USAGE:
%       out = testCondorFunction(in)
%
%   INPUT:
%       in - Any single input. Can be anything from a single value to a
%       large matrix or structure of data.
%
%   OUTPUT:
%       out - Any single entity output. All other output will be ignored.
%
%   Author:
%   Luke Winslow
%   Limnology and Oceanography PhD Student
%   University of Wisconsin - Madison
%   USA, 2012
%
%   lawinslow@gmail.com

function out = testCondorFunction(in)


    inc = 1;
    for i=1:length(in)
        pause(0.1);
        out(i) = 1;
        inc = inc + 2;
    end


end