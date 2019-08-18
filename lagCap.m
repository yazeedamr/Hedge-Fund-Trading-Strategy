%% lagCap.m = Lag-Market Cap Function
% finds market cap the month before for the sake of valuation with more
% financial sense. This allows us to calculate weights in the portfolio.
 
function z=lagCap(thisPermno,thisYear,thisMonth,crsp)
if thisMonth==1
    finalMonth=12;
else finalMonth=thisMonth-1;
end 
if thisMonth==1
    finalYear=thisYear-1;
else finalYear=thisYear;
end
 
if isempty(crsp.marketCap(thisPermno==crsp.PERMNO&crsp.year==finalYear&...
        crsp.month==finalMonth))
    z=NaN;
else z=crsp.marketCap(thisPermno==crsp.PERMNO&crsp.year==finalYear&...
        crsp.month==finalMonth);
end
end

