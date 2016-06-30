classdef YahooDataSource < DataSourceInterface
    %YahooDataSource Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        curTick
        cache
    end
    
    methods
        function this = YahooDataSource
            this.name = 'Yahoo';
        end
        
        function setTick(this, name)
            this.curTick = lower(name);
            this.cache = [];
        end
        
        function out = getPrice(this)
            out = NaN;
        end
        
        function out = getPE(this)
            this.ensureTickIsSet;
            dat = this.getValuationTable;
            lineNo = find(~cellfun(@isempty,strfind(dat(:,1), 'Trailing P/E')));
            t1 = cell2mat(dat(lineNo,2));
            out = str2double(t1);
        end
        
        function out = getPB(this)
            this.ensureTickIsSet;
            dat = this.getValuationTable;
            lineNo = find(~cellfun(@isempty,strfind(dat(:,1), 'Price/Book')));
            t1 = cell2mat(dat(lineNo,2));
            out = str2double(t1);
        end      
        
        function out = getPS(this)
            this.ensureTickIsSet;
            dat = this.getValuationTable;
            lineNo = find(~cellfun(@isempty,strfind(dat(:,1), 'Price/Sales')));
            t1 = cell2mat(dat(lineNo,2));
            out = str2double(t1);
        end   
        
        function out = getEVEBITDA(this)
            this.ensureTickIsSet;
            dat = this.getValuationTable;
            lineNo = find(~cellfun(@isempty,strfind(dat(:,1), 'Enterprise Value/EBITDA')));
            t1 = cell2mat(dat(lineNo,2));
            out = str2double(t1);
        end
        
        function out = getPFCF(this)
            %disp('getPFCF not implemented');
            out = NaN;
        end
        
        function out = getDivYield(this)
            % Part1: get div yield first
            this.ensureTickIsSet;
            url = ['http://finance.yahoo.com/q/ks?s=' upper(this.curTick)];
            dat = getTableFromWeb_mod(url, 16);
            lineNo = find(~cellfun(@isempty,strfind(dat(:,1), 'Trailing Annual Dividend Yield')));
            % get the second line and strip the percentage sign
            if isempty(lineNo)
                error('Can''t get dividend yield');
            end
            num = strtok(dat(lineNo(2),2),'%');
            out = str2double(num{:});
        end
        
        function out = getBuybackYield(this)
            stockURL = ['http://finance.yahoo.com/q/cf?s=' upper(this.curTick) '&ql=1'];
            %disp(tick{jj}); % Used for debug purposes

            buffer = java.io.BufferedReader(...
                java.io.InputStreamReader(...
                openStream(...
                java.net.URL(stockURL))));
            lcount = 0;
            loop = 1;
            runningtot = 0;
            ll = 0;

            while loop
                tline = char(readLine(buffer));
                if regexp(tline,'There.is.no.Cash.Flow')
                    error('no data');
                end
                if regexp(tline,'Get.Quotes.Results.for')
                    error('can''t locate the ticker');
                end
                if regexp(tline,'Changed.Ticker.Symbol') 
                    error('ticker symbol has been changed, ignore');
                end
                if regexp(tline,'</html>') % 
                    error('We''ve reached the end of the html, the data''s not here');
                end
                if regexp(tline,'Sale.Purchase.of.Stock') % contains the Sale/Purchase of Stock information
                    if regexp(tline,'Net.Borrowings') % find if the line contains borrowings detail as well
                        tline = regexprep(tline,'Net.Borrowings.*',''); % remove all extra data
                    end
                    tline = tline(regexp(tline,'Sale.Purchase.of.Stock'):end); % trim prior data.
                    posneg = regexprep(tline,'(','-'); % determine buys or sells.  (X,XXX) becomes -X,XXX)
                    nocommas = regexprep(posneg,',|)',''); % eliminates commas and close parens.  -X,XXX) becomes -XXXX
                    remhtml = regexprep(nocommas,'<.*?>|&nbsp;',','); % remove HTML data and various markup, replacing them with commas
                    starts = regexp(remhtml,',\d+,|,.\d+'); % locate the beginning of quarterly Sale Purchase Data points
                    ends = regexp(remhtml,'\d,'); % locate the end of the quarterly Sale Purchase Data points
                    for ll = 1:length(starts)
                        runningtot = runningtot + str2double(remhtml(starts(ll)+1:ends(ll)))*1000; % Sum up all of the buys and sells
                    end
                    break
                end
            end
            out = -1*runningtot/this.getMarketCap*100; % Buy back yield as a percentage of current market cap
        end
        
        function out = getMarketCap(this)
            this.ensureTickIsSet;
            dat = this.getValuationTable;
            lineNo = find(~cellfun(@isempty,strfind(dat(:,1), 'Market Cap')));
            raw = dat{lineNo,2};
            switch raw(end)
                case 'B'
                    scale = 1e9;
                case 'M'
                    scale = 1e6;
                case 'K'
                    scale = 1e3;
                otherwise
                    error('unknown scale %s', raw(end-1));
            end
                    
            out = str2num(raw(1:end-1)) * scale;
        end
        
        function out = getShareholderYield(this)
            out = this.getDivYield + this.getBuybackYield;
        end
        
        function out = get6monthPricePercentageChange(this)
            out = NaN;
        end
        
    end
    
    methods (Access=protected)
        function ensureTickIsSet(this)
            if isempty(this.curTick)
                error('Please use setTick(name) first');
            end
        end
        
        function out = getValuationTable(this)
            if isfield(this.cache,'ValuationTable')
                if ~isempty(this.cache.ValuationTable)
                    out = this.cache.ValuationTable;
                    return
                end
            end
            
            url = ['http://finance.yahoo.com/q/ks?s=' upper(this.curTick)];
            out = getTableFromWeb_mod(url, 4);
            this.cache.ValuationTable = out;
        end
    end
    
end

