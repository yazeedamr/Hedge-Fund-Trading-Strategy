% AQR Momentum
% Author: Yazeed Amr
%
% Purpose: To calculate cumulative returns of the recommended strategy that
% allows mutual funds to capitulate on the phenmomenon of momentum trading
% -------------------------------------------------------------------------
% Variables used:
 
% crsp = table including hstorical data regarding stocks
 
% momentum = created table using unique dates found in crsp in order to
% simplify the calculations of monthly returns, and thus, cumulative returns.
 
% rankVariable = column used to calculate momentum for each stock at every
% point in time available in the data (using the getMomentum function). 
% Used in order to label stocks as either 'Winners' or 'Losers'.
 
% lagMarketCap = column used to gather the lagged market caps (using the
% lagCap function). This allows for more precision while looking at the 
% strategy, due to the fact thaat the end of month market cap for each 
% stock would not be known at the time of initial investment.
 
% isInvestible = logical vector used to remove stocks with NaNs as their
% respective returns in certain months.
 
% isWinner = logical vector used to filter out the 10th decile of stocks
% regarding their respective calculations of momentum. Labelled as 'winner'
% stocks.
 
% isLoser = logical vector used to filter out the 1st decile of stocks
% regarding their respective calculations of momentum. Labelled as 'winner'
% stocks.
 
% Please note that other, more miniscule variables, will be explained
% throughout the following code.
% -------------------------------------------------------------------------
% Functions used & Other files used:
 
% getMomentum: used in order to calculate momentum of stocks in crsp.
% The getMomentum function can be found in the file getMomentum.m
 
% lagCap: used in order to lag market caps by 1 month. The lagCap function 
% can be found in the file lagCap.m

%% 1 - Import data
crsp=readtable('crsp20042008.csv');
 
%% 2 - Construct Variable year, month, datenum
crsp.datenum=datenum(num2str(crsp.DateOfObservation),'yyyymmdd');
crsp.year=year(crsp.datenum);
crsp.month=month(crsp.datenum);
 
%% 3 - Create getMomentum function & Calculate momentum
% getMomentum function can be found in the getMomentum.m file
 
% Calculating momentum:
for i = 1:height(crsp)
    crsp.rankVariable(i) = getMomentum(crsp.PERMNO(i),crsp.year(i),...
    	crsp.month(i),crsp);
end
 
%% 4 - Create lagCap function&produce column in crsp with lag Market Caps
% This is done since, if we were to actually execute the strategy, we can't
% forecast the market cap at the end of the month, while deciding to invest
% at the beginning of the period. This is done for portfolio weights.
 
% lagCap function can be found in the lagCap.m file
 
% Producing a column with lagged Market Caps:
for i = 1:height(crsp)
    crsp.lagMarketCap(i) = lagCap(crsp.PERMNO(i),crsp.year(i),...
    	crsp.month(i),crsp);
end
%% 5 - Calculate returns (Momentum, then final strategy)
% Create 'momentum' table with unique dates
momentum=table(unique(crsp.datenum),'VariableNames',{'datenum'});
momentum.year=year(momentum.datenum);
momentum.month=month(momentum.datenum);
for i=1:height(momentum)
thisYear=momentum.year(i);
thisMonth=momentum.month(i);
% Must remove NaNs:
isInvestible=(crsp.year==thisYear&crsp.month==thisMonth&...
    ~isnan(crsp.Returns));
% Momentum of "investible" stocks:
thisRankVar=crsp.rankVariable(isInvestible);
% Return of "investible" stocks:
thisRet=crsp.Returns(isInvestible);
% Lagged Market Cap of "investible" stocks:
thisMarketCap=crsp.lagMarketCap(isInvestible);
% Define Winners as highest 10% regarding momentum (10th decile):
isWinner=(thisRankVar>=quantile(thisRankVar,.9));
isWinner(isWinner<0)=0;
% Define Losers as lowest 10% regarding momentum (1st decile):
isLoser=(thisRankVar<=quantile(thisRankVar,.1));
isLoser(isLoser<0)=0;
thisW=thisMarketCap.*isWinner;
thisW=thisW./nansum(thisW); % Value-weighted based on lagged market caps
thisL=thisMarketCap.*isLoser;
thisL=thisL./nansum(thisL); % Value-weighted based on lagged market caps
momentum.momW(i)=nansum(thisW.*thisRet); % Returns on winner stocks
momentum.momL(i)=nansum(thisL.*thisRet); % Returns on loser stocks
momentum.momW(momentum.momW==0)=NaN;
momentum.momL(momentum.momL==0)=NaN; % doing this as we cannot be invested
% in the momentum portfolio in the first year
momentum.mom=momentum.momW-momentum.momL; % this column contains the
% long-short momentum strategy. This was included for the sake of
% comparison with our final equally weighted momentum strategy.
 
% Replicating the desired strategy:
% If winner stock, will invest twice as much (isWinner=1, isLoser=0)
% If middle stock, will invest (isWinner=0, isLoser=0)
% If loser stock, won't invest, won't short (isWinner=0, isLoser=1)
wStrat=thisMarketCap.*(1+isWinner-isLoser);
wStrat=wStrat./nansum(wStrat);
momentum.stratReturn(i)=nansum(wStrat.*thisRet);
end
 
for i=1:12
    momentum.stratReturn(i)=NaN;
    % Done in order to nullify the first 12 months; technically we are
    % not supposed to be invested during this time as we couldn't
    % have calculated momentum. (Due to momentum's definition)
end
%% 6 - Calculate cumulative returns
thisCumReturn=momentum.momW;
thisCumReturn(isnan(thisCumReturn))=0;
momentum.wCumulativeRet=cumprod(thisCumReturn+1)-1;
 
thisCumReturn1=momentum.mom;
thisCumReturn1(isnan(thisCumReturn1))=0;
momentum.momCumulativeRet=cumprod(thisCumReturn1+1)-1;
 
thisCumReturn2=momentum.stratReturn;
thisCumReturn2(isnan(thisCumReturn2))=0;
momentum.stratCumulativeRet=cumprod(thisCumReturn2+1)-1;
 
thisCumReturn3=momentum.momL;
thisCumReturn3(isnan(thisCumReturn3))=0;
momentum.LCumulativeRet=cumprod(thisCumReturn3+1)-1;
 
%% 7 - Plot the strategies cumulative returns with time
figure;
x1=plot(momentum.datenum,momentum.wCumulativeRet*100,'LineWidth',2);
datetick('x','yyyymmm');
hold on
x2=plot(momentum.datenum,momentum.momCumulativeRet*100,'LineWidth',2);
datetick('x','yyyymmm');
hold on
x3=plot(momentum.datenum,momentum.stratCumulativeRet*100,'LineWidth',2);
datetick('x','yyyymmm');
x4=plot(momentum.datenum,momentum.LCumulativeRet*-100,'LineWidth',2);
datetick('x','yyyymmm');
legend([x1,x2,x3,x4],{'Winner-Long','Momentum Long-Short',...
    'Equally Weighted Momentum','Loser-Short'},'Location','northwest');
title('Different Strategies Cumulative Returns with Time')
xlabel('Dates');
ylabel('Cumulative Returns (%)')
hold off
