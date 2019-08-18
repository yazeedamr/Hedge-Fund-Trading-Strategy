%% getMomentum.m = getMomentum function
% this function calculates momentum for each stock in crsp. It does so by
% matching the exact year, month, and PERMNO of each stock in order to
% carry out the calulation of momentum.
 
% Momentum = Price (1 month ago)/Price (12 months ago)
% If the required data is not found, then the function returns NaN.
 
function y=getMomentum(thisPermno,thisYear,thisMonth,crsp)
% Define 'start' Variables
startYear= thisYear-1;
startMonth= thisMonth;
startPrice=crsp.adjustedPrice(crsp.year==startYear&crsp.month==startMonth&...
    crsp.PERMNO==thisPermno);
% Define 'end' Variables
if thisMonth==1;
    endMonth=12;
else endMonth=thisMonth-1;
end
if thisMonth==1;
    endYear=thisYear-1;
else endYear=thisYear
end
endPrice=crsp.adjustedPrice(crsp.year==endYear&crsp.month==endMonth&...
    crsp.PERMNO==thisPermno);
% NaN for empty cells, else Calculate momentum as endPrice/startPrice
if isempty(startPrice|endPrice);
    y=NaN
else y=endPrice/startPrice
end
end

