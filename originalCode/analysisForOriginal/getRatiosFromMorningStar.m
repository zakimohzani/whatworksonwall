function out = getRatiosFromMorningStar(tick)

out.tick = tick;

%% price from Yahoo
stockURL = ['http://finance.yahoo.com/d/quotes.csv?s=' tick '&f=p' ];
a = urlread(stockURL);
out.price = str2num(a);


%% data from morningstar
stockURL = ['http://financials.morningstar.com/ajax/exportKR2CSV.html?t=' tick ];
text = urlread(stockURL);

fn = 'deleteMe1.csv';
fileID = fopen(fn,'w');
fprintf(fileID, '%s',text);
fclose(fileID);

[~,~,formatted] = xlsread(fn);

line = returnLineFor(formatted,'Free Cash Flow Per Share USD');
freeCashFlowPerShare = cell2mat(line(end-1));

line = returnLineFor(formatted,'Earnings Per Share USD');
earningsPerShare = cell2mat(line(end-1));
out.PE = out.price / earningsPerShare;

line = returnLineFor(formatted,'Book Value Per Share USD');
bookPerShare = cell2mat(line(end-1));
out.PB = out.price / bookPerShare;

line = returnLineFor(formatted,'Revenue USD Mil');
revenue = cell2mat(line(end-1));

line = returnLineFor(formatted,'Shares Mil');
noOfShares = cell2mat(line(end-1));
revenuePerShare = revenue / noOfShares;
out.PS = out.price / revenuePerShare;

%% Enterprise Value
% FAILED because they're percentages
% line = returnLineFor(formatted,'Total Liabilities & Equity');
% tlte = cell2mat(line(end-1));
% 
% line = returnLineFor(formatted,'Cash & Short-Term Investments');
% csti = cell2mat(line(end-1));
% 
% out.EV = tlte - csti;



%% EBITDA
stockURL = [ 'http://financials.morningstar.com/ajax/ReportProcess4CSV.html?t=' tick '&reportType=is&period=12&dataType=A&order=asc&columnYear=5&number=3'];
text = urlread(stockURL);

fn = 'deleteMe2.csv';
fileID = fopen(fn,'w');
fprintf(fileID, '%s',text);
fclose(fileID);

[~,~,formatted] = xlsread(fn);

line = returnLineFor(formatted,'EBITDA');
out.EBITDA = cell2mat(line(end-1));
% out.EVEBITDA = out.EV / out.EBITDA;