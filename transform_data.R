require(anytime)
require(plyr)
require(dplyr)
require(zoo)
require(ggplot2)

setwd("C:/Users/DE-98128/Privat/tradedata-master/")

trade_data <- read.csv("XETHZEUR.csv",header = FALSE)
names(trade_data) <- c("Price","Volume","Timestamp","Buy_Sell","Market_Limit","X")

trade_data <- trade_data %>% 
  filter(Price!=0) %>% 
  mutate(Time = anytime(Timestamp)) %>% 
  select(Time,Price,Volume,Buy_Sell,Market_Limit) %>% 
  mutate(Sell_Volume=if_else(Buy_Sell=='s',Volume,0)) %>% 
  mutate(Buy_Volume=if_else(Buy_Sell=='b',Volume,0)) %>%
  mutate(Acc_Volume=cumsum(Volume)) %>% 
  mutate(Acc_Sell_Volume=cumsum(Sell_Volume)) %>%
  mutate(Acc_Buy_Volume=cumsum(Buy_Volume)) %>%
  select(-Sell_Volume,-Buy_Volume)



# set time as index
# write utility function for calculation of returns
# get XBTUSD data and ETHUSD for comparison
# 


daily_vols <- lead(comp$Acc_Volume)/comp$Acc_Volume -1


write.csv(paste0(working_dir,"XETHZEUR_transformed.csv"))



tt <- trade_data[1,]
tt[1:length(days),] <- matrix(NA,ncol=6,nrow=length(days))
tt$Time <- days
trade_data_daily <- rbind(trade_data,tt) %>% arrange(Time)
trade_data_daily <- na.locf(trade_data_daily)


trade_data <- trade_data %>% mutate(Acc_Volume=cumsum(Volume)) %>% 
  mutate(Acc_Sell_Volume=cumsum(Sell_Volume)) %>%
  mutate(Acc_Buy_Volume=cumsum(Buy_Volume)) %>%
  mutate(Diff_Volume=Acc_Buy_Volume-Acc_Sell_Volume) %>%
  select(-Sell_Volume,-Buy_Volume)