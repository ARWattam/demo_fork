library(stringr)
library(lubridate)
library(pander)
library(dplyr)
library(tidyr)

#source ("reports/CMS_prep.R")

#CMS <- read.csv("data/CMS_8_26.txt")
#FIPS_Codes <- read.csv("/data/FIPS_R.csv")

# # Remove Extraneous columns from CMS table
# CMS <- CMS[,!names(CMS) %in% c("Notes","Received","ErrorType","FilingDate","CorrectionDate")]
# 
# #Remove extra white space from around some values
# CMS$HEAR.RSLT <- str_trim(CMS$HEAR.RSLT)
# CMS$CASE.TYP <- str_trim(CMS$CASE.TYP)
# CMS$MOT <- str_trim(CMS$MOT)
# 
# #Create Month and Year columns
# CMS$HEAR.DATE <- as.Date(CMS$HEAR.DATE, format = '%m/%d/%Y')
# CMS$Year<- year(CMS$HEAR.DATE)
# CMS$Month <- month(CMS$HEAR.DATE)
# 
# #Filter for no errors (keep or no?)
# CMS<- filter(CMS, Error< 1|is.na(Error))
# 
# # Create Fiscal Year Variable
# CMS$FYear<- CMS$Year
# CMS[CMS$Month > 6, ]$FYear <- as.numeric(CMS[CMS$Month > 6, ]$Year) + 1
# 
# #Create Fiscal Quarter Variable
# CMS$FQtr <- CMS$Month
# CMS[CMS$Month == 7|CMS$Month==8| CMS$Month==9, ]$FQtr <- 1
# CMS[CMS$Month == 10|CMS$Month==11| CMS$Month==12, ]$FQtr <- 2
# CMS[CMS$Month == 1|CMS$Month==2| CMS$Month==3, ]$FQtr <- 3
# CMS[CMS$Month == 4|CMS$Month==5| CMS$Month==6, ]$FQtr <- 4
# 
# # Create abbreviated month column, factored in accordance with fiscal calendar
# CMS$FYMonthAbbrev <- factor(substr(month.name[CMS$Month],1,3),levels=substr(c(month.name[7:12],month.name[1:6]),1,3))
# 
# # Create a uniq identifier for the month (may or may not be needed)
# CMS$month_id <- factor(paste(CMS$FYear, str_pad(as.character(CMS$Month), 2, side="left", pad="0"), sep="-"))
# 
# #Create FIPs column
# CMS$FIPS <- substr(CMS$CASE.NUMBER, 1, 4)
# 
# #Include FIPS names
# CMS <- merge(CMS, FIPS_Codes, by = c("FIPS"), all.x = TRUE)
# CMS <- CMS[,!names(CMS) %in% c("SHORT_FIPS","COURT")]
# names(CMS)[names(CMS)=="NAME"] <- "Locality"
# 
# #Use Pay Code to determine if Initial
# CMS$initial <- ifelse (CMS$PAY.CD == 41 | CMS$PAY.CD == 46, FALSE, TRUE)
# CMS$initial [is.na(CMS$PAY.CD)] <- TRUE

########### HERE'S THE MEAT #########
# Create table of the counts of 4 Different MOT Types for all localities
CMS_MOT_Type_Annual <- filter(CMS, CASE.TYP =="MC", HEAR.RSLT %in% c("MO", "I"))%>%
    mutate(MOT_TYPE=ifelse((HEAR.RSLT=="I" & MOT=="Y" & !initial), "Discharge Recommit", NA)) %>%
  mutate(MOT_TYPE=ifelse((HEAR.RSLT=="I" & MOT=="Y" & initial), "Discharge Initial", MOT_TYPE)) %>%
  mutate(MOT_TYPE=ifelse((HEAR.RSLT=="MO"  & initial), "Direct", MOT_TYPE)) %>%
  mutate(MOT_TYPE=ifelse((HEAR.RSLT=="MO"  & !initial), "New Hearing", MOT_TYPE)) %>%
  mutate(MOT_TYPE=factor(MOT_TYPE)) %>%
  #   group_by(Locality,HEAR.RSLT, MOT, initial)%>%
  group_by(FYear, MOT_TYPE)%>%
  #   filter((HEAR.RSLT == "I" & (MOT == "Y") ) | HEAR.RSLT == "MO" ) %>%
  summarise(count = n()) 



MOT_Type_Annual_Plot <- 
  ggplot(CMS_MOT_Type_Annual, aes(factor(FYear), count, group=factor(MOT_TYPE), color=factor(MOT_TYPE))) + 
  geom_line() +
  ylab("Number of Orders for MOT") +
  xlab("Fiscal Year")

MOT_Type_Annual_Plot + ylim(0,250) + geom_line(size=1.2) + geom_point(aes(shape=factor(MOT_TYPE)), size=3) + scale_colour_discrete(name  ="MOT Type") + scale_shape_discrete(name="MOT Type") + ggtitle("Annual MOT Trends by Type, FY09-FY15")
  