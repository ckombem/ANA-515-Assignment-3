#Verifying directory
getwd()

#set new working directory.

# Installing necessary packages on R studio
install.packages("tidyverse")
install.packages("dplyr")
install.packages("stringr")
install.packages("lubridate")
install.packages("ggplot2")


#Loading the core packages
library(tidyverse)
library(dplyr)
library(stringr)
library(lubridate)
library(ggplot2)
library(readr)


#Downloading the bulk storm details data for the year you were born, in the file that starts"StormEvents_details" and includes "dXXXX". 
#Pulling file from my Github account.

download.file(url = "https://raw.githubusercontent.com/ckombem/ANA-515-Assignment-3/main/StormEvents_details-ftp_v1.0_d1987_c20160223.csv" , destfile = "StormEvents_details-ftp_v1.0_d1987_c20160223.csv")
stormevents<-read.csv("StormEvents_details-ftp_v1.0_d1987_c20160223.csv", stringsAsFactors =FALSE)
  
head(stormevents, 6)


# select variables from within 51 variables
df1 <- stormevents[c(1,2,3,4,5,6,7,8,9,10,13,14,15,16,27,45,47,48)]


# Convert the beginning and ending dates to a "date-time" class (there should be one column for the beginning date-time and one for the ending date-time)
df2 <- mutate(stormevents, BEGIN_DATE_TIME = dmy_hms(BEGIN_DATE_TIME), END_DATE_TIME = dmy_hms(END_DATE_TIME))

 
#To change the state and county names to title case. 

str_to_title("df2$STATE")
str_to_title("df2$CZ_NAME")

rename_all(df2, STATE)
rename_all(df2, CZ_NAME)

# Limit to the events listed by county FIPS (CZ_TYPE of "C") and then remove the CZ_TYPE column.

df3 <- filter(stormevents,CZ_TYPE == "C")

colnames(df3)

df4 = subset(df3, select = -c(CZ_TYPE))
colnames(df4)

# Pad the state and county FIPS with a "0" at the beginning and then unite the two columns to make one fips column with the5-digit county FIPS code.

str_pad(df4$STATE_FIPS, width =3, side = "left", pad = "0")
str_pad(df4$CZ_FIPS, width =3, side = "left", pad = "0")


fips <- unite_(df4, "STATE_FIPS_CZ_FIPS", c("STATE_FIPS","CZ_FIPS"))


# Change all the column names to lower case (you may want to try the rename_all function for this)

df5 <-rename_all(df4, tolower)


# There is data that comes with R on U.S. states (data("state")). Use that to create a dataframe with the state name, area, and region

data("state")

us_state_info<-data.frame(state=state.name, region=state.region, area=state.area)

# Create a dataframe with the number of events per state in the year of your birth.

newset<- data.frame(table(stormevents$STATE))
head(newset)

# Merge in the state information dataframe you just created. Remove any states that are not in the state information dataframe.
## First we need to update the "us_state_info" data State column to capital to match "stormevents" data.

us_state_info2 <-(mutate_all(us_state_info,toupper))

## secondly. Name column in "newset" data set.
newset1<-rename(newset, c("state"="Var1"))

## Finally merging ....

merged <-merge(x=newset1, y=us_state_info2,by.x="state", by.y="state")

# Create the following plot

ggplot(data = merged, 
      mapping = aes(x = area,
                    y = Freq)) +
  geom_point(aes(color = region)) +
  labs (x = "Land Area (square miles)",
        y = "# of storm events in 2017")








