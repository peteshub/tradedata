prepareData <- function(path){
    trade_data <- read.csv(path,header = FALSE)
    names(trade_data) <- c("Price","Volume","Timestamp","Buy_Sell","Market_Limit","X")
    
    trade_data <- trade_data %>% 
        filter(Price!=0) %>% 
        mutate(Time = anytime(Timestamp, tz="UTC", asUTC=TRUE)) %>% 
        select(Time,Price,Volume,Buy_Sell,Market_Limit) %>% 
        mutate(Sell_Volume=if_else(Buy_Sell=='s',Volume,0)) %>% 
        mutate(Buy_Volume=if_else(Buy_Sell=='b',Volume,0)) %>%
        mutate(Acc_Volume=cumsum(Volume)) %>% 
        mutate(Acc_Sell_Volume=cumsum(Sell_Volume)) %>%
        mutate(Acc_Buy_Volume=cumsum(Buy_Volume)) %>%
        select(-Sell_Volume,-Buy_Volume)
    
    trade_data <- trade_data %>% 
        mutate(Diff_Volume=Acc_Buy_Volume-Acc_Sell_Volume)
    
    trade_data
}