filterByInterval <- function(trade_data,from,to,by=1){
    require(anytime)
    require(zoo)
    require(dplyr)
    require(plyr)
    
    
    time_series<- data.frame(Time=seq(anytime(from, tz = "UTC", asUTC=TRUE),anytime(to, tz = "UTC", asUTC=TRUE),by=3600*by)) 
    filtered <- trade_data[0,]
    filtered[1:nrow(time_series),] <- matrix(NA,ncol=ncol(trade_data),nrow=nrow(time_series))
    filtered$Time <- time_series$Time
    
    filtered <- rbind(trade_data,filtered) %>% arrange(Time)
    
    filtered <- colwise(na.locf)(filtered) %>% merge(time_series,by="Time")
    
    filtered[!duplicated(filtered$Time),]
}