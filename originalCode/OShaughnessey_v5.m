% This script is designed to replicate the work performed by James
% O'Shaughnessey as detailed in his book, "What Works on Wall Street."  I
% do not claim this method as my own or vouch for its effectiveness in
% securing future results.  
%
% The basic principle of the "Trending Value" method is as follows:
% Each company is scored on 6 performance metrics:
%   * Price to Earnings (P/E ratio)
%   * Price to Sales (P/S ratio)
%   * Price to Book (P/B ratio)
%   * Price to Free Cash Flow (P/FCF ratio)
%   * Enterprise Value / EBITDA (EV/EBITDA ratio)
%   * Shareholder Yield (Dividend Yield + Buyback Yield = equity returned
%   to the investors)
%
% These are scored on a rank of 0-100, where 100 is the "best" ratio in the
% entire stock universe, and 0 is the worst.  The scores are then added to
% create a stock's intrinsic value relative to the market.  600 is the
% utlimate score and represents a stock that is incredibly undervalued
% compared to the market.
%
% The scores are then arragned in decending order and the top 10% is
% extracted for further sorting.  It is re-arranged by 6-month price
% momentum.  We buy the top 25 in equal amounts.  These are 25 under valued
% companies that the market is rallying behind.
%
% Hold for 1 year, liquidate everything, do it again.  Historically, this
% has returned an average of 21.2% per year.
%
% As will all investing, do you due diligence prior to buying.  Also,
% PLEASE do not attempt this method with less than $25,000.  As small time
% individual investors, we fight against both the market and commission
% structures.  This method has 25 buys and 25 sells per year.  50
% transactions can be expensive.  At $8/trade, that's $400.  Even if you're
% investing $25,000, the trading fees will eat up 1.6% of your principle!
% You are better off investing in an "own the S&P500" fund like FUSVX which
% charges .05% of your principle.
%
% Some fields are empty for various equities.  For example, a mutual fund
% will not report an EV/EBITDA value.  To allow this program to run, these
% numbers are artificially set to 0 or 100000, depending on the metric being
% replaced.  There is other error checking in place which will artifically
% assign 0 or 100000 values to move on in the script.
%
% To query this data afterwards, it's recommended to use the GetStockData
% function.
%
% One last note: This was not written for complete efficiency.  It's a
% brute force method of grabbing the data.  The first time I ran the script
% successfully, it took me 1 hour and 42 minutes, of which 1 hour and 36
% minutes was spent grabbing the EV/EBITDA data alone.  While it likely can
% be optimized, O'Shaughnessey's method is implemented once per year, so it
% was not deemed overly important.  Each of the revisions has increased the
% efficiency, but it's not the goal of this program to be completely
% streamlined.
%
% Written by Justin Riley
% 21-August, 2012
%
% Version 5 updated 1-June, 2014
%
% Distribution Unlimited
% NOT FOR SALE

clear;

tic

% Grab data from finviz.  This runs a screener for all stocks with a market
% cap > $200M in the All Stocks universe.  Financials are reported (denoted
% with the numbers at the end of the URL).  Everything we need is here
% except for stock buybacks and EBITDA/EV.
stockURL = 'http://finviz.com/screener.ashx?v=152&f=cap_smallover&ft=4&c=0,1,2,6,7,10,11,13,14,45,65';

buffer = java.io.BufferedReader(...
    java.io.InputStreamReader(...
    openStream(...
    java.net.URL(stockURL))));

ii = 0; % stock counter

% search the source for the number of pages we'll have to search and then
% pull stock data
tic
loop = 1;
while loop
    tline  = char(readLine(buffer));
    if length(tline) > 40
        if strcmp(tline(1:40),'<option selected="selected" value=1>Page')
            b1 = find(tline == '/'); b2 = find(tline == '<'); % string identifiers
            numpages = str2double(tline(b1(1)+1:b2(2)-1)); % Number of pages with stock data
            loop = 0;
        end
    end
end
toc

loop = 1;
while loop
    tline = char(readLine(buffer));
    if length(tline) > 15
        if strcmp(tline(1:15),'<td height="10"') % stock table identifier
            ii = ii + 1; % increment stock counter
            % parse the data by first identifying symbols and then storing the
            %clear data
            rem = regexprep(tline,'</td>','`'); % replace all table data breaks with backticks (just an odd delimeter)
            stkraw = regexprep(rem,'<.*?>',''); % remove all remaining HTML data
            d1 = regexp(stkraw,'(`|>)'); % locate the backticks and unbalanced HTML
            tick(ii) = {stkraw(d1(2)+1:d1(3)-1)}; % ticker symbol
            name(ii) = {stkraw(d1(3)+1:d1(4)-1)}; % company name
            if stkraw(d1(5)-1) == 'B'
                capmult = 1000000000;
            else
                capmult = 1000000;
            end
            mktcap(ii) = str2num(stkraw(d1(4)+1:d1(5)-2)) * capmult; % market cap     
            pe_s(ii) = {stkraw(d1(5)+1:d1(6)-1)}; % Price/Earnings Ratio
            ps_s(ii) = {stkraw(d1(6)+1:d1(7)-1)}; % Price/Sales Ratio
            pb_s(ii) = {stkraw(d1(7)+1:d1(8)-1)}; % Price/Book Ratio
            pfcf_s(ii) = {stkraw(d1(8)+1:d1(9)-1)}; % Price/Free Cash Flow Ratio
            div_s(ii) = {stkraw(d1(9)+1:d1(10)-2)}; % Dividend Yield
            mom_s(ii) = {stkraw(d1(10)+1:d1(11)-2)}; % 6-month relative price strength
            price_s(ii) = {stkraw(d1(12)+1:d1(13)-1)}; % Current stock price
        end
    end
    if ii > 0 && length(tline) < 10
        loop = 0;
    end
end

% Now that the first page of stocks (20) is exhausted, we have to start
% advancing pages

for jj = 2:numpages
    stockURL = ['http://finviz.com/screener.ashx?v=152&f=cap_smallover&ft=4&r=' num2str(jj*20+1) '&c=0,1,2,6,7,10,11,13,14,45,65'];
    
    buffer = java.io.BufferedReader(...
        java.io.InputStreamReader(...
        openStream(...
        java.net.URL(stockURL))));

    loop = 1;
    stktrigger = 0; % can't use i as the trigger anymore

    while loop
        tline = char(readLine(buffer));
        if length(tline) > 15
            if strcmp(tline(1:15),'<td height="10"') % stock table identifier
                ii = ii + 1; % increment stock counter
                if stktrigger == 0
                    stktrigger = 1;
                end
                % parse the data by first identifying symbols and then storing the
                %clear data
                rem = regexprep(tline,'</td>','`'); % replace all table data breaks with backticks (just an odd delimeter)
                stkraw = regexprep(rem,'<.*?>',''); % remove all remaining HTML data
                d1 = regexp(stkraw,'(`|>)'); % locate the backticks and unbalanced HTML
                tick(ii) = {stkraw(d1(2)+1:d1(3)-1)}; % ticker symbol
                name(ii) = {stkraw(d1(3)+1:d1(4)-1)}; % company name
                if stkraw(d1(5)-1) == 'B'
                    capmult = 1000000000;
                else
                    capmult = 1000000;
                end
                mktcap(ii) = str2num(stkraw(d1(4)+1:d1(5)-2)) * capmult; % market cap
                pe_s(ii) = {stkraw(d1(5)+1:d1(6)-1)}; % Price/Earnings Ratio
                ps_s(ii) = {stkraw(d1(6)+1:d1(7)-1)}; % Price/Sales Ratio
                pb_s(ii) = {stkraw(d1(7)+1:d1(8)-1)}; % Price/Book Ratio
                pfcf_s(ii) = {stkraw(d1(8)+1:d1(9)-1)}; % Price/Free Cash Flow Ratio
                div_s(ii) = {stkraw(d1(9)+1:d1(10)-2)}; % Dividend Yield
                mom_s(ii) = {stkraw(d1(10)+1:d1(11)-2)}; % 6-month relative price strength
                price_s(ii) = {stkraw(d1(12)+1:d1(13)-1)}; % Current stock price
            end
        end
        if stktrigger > 0 && length(tline) < 10
            loop = 0;
        end
    end
end

toc
tic
% Yahoo! finance reports EV/EBITDA on each stock's Key Statistics page.

% pre-allocate EV/EBITDA for speed -- how to preallocate cells?


for jj = 1:ii
    stockURL = ['http://finance.yahoo.com/q/ks?s=' tick{jj} '+Key+Statistics'];
    %disp(tick{jj}); % Used for debug purposes
    
    buffer = java.io.BufferedReader(...
        java.io.InputStreamReader(...
        openStream(...
        java.net.URL(stockURL))));
    loop = 1;
    while loop
        tline = char(readLine(buffer));
        if regexp(tline,'There.is.no.Key.Statistics') % non-financial file like a mutual fund
            evebitda_s(jj) = {'1000'}; % artificially assign the evebitda value to something high.
            %disp([tick{jj} ' is a fund with no EV/EBITDA information']); % used for debug purposes
            break
        end
        if regexp(tline,'Get.Quotes.Results.for') % can't locate the ticker
            evebitda_s(jj) = {'1000'};
            break
        end
        if regexp(tline,'Changed.Ticker.Symbol') % ticker symbol has been changed, ignore
            evebitda_s(jj) = {'1000'};
            break
        end
        if regexp(tline,'</html>') % reached the end of html, haven't found the data
            evebitda_s(jj) = {'1000'};
            break
        end
        if regexp(tline,'Enterprise.Value/EBITDA') % if the line contains EV/EBITDA info, grab it
            rem = regexprep(tline,'</td>','`'); % same as abefore, replace table breaks with a weird delimiter
            stkraw = regexprep(rem,'<.*?>',''); % remove all HTML data, leaving just the stock data
            d1 = regexp(stkraw,'`'); % locate backticks
            for kk = 1:numel(d1)-1
                if strcmp(stkraw(d1(kk)+1:d1(kk)+23),'Enterprise Value/EBITDA')
                    evebitda_s(jj) = {stkraw(d1(kk+1)+1:d1(kk+2)-1)};
                    break
                end
            end
            %disp([tick{jj} ' is good']); % used for debug purposes.
            break
        end
    end
    if mod(jj,100) == 0
        disp(['EV/EBITDA #' num2str(jj) ' of ' num2str(ii) ' completed.']); % track progress
    end
end

toc
tic

BBY = zeros(1,ii); % preallocate buyback yield (BBY)

for mm = 1:ii
    stockURL = ['http://finance.yahoo.com/q/cf?s=' tick{mm} '&ql=1'];
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
        if regexp(tline,'There.is.no.Cash.Flow') % no data
            break
        end
        if regexp(tline,'Get.Quotes.Results.for') % can't locate the ticker
            break
        end
        if regexp(tline,'Changed.Ticker.Symbol') % ticker symbol has been changed, ignore
            break
        end
        if regexp(tline,'</html>') % We've reached the end of the html, the data's not here
            break
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
    BBY(mm) = -1*runningtot/mktcap(mm)*100; % Buy back yield as a percentage of current market cap
    if mod(mm,100) == 0
        disp(['BBY #' num2str(mm) ' of ' num2str(ii) ' completed.']); % track progress
    end
end
toc
tic

% Now that all of the data is imported, let's find errors caused by
% negative earnings or no dividends, etc.


% Convert everything to workable numbers
pe = str2double(pe_s);
ps = str2double(ps_s);
pb = str2double(pb_s);
pfcf = str2double(pfcf_s);
div = str2double(div_s);
mom = str2double(mom_s);
price = str2double(price_s);
evebitda = str2double(evebitda_s);

% Identify and repair all NaNs.
badpe = find(isnan(pe));
badps = find(isnan(ps));
badpb = find(isnan(pb));
badpfcf = find(isnan(pfcf));
baddiv = find(isnan(div));
badmom = find(isnan(mom));
badev = find(isnan(evebitda));

% Find EV/EBITDA values < 0 (I'm not sure how this happens, but it happens
% and I don't like it!)
badev2 = find(evebitda < 0);

% artificially set P/E, P/S, P/B at 100000 for sorting purposes.  This value
% should be high enough (or low enough) where it automatically ranks them
% last/tied for last
pe(badpe) = 100000; 
ps(badps) = 100000;
pb(badpb) = 100000;
pfcf(badpfcf) = 100000;
div(baddiv) = 0; % no dividend paid
mom(badmom) = 0; % no positive price momentum
evebitda(badev) = 100000;
evebitda(badev2) = 100000;

% Define shareholder yield as dividend + buyback yield
shyield = div + BBY;

% Rank stocks based on each metric

perank = ((-1*tiedrank(pe)/length(pe))+1)*100; % Rank P/E values, with the lowest getting 100
psrank = ((-1*tiedrank(ps)/length(ps))+1)*100; % Rank P/S values, with the lowest getting 100
pbrank = ((-1*tiedrank(pb)/length(pb))+1)*100; % Rank P/B values, with the lowest getting 100
pfcfrank = ((-1*tiedrank(pfcf)/length(pfcf))+1)*100; % Rank P/FcF values, with the lowest getting 100
shyieldrank = tiedrank(shyield)/length(shyield)*100; % Rank shareholder yield values, with the highest getting 100
evrank = ((-1*tiedrank(evebitda)/length(evebitda))+1)*100; % Rank EV/EBITDA value, with the lowest getting 100

stkrank = perank + psrank + pbrank + pfcfrank + shyieldrank + evrank; % Total stock valuation

% identify the top performing decile
ovrrnk = tiedrank(stkrank)/length(stkrank);
tops = find(ovrrnk > 0.9);

% sort top decile by price momentum
momtops = tiedrank(mom(tops));
mom_backup = mom; % just a backup for reference as we delete items from the original in the next step

% return top n stocks
for kk = 1:25
    topmom = find(mom == max(mom(tops))); % If two stocks have the same price momentum, it will return all of them, regardless of whether or not it's in the top decile
    if numel(topmom) > 1 % check for multiple entries
        for n = 1:length(topmom)
            if ovrrnk(topmom(n)) > 0.9 % make sure the entry is in the top decile
                topmom = topmom(n);
                break
            end
        end
    end
    stk(kk) = topmom;
    mom(topmom) = -100; % artificially decrease price momentum to -100% so that it's no longer the max in the data set
end
mom = mom_backup; % repair momentum variable for later analysis
disp(tick(stk)); % If you've already run the script and just want to display the stocks, use tick(stk).  Also for specific data, like p/e of those, pe(stk).
toc

% Save the data for later use
svname = [date '_Stock_Data'];
save(svname,'pe','perank','ps','psrank','pb','pbrank','pfcf','pfcfrank','evebitda','evrank','div','shyield','shyieldrank','stkrank','ovrrnk','mom','tick','name','price','stk')