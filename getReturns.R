getReturns <- function(trade_data,from,to,by=1){
  require(anytime)
  require(zoo)
  require(dplyr)
  require(plyr)
  
  
  time_series<- data.frame(Time=seq(anytime(from),anytime(to),by=3600*1)) 
  returns <- trade_data[0,]
  returns[1:nrow(time_series),] <- matrix(NA,ncol=8,nrow=nrow(time_series))
  returns$Time <- time_series$Time
  
  returns <- rbind(trade_data,returns) %>% arrange(Time)
  returns <- colwise(na.locf)(returns) %>% merge(time_series,by="Time")
  
  returns <- returns %>% mutate(Return=lead(returns$Price)/returns$Price -1)
  
  returns
  
  
}