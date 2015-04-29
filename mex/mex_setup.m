% -------------------------------------------------------------------------
% you must run this script prior to using the package
% -------------------------------------------------------------------------

CPP_SRC = '../cpp/';
VLFEAT_DIR = '/home/vasiliy/research/toolbox/VLfeat/';
% VLFEAT_DIR = '/home/btay/Source/vlfeat-0.9.18/';

VLFEAT_SRC = [VLFEAT_DIR, 'vl/'];
VLFEAT_LIB = [VLFEAT_DIR, 'bin/glnxa64/'];

% % -------------------------------------------------------------------------
% %                   delete all previous files
% % -------------------------------------------------------------------------
unix('rm *.mexa64')

% % -------------------------------------------------------------------------
% %                   build primaldual solver
% % -------------------------------------------------------------------------
cmd = sprintf('mex pd_wrapper.cpp CXXFLAGS="-O -msse2 -msse -msse3 -fPIC -DHAVE_SSE -DHAVE_MATLAB" -I%s ', CPP_SRC);
% uncomment this to TURN OFF SSE:
% cmd = sprintf('mex pd_wrapper.cpp CXXFLAGS="-O -fPIC -DHAVE_MATLAB" -I%s ', CPP_SRC);
cmd = sprintf('%s %s/solver_primaldual.cpp', cmd, CPP_SRC);
cmd = sprintf('%s %s/bcv_diff_ops.cpp', cmd, CPP_SRC);
cmd = sprintf('%s %s/sparse_op.cpp', cmd, CPP_SRC);
cmd = sprintf('%s %s/utils.cpp', cmd, CPP_SRC);
eval(cmd);
fprintf('Built solver.\n');
% % -------------------------------------------------------------------------
% %                   build GMM learning (using VLFEAT)
% % -------------------------------------------------------------------------
cmd = sprintf('mex learn_constraint_gmm_mex.cpp CFLAGS="-std=c99 -O -fPIC -DVL_DISABLE_SSE2 -DVL_DISABLE_AVX" CXXFLAGS="-O -fPIC " -I%s ', VLFEAT_SRC);
cmd = sprintf('%s %s/generic.c ',   cmd, VLFEAT_SRC);
cmd = sprintf('%s %s/gmm.c ',       cmd, VLFEAT_SRC);
cmd = sprintf('%s %s/kmeans.c ',    cmd, VLFEAT_SRC);
cmd = sprintf('%s %s/random.c ',    cmd, VLFEAT_SRC);
cmd = sprintf('%s %s/mathop.c ',    cmd, VLFEAT_SRC);
cmd = sprintf('%s %s/kdtree.c ',    cmd, VLFEAT_SRC);
cmd = sprintf('%s %s/host.c ',      cmd, VLFEAT_SRC);
eval(cmd);

%-------------------------------------------------------------------------
% build GMM learning (using VLFEAT)
%-------------------------------------------------------------------------
% learn_bbox_gmm_mex.cpp
cmd = sprintf('mex learn_bbox_gmm_mex.cpp CXXFLAGS="-O -msse2 -msse -msse3 -fPIC " -I%s ', VLFEAT_SRC);
cmd = sprintf('%s -L%s -lvl', cmd, VLFEAT_LIB);
eval(cmd);


% compile other local MEX files:
cppfiles = dir('*.cpp');
for ii=1:length(cppfiles)
    if strcmpi(cppfiles(ii).name, 'pd_wrapper.cpp'), continue; end
    if strcmpi(cppfiles(ii).name, 'learn_constraint_gmm_mex.cpp'), continue; end
    if strcmpi(cppfiles(ii).name, 'learn_bbox_gmm_mex.cpp'), continue; end

    fprintf('Compiling: %s\n', cppfiles(ii).name);
    cmd = sprintf('mex %s', cppfiles(ii).name);
    eval(cmd);
end