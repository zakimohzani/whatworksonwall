clear

load('15-Jun-2016_Stock_Data.mat')

%%
disp('Processing PE');
data = {morningstar.getPE};
cleanedUpData = cleanYahooData(data);
reportOnBadData(data, cleanedUpData);

data = cleanedUpData;
iN = cellfun(@isnumeric,data);
iNaN = cellfun(@isnan,data);

valid = iN & ~iNaN;
missing.getPE = 100*(length(data)-length(find(valid))) / length(data);


%%
disp('Processing PB');
data = {morningstar.getPB};
cleanedUpData = cleanYahooData(data);
reportOnBadData(data, cleanedUpData)

data = cleanedUpData;
iN = cellfun(@isnumeric,data);
iNaN = cellfun(@isnan,data);

valid = iN & ~iNaN;
missing.getPB = 100*(length(data)-length(find(valid))) / length(data);


%%
disp('Processing PS');
data = {morningstar.getPS};
cleanedUpData = cleanYahooData(data);
reportOnBadData(data, cleanedUpData)

data = cleanedUpData;
iN = cellfun(@isnumeric,data);
iNaN = cellfun(@isnan,data);

valid = iN & ~iNaN;
missing.getPS = 100*(length(data)-length(find(valid))) / length(data);


%%
disp('Processing EVEBITDA');
data = {morningstar.getEVEBITDA};
cleanedUpData = cleanYahooData(data);
reportOnBadData(data, cleanedUpData)

data = cleanedUpData;
iN = cellfun(@isnumeric,data);
iNaN = cellfun(@isnan,data);

valid = iN & ~iNaN;
missing.getEVEBITDA = 100*(length(data)-length(find(valid))) / length(data);


%%
disp('Processing PFCF');
data = {morningstar.getPFCF};
iN = cellfun(@isnumeric,data);
iNaN = cellfun(@isnan,data);

valid = iN & ~iNaN;
missing.getPFCP = 100*(length(data)-length(find(valid))) / length(data);


%%
disp('Processing DivYield');
data = {morningstar.getDivYield};
iE = cellfun(@isempty,data);
data(iE) = {NaN};

% find non-number stuff
iBS = ~cellfun(@isscalar,data);
if ~isempty(data(iBS))
    disp('Data is dirty');
end

% calculate now
iN = cellfun(@isnumeric,data);
iNaN = cellfun(@isnan,data);

valid = iN & ~iNaN;
missing.getDivYield = 100*(length(data)-length(find(valid))) / length(data);

%%
disp('Processing BuybackYield');
data = {morningstar.getBuybackYield};

% find non-number stuff
iBS = ~cellfun(@isscalar,data);
if ~isempty(data(iBS))
    disp('Data is dirty');
end

cleanedUpData = data;
reportOnBadData(data, cleanedUpData)

data = cleanedUpData;
iN = cellfun(@isnumeric,data);
iNaN = cellfun(@isnan,data);

valid = iN & ~iNaN;
missing.getBuybackYield = 100*(length(data)-length(find(valid))) / length(data);

%%
disp('Processing MarketCap');
data = {morningstar.getMarketCap};

% find non-number stuff
iBS = ~cellfun(@isscalar,data);
if ~isempty(data(iBS))
    disp('Data is dirty');
end

cleanedUpData = data;
reportOnBadData(data, cleanedUpData)

data = cleanedUpData;
iN = cellfun(@isnumeric,data);
iNaN = cellfun(@isnan,data);

valid = iN & ~iNaN;
missing.getMarketCap = 100*(length(data)-length(find(valid))) / length(data);

%% END
missing
