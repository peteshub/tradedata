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




alg = "right"
wdw <- 200
from_to = 1000000:1150000

trade_data$Price_sm <- rollmean(trade_data$Price,k = wdw,fill = c(trade_data$Price[1],1,trade_data$Price[length(trade_data$Price)]), align = alg)

trade_data$Diff_Volume_sm <- rollmean(trade_data$Diff_Volume,k = wdw,fill = c(trade_data$Diff_Volume[1],1,trade_data$Diff_Volume[length(trade_data$Diff_Volume)]), align = alg)

trade_data$deriv_price <- (c(0,diff(trade_data$Price_sm,lag=1))/trade_data$Price_sm)
trade_data$deriv_vol <- (c(diff(trade_data$Diff_Volume_sm,lag=1),0)/trade_data$Diff_Volume_sm)
trade_data$deriv_price_sm <- rollmean(trade_data$deriv_price,k = wdw,fill = c(trade_data$deriv_price[1],1,trade_data$deriv_price[length(trade_data$deriv_price)]), align = alg)
trade_data$deriv_vol_sm <- rollmean(trade_data$deriv_vol,k = wdw/2,fill = c(trade_data$deriv_vol[1],1,trade_data$deriv_vol[length(trade_data$deriv_vol)]) , align = alg)


plot(trade_data$Time[from_to],trade_data$Price[from_to]/trade_data$Price[from_to[1]],type="l")



plot(trade_data$Time[from_to],(trade_data$Diff_Volume[from_to]+trade_data$Acc_Volume[from_to[1]])/(trade_data$Diff_Volume[from_to[1]]+trade_data$Acc_Volume[from_to[1]]),type="l")

par(mfrow=c(3,1))

plot(trade_data$Time[from_to],trade_data$Price[from_to],pch=19,col=as.numeric(trade_data$deriv_vol_sm[from_to]<0)+2)

plot(trade_data$Time[from_to],trade_data$Diff_Volume_sm[from_to],pch=19,col=as.numeric(trade_data$deriv_vol_sm[from_to]<0)+2)

plot(trade_data$Time[from_to],-trade_data$deriv_vol_sm[from_to],pch=19,col=as.numeric(trade_data$deriv_vol_sm[from_to]<0)+2)

#write.csv(trade_data,paste0(working_dir,"XETHZEUR_transformed.csv"),row.names = FALSE)

qplot(data=trade_data[600000:340000,],Time,Price,geom="line") + geom_line(aes(Time,Diff_Volume/5e+4+10),col="red")



smoothed_price <- apply(trade_data,1,function(x){ mn <- mean(trade_data[trade_data$Time<=x[5] & trade_data$Time>=x[5]-300,1]); ifelse(is.na(mn),x[1],mn)})
