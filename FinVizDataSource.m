classdef FinVizDataSource < DataSourceInterface
    %FinVizDataSource Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        curTick
        cache
        
    end
    
    methods
        function this = FinVizDataSource
            this.name = 'FinViz';
        end
        
        function setTick(this, name)
            this.curTick = lower(name);
            this.cache = [];
        end
        
        function out = getPrice(this)
            this.ensureTickIsSet;
            dat = this.getValuationTable;
            targetLabel = 'Price';
            % there could be 2 labels e.g. P/Es and Forward P/E
            idxlabelMult = find(~cellfun('isempty',strfind(dat,targetLabel)));
            idx2 = find(strcmp(dat(idxlabelMult),targetLabel));
            if ~strcmp(dat(idxlabelMult(idx2)),targetLabel)
                error('not matching');
            end
            idxlabel = idxlabelMult(idx2);
            idxvalue = idxlabel+size(dat,1);
            t1 = dat{idxvalue};
            
            if isa(t1,'double')
                out = t1;
            else
                out = str2double(t1);
            end
        end
        
        function out = getPE(this)
            this.ensureTickIsSet;

            dat = this.getValuationTable;
            targetLabel = 'P/E';
            % there could be 2 labels e.g. P/Es and Forward P/E
            idxlabelMult = find(~cellfun('isempty',strfind(dat,targetLabel)));
            idx2 = find(strcmp(dat(idxlabelMult),targetLabel));
            if ~strcmp(dat(idxlabelMult(idx2)),targetLabel)
                error('not matching');
            end
            idxlabel = idxlabelMult(idx2);
            idxvalue = idxlabel+size(dat,1);
            t1 = dat{idxvalue};
            
            if isa(t1,'double')
                out = t1;
            else
                out = str2double(t1);
            end
        end
        
        function out = getPB(this)
            this.ensureTickIsSet;
            dat = this.getValuationTable;
            targetLabel = 'P/B';
            % there could be 2 labels e.g. P/Es and Forward P/E
            idxlabelMult = find(~cellfun('isempty',strfind(dat,targetLabel)));
            idx2 = find(strcmp(dat(idxlabelMult),targetLabel));
            if ~strcmp(dat(idxlabelMult(idx2)),targetLabel)
                error('not matching');
            end
            idxlabel = idxlabelMult(idx2);
            idxvalue = idxlabel+size(dat,1);
            t1 = dat{idxvalue};
            
            if isa(t1,'double')
                out = t1;
            else
                out = str2double(t1);
            end
        end      
        
        function out = getPS(this)
            this.ensureTickIsSet;
            dat = this.getValuationTable;
            targetLabel = 'P/S';
            % there could be 2 labels e.g. P/Es and Forward P/E
            idxlabelMult = find(~cellfun('isempty',strfind(dat,targetLabel)));
            idx2 = find(strcmp(dat(idxlabelMult),targetLabel));
            if ~strcmp(dat(idxlabelMult(idx2)),targetLabel)
                error('not matching');
            end
            idxlabel = idxlabelMult(idx2);
            idxvalue = idxlabel+size(dat,1);
            t1 = dat{idxvalue};
            
            if isa(t1,'double')
                out = t1;
            else
                out = str2double(t1);
            end
        end   
        
        function out = getEVEBITDA(this)
%             disp('getEVEBITDA is not implemented');
            out = NaN;
        end
        
        function out = getPFCF(this)
            this.ensureTickIsSet;
            dat = this.getValuationTable;
            targetLabel = 'P/FCF';
            % there could be 2 labels e.g. P/Es and Forward P/E
            idxlabelMult = find(~cellfun('isempty',strfind(dat,targetLabel)));
            idx2 = find(strcmp(dat(idxlabelMult),targetLabel));
            if ~strcmp(dat(idxlabelMult(idx2)),targetLabel)
                error('not matching');
            end
            idxlabel = idxlabelMult(idx2);
            idxvalue = idxlabel+size(dat,1);
            t1 = dat{idxvalue};
            
            if isa(t1,'double')
                out = t1;
            else
                out = str2double(t1);
            end
        end
        
        function out = getDivYield(this)
            this.ensureTickIsSet;
            url = ['http://finviz.com/quote.ashx?t=' upper(this.curTick)];
            t1 = urlfilter(url,'Dividend %');
            dat = this.getValuationTable;
            targetLabel = 'Dividend %';
            % there could be 2 labels e.g. P/Es and Forward P/E
            idxlabelMult = find(~cellfun('isempty',strfind(dat,targetLabel)));
            idx2 = find(strcmp(dat(idxlabelMult),targetLabel));
            if ~strcmp(dat(idxlabelMult(idx2)),targetLabel)
                error('not matching');
            end
            idxlabel = idxlabelMult(idx2);
            idxvalue = idxlabel+size(dat,1);
            t1 = dat{idxvalue};
            t1 = strtok(t1,'%');
            
            if isa(t1,'double')
                out = t1;
            else
                out = str2double(t1);
            end
        end
        
        function out = getBuybackYield(this)            
%             disp('getBuybackYield is not implemented');
            out = NaN;
        end
        
        function out = getMarketCap(this)
            this.ensureTickIsSet;
            dat = this.getValuationTable;
            idx = find(~cellfun('isempty',strfind(dat,'Market Cap')))+size(dat,1);
            raw = dat{idx};
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
                    
            out = str2double(raw(1:end-1)) * scale;
        end
        
        function out = getShareholderYield(this)
            out = this.getDivYield + this.getBuybackYield;
        end
        
        function out = get6monthPricePercentageChange(this)
            this.ensureTickIsSet;
            dat = this.getValuationTable;
            targetLabel = 'Perf Half Y';
            % there could be 2 labels e.g. P/Es and Forward P/E
            idxlabelMult = find(~cellfun('isempty',strfind(dat,targetLabel)));
            idx2 = find(strcmp(dat(idxlabelMult),targetLabel));
            if ~strcmp(dat(idxlabelMult(idx2)),targetLabel)
                error('not matching');
            end
            idxlabel = idxlabelMult(idx2);
            idxvalue = idxlabel+size(dat,1);
            t1 = dat{idxvalue};
            % remove percentage sign
            t1 = strtok(t1,'%');
            
            if isa(t1,'double')
                out = t1;
            else
                out = str2double(t1);
            end
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
            
            url = ['http://finviz.com/quote.ashx?t=' upper(this.curTick)];
            out = getTableFromWeb_mod(url, 6);
            this.cache.ValuationTable = out;
        end
    end
    
end

