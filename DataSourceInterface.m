%classdef (Abstract) DataSourceInterface < handle
classdef DataSourceInterface < handle
    %DATASOURCEINTERFACE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name
    end
    
    methods (Abstract)
       getPrice(this)
       getPE(this)
       getPB(this)
       getPS(this)
       getPFCF(this)
       getEVEBITDA(this)
       getShareholderYield(this)
       get6monthPricePercentageChange(this)
       setTick(this,tick)
    end
    
    % defaults
    methods
        function out = getName(this)
            out = this.name;
        end
    end
    
end

