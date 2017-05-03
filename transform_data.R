require(anytime)
require(dplyr)

working_dir <- "C:/Users/DE-98128/Privat/tradedata-master/"

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
  select(-Sell_Volume,-Buy_Volume)

write.csv(paste0(working_dir,"XETHZEUR_transformed.csv"))
