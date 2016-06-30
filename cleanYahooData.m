function cleanedUpData = cleanYahooData(data)
% this is because of a bug in my retrieval code
% FIX IT!
a = cellfun(@str2double,data);
sz = size(a);
cleanedUpData = mat2cell(a,1, ones(1,sz(2)));
end