getReturns <- function(trade_data,from,to,by=1){
    source("filterByInterval.R")
    
    require(anytime)
    require(zoo)
    require(dplyr)
    require(plyr)
    
    returns <- filterByInterval(trade_data,from,to,by)
    
    returns <- returns %>% 
      mutate(Return=returns$Price/lag(returns$Price) -1) %>% 
      mutate(Vol_Change=c(NA, diff(Diff_Volume))/c(NA, diff(Acc_Volume)))
    
    returns
}