require(anytime)
require(dplyr)

working_dir <- "/home/peter/PycharmProjects/mefirstproject/"

trade_data <- read.csv(paste0(working_dir,"XETHZEUR.csv"),header = FALSE)
names(trade_data) <- c("Price","Volume","Timestamp","Buy_Sell","Market_Limit","X")

trade_data <- trade_data %>% select(-X) %>% filter(Price!=0) %>% 
  mutate(Time = anytime(Timestamp)) %>% arrange(Time)

trade_data <- trade_data %>% mutate(Sell_Volume=if_else(Buy_Sell=='s',Volume,0))
trade_data <- trade_data %>% mutate(Buy_Volume=if_else(Buy_Sell=='b',Volume,0))

trade_data <- trade_data %>% mutate(Acc_Volume=cumsum(Volume)) %>% 
  mutate(Acc_Sell_Volume=cumsum(Sell_Volume)) %>%
  mutate(Acc_Buy_Volume=cumsum(Buy_Volume)) %>%
  mutate(Diff_Volume=Acc_Buy_Volume-Acc_Sell_Volume) %>%
  select(-Sell_Volume,-Buy_Volume,-Timestamp)

trade_data$Price_sm <- rollmean(trade_data$Price,k = 200,fill = c(trade_data$Price[1],1,trade_data$Price[length(trade_data$Price)]))

trade_data$Diff_Volume_sm <- rollmean(trade_data$Diff_Volume,k = 200,fill = c(trade_data$Diff_Volume[1],1,trade_data$Diff_Volume[length(trade_data$Diff_Volume)]))


write.csv(trade_data,paste0(working_dir,"XETHZEUR_transformed.csv"),row.names = FALSE)

qplot(data=trade_data[300000:340000,],Time,Price,geom="line") + geom_line(aes(Time,Diff_Volume/5e+4+10),col="red")



smoothed_price <- apply(trade_data,1,function(x){ mn <- mean(trade_data[trade_data$Time<=x[5] & trade_data$Time>=x[5]-300,1]); ifelse(is.na(mn),x[1],mn)})


smoothed_price <- apply(trade_data[300000:310000,],1,function(x){ mn <- mean(trade_data[trade_data$Time<=as.POSIXlt(x[5]) & trade_data$Time>=as.POSIXlt(x[5])-3600,1]); ifelse(is.na(mn),x[1],mn)})

deriv_price <- (diff(trade_data[700000:703000,]$Price_sm,lag=1)/trade_data[700000:702999,]$Price_sm)
deriv_vol <- (diff(trade_data[700000:703000,]$Diff_Volume_sm,lag=1)/trade_data[700000:702999,]$Diff_Volume_sm)
deriv_price_sm <- rollmean(deriv_price,k = 200,fill = c(deriv_price[1],1,deriv_price[length(deriv_price)]))
deriv_vol_sm <- rollmean(deriv_vol,k = 200,fill = c(deriv_vol[1],1,deriv_vol[length(deriv_vol)]))
