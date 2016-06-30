function getDataIntoMatFile(fn, ds)
% ds is DataSourceInterface object

stocks = [];
for i  = 1:length(tick)
    ds.setTick(tick{i});
    disp(sprintf('%d of %d : %s', i, length(tick), tick{i}));
    stocks(i).name = tick{i};
    for method = methods
        try
            stocks(i).(method{:})  = ds.(method{:});
        catch ME
            stocks(i).(method{:}) = ME.message;
            msg = ['Failed: ' ME.message];
            disp(msg);
        end
    end
end

save(fn,'stocks');