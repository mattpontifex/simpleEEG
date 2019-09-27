function [step, strLength] = commandwaitbar(compl, total, step, nSteps, strLength)
% % Setup Controls
% WinStart = 1;
% WinStop = 100;
% nSteps = 25;
% step = 1;
% 
% % Start Loop
% fprintf(1, 'Progress: |');
% strLength = fprintf(1, [repmat(' ', 1, nSteps-step) '|   0%%']);
% tic
% for n = WinStart:WinStop
%     [step, strLength] = commandwaitbar(n, WinStop, step, nSteps, strLength);
%     pause(0.1)
% end
% % Closeout bar
% [step, strLength] = commandwaitbar(WinStop, WinStop, step, nSteps, strLength);
% fprintf(1, '\n')

    progStrArray = '|';
    tmp = floor(compl / total * nSteps);
    if tmp > step
        fprintf(1, [repmat('\b', 1, strLength) '%s'], repmat('=', 1, tmp - step))
        step = tmp;
        ete = ceil(toc / step * (nSteps - step));
        strLength = fprintf(1, [repmat(' ', 1, nSteps - step) '%s %3d%%, ETC %02d:%02d'], progStrArray(1), floor(step * 100 / nSteps), floor(ete / 60), mod(ete, 60));
    end

end