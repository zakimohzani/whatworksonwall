clc; clear;
diary('diary.log') 

% tick = {'msft'};
%% settings
pathForSourceOfTicks = '09-Jun-2016_Stock_Data.mat';
previousDataToResume = '27-Jun-2016_Stock_Data.mat';

%% don't modify below
load(pathForSourceOfTicks,'tick');
load(previousDataToResume);


methods = { ...
    'getPrice', 'getPE', 'getPB', 'getPFCF', 'getPS', 'getEVEBITDA', ...
    'getShareholderYield', 'getBuybackYield', 'getDivYield', ...
    'getMarketCap', 'get6monthPricePercentageChange'};

%%
dss = {FinVizDataSource, YahooDataSource, MorningstarDataSource};

% calculate resume point
if exist('data')
    a = fieldnames(data);
    lastTick = data.(a{1})(end).name;
    starti = find(strcmp(tick,lastTick)) + 1;
else
    starti = 1;
end

for i  = starti:length(tick)
    fprintf('%4d of %d : %s\t\t\t', i, length(tick), tick{i});
    for iD = 1:length(dss)
        ds = dss{iD};
        ds.setTick(tick{i});
        fprintf('%s  ', ds.getName);
        
        stock.name = tick{i};
        for method = methods
            try
                stock.(method{:})  = ds.(method{:});
            catch ME
                stock.(method{:}) = ME.message;
                msg = ['Failed: ' ME.message];
                disp(msg);
            end
        end
        
        data.(ds.getName)(i) = stock;
    end
    fprintf('\n');
    
    if rem(i, 50) == 0
        save([date '_Stock_Data.mat'],'data');
    end
end

%%
save([date '_Stock_Data.mat'],'data');