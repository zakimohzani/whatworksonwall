function reportOnBadData(data, cleanedUpData)
visualisationOfConversion = [data;cleanedUpData]';

iNaN = cellfun(@isnan,cleanedUpData);
visualisationOfProblemPoints = visualisationOfConversion(iNaN,:);

% filter out the typical cases

% [NaN] [NaN]
t1 = cellfun(@isnan,visualisationOfProblemPoints, 'UniformOutput', false);
t2 = cellfun(@isscalar,t1, 'UniformOutput', false);
t3 = cell2mat(t2);
idx = t3(:,1) == 1 & t3(:,2) == 1;
% uncomment to verify
% visualisationOfProblemPoints(idx,:); 


% 'N/A'    [NaN]
visualisationOfProblemPoints = visualisationOfProblemPoints(~idx,:);
t1 = strcmp(visualisationOfProblemPoints(:,1),'N/A');
t2 = cellfun(@isnan,visualisationOfProblemPoints(:,2));
idx = t1 & t2;
visualisationOfProblemPoints = visualisationOfProblemPoints(~idx,:);

if ~isempty(visualisationOfProblemPoints)
    msg = sprintf('There is %d bad points, please check', size(visualisationOfProblemPoints,1));
    disp(msg);
end
end