classdef DataSourceInterfaceTest < matlab.unittest.TestCase
    % test the default data source
    
    properties
        ds
        prevDir
    end
    
% This feature is not available for MATLAB < 2016
    properties (ClassSetupParameter)
        classNames = {'FinVizDataSource','MorningstarDataSource','YahooDataSource'};
    end
    
    methods (TestClassSetup)
        function addPath(testCase, classNames)
            testCase.prevDir = pwd;
            testCase.addTeardown(@testCase.changeDirectoryBack);
            import matlab.unittest.fixtures.PathFixture
            
            f = testCase.applyFixture(PathFixture('..'));
            disp(['Added to path: ' f.Folder])
            Initialise;
            testCase.ds = eval(classNames);
            testCase.ds.setTick('msft');
        end
    end
    
    methods (Test)
        function getPrice(testCase)
            actual = testCase.ds.getPrice;
            testCase.assertInstanceOf(actual,'double');
        end
        
        function getPE(testCase)
            actual = testCase.ds.getPE;
            testCase.assertInstanceOf(actual,'double');
        end
        
        function getPS(testCase)
            actual = testCase.ds.getPS;
            testCase.assertInstanceOf(actual,'double');
        end
        
        function getPB(testCase)
            actual = testCase.ds.getPB;
            testCase.assertInstanceOf(actual,'double');
        end
        
        function getPFCF(testCase)
            actual = testCase.ds.getPFCF;
            testCase.assertInstanceOf(actual,'double');
        end
        
        function getEVEBITDA(testCase)
            actual = testCase.ds.getEVEBITDA;
            testCase.assertInstanceOf(actual,'double');
        end
        
        function getDivYield(testCase)
            actual = testCase.ds.getDivYield;
            testCase.assertInstanceOf(actual,'double');
        end
        
        function getBuybackYield(testCase)
            actual = testCase.ds.getBuybackYield;
            testCase.assertInstanceOf(actual,'double');
        end
        
        function getMarketCap(testCase)
            actual = testCase.ds.getMarketCap;
            testCase.assertInstanceOf(actual,'double');
        end
        
        function getShareholderYield(testCase)
            actual = testCase.ds.getShareholderYield;
            testCase.assertInstanceOf(actual,'double');
        end
        
        function changeDirectoryBack(testCase)
            cd(testCase.prevDir);
        end
    end
    
end 
