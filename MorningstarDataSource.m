classdef MorningstarDataSource < DataSourceInterface
    %MorningstarDATASOURCE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        curTick
        cache
    end
    
    methods
        function this = MorningstarDataSource
            this.name = 'MorningStar';
        end
        
        function setTick(this, name)
            this.curTick = lower(name);
            this.cache = [];
        end
        
        function out = getPrice(this)
            this.ensureTickIsSet;
            url2 = this.getMorningstarURL;
            out = urlfilter(url2,'Last Price');
        end
        
        function out = getPE(this)
            out = NaN;
        end
        
        function out = getPB(this)
            this.ensureTickIsSet;
            url2 = this.getMorningstarURL;
            out = urlfilter(url2,'Price/Book');
        end      
        
        function out = getPS(this)
            this.ensureTickIsSet;
            url2 = this.getMorningstarURL;
            out = urlfilter(url2,'Price/Sales');
        end   
        
        function out = getEVEBITDA(this)
            out = NaN;
        end
        
        function out = getPFCF(this)
            this.ensureTickIsSet;
            url2 = this.getMorningstarURL;
            out = urlfilter(url2,'Price/Cash Flow');
        end
        
        function out = getDivYield(this)
            this.ensureTickIsSet;
            url2 = this.getMorningstarURL;
            out = urlfilter(url2,'Yield');
        end
        
        function out = getBuybackYield(this)
            out = NaN;
        end
        
        function out = getMarketCap(this)
            this.ensureTickIsSet;
            url2 = this.getMorningstarURL;
            out = urlfilter(url2,'Market Cap');
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
        
        function out = getMorningstarURL(this)
            url = [ 'http://quotes.morningstar.com/stock/s?t=' ... 
                    upper(this.curTick) ...
                    '&culture=en_us&platform=RET&viewId1=2245602611&viewId2=3457102725&viewId3=3433352415&test=QuoteiFrame'];

            a = urlread(url);

            % break data into lines
            b = strread(a, '%s', 'delimiter', sprintf('\n'));

            % find location of loadHeader
            loc1 = find(~cellfun(@isempty, strfind(b,'function loadHeader')));

            % url is on the next line
            c = b{loc1+1,1};

            % get the url limiter locations
            locQuotes = strfind(c,'"');

            % get url
            url = ['http:' c(locQuotes(1)+1:locQuotes(2)-1)];

            % retrieve
            %out = urlread(url);
            out = url;
        end
    end
 
end

