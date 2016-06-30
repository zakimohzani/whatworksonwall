% GetStockData('ticker')
%
% GetStockData is designed to work with the outputs of the OShaughnessey.m
% stock valuation script.  It is a simplified way to recall and display
% data for any given ticker symbol.  Additionally, not specifying a ticker
% - i.e. calling GetStockData - will return the outputs of OShaughnessey.m.
%
% Example:
% Recall the data for Apple, Inc.  Stock ticker 'AAPL'.
% GetStockData('AAPL')
% returns:
% 
% Ticker Symbol: AAPL, $530.38
% Apple Inc.
% P/E: 12.93   P/E Rank: 76.4101
% P/S: 3.48   P/S Rank: 32.3465
% P/B: 4.84   P/B Rank: 32.3465
% P/fcf: 11.12   P/fcf Rank: 88.6725
% Div: 0%   Div Rank: 19.7414
% EV/EBITDA: 8.78   EV/EBITDA Rank: 61.3898
% 6 month price momentum: 37.84%
% Overall Rank: 300.4674   Percentile: 48.551%

% Written by Justin Riley
% 22-May-2012
% Unlimited Distribution
% Not for sale


function GetStockData(input1)

pe = evalin('base','pe');
perank = evalin('base','perank');
ps = evalin('base','ps');
psrank = evalin('base','psrank');
pb = evalin('base','pb');
pbrank = evalin('base','pbrank');
pfcf = evalin('base','pfcf');
pfcfrank = evalin('base','pfcfrank');
evebitda = evalin('base','evebitda');
evrank = evalin('base','evrank');
div = evalin('base','div');
shyield = evalin('base','shyield');
shyieldrank = evalin('base','shyieldrank');
stkrank = evalin('base','stkrank');
ovrrnk = evalin('base','ovrrnk');
mom = evalin('base','mom');
tick = evalin('base','tick');
name = evalin('base','name');
price = evalin('base','price');
stk = evalin('base','stk');

if nargin == 0
    input1 = stk;
end


n = numel(input1);
if isstr(input1)
    n = 1;
end

for ii = 1:n
    disp(' '); % increment line counter to break things up
    if isstr(input1)
        index = strmatch(input1,tick,'exact');
        if isempty(index)
            disp('No Such Ticker Symbol!');
            index = [];
            return
        end
    elseif isa(input1(ii),'numeric')
        index = input1(ii);
        if index > numel(pe)
            disp('Invalid index!');
            return
        else
            index = input1(ii);
        end
    end
    if isempty(index)
        return
    else
        disp(['Ticker Symbol: ' tick{index} ', $' num2str(price(index))]);
        disp(name{index});
        disp(['P/E: ' num2str(pe(index)) '   P/E Rank: ' num2str(perank(index))]);
        disp(['P/S: ' num2str(ps(index)) '   P/S Rank: ' num2str(psrank(index))]);
        disp(['P/B: ' num2str(pb(index)) '   P/B Rank: ' num2str(pbrank(index))]);
        disp(['P/fcf: ' num2str(pfcf(index)) '   P/fcf Rank: ' num2str(pfcfrank(index))]);
        disp(['SHYield: ' num2str(shyield(index)) '%   SHYield Rank: ' num2str(shyieldrank(index))]);
        disp(['Dividend: ' num2str(div(index)) '%']);
        disp(['EV/EBITDA: ' num2str(evebitda(index)) '   EV/EBITDA Rank: ' num2str(evrank(index))]);
        disp(['6 month price momentum: ' num2str(mom(index)) '%']);
        disp(['Overall Rank: ' num2str(stkrank(index)) '   Percentile: ' num2str(ovrrnk(index)*100) '%']);
    end
end