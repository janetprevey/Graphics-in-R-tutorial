
################## Code for making manuscript quality graphics in R ##################

# Install packages we will use to create graphics:

#if(!requireNamespace("devtools")) install.packages("devtools")
#devtools::install_github("dkahle/ggmap") 

install.packages('maps')
install.packages('maptools')
install.packages('ggplot2') #one of the most popular graphics packages
install.packages('ggmap') # ggmap draws maps that work seamlessly w/ ggplot2
install.packages('RColorBrewer') #some nice color palette options, website: http://colorbrewer2.org/#type=sequential&scheme=BuGn&n=3
install.packages('viridis') #other beautiful color options - website: https://cran.r-project.org/web/packages/viridis/vignettes/intro-to-viridis.html
install.packages('wesanderson') #color palettes inspired by Wes Anderson movies: http://blog.revolutionanalytics.com/2014/03/give-your-r-charts-that-wes-anderson-style.html
install.packages('colorRamps')#nice rainbow color palettes: https://cran.r-project.org/web/packages/colorRamps/colorRamps.pdf
install.packages('gridExtra') #helps to place graphs together on the same page

#### Load the packages we just installed

library(maps)
library(maptools)
library(ggplot2)
library(ggmap) 
library(RColorBrewer)
library(viridis)
library(wesanderson)
library(colorRamps)
library(gridExtra)


# First, lets make a simple world map using ggplot 
# This code grabs a layer of country borders for the world

mapWorld <- borders("world", colour="black", fill="white", size = 0.2) 

# Now we add our world map outline to a ggplot object

mp <- ggplot() +  mapWorld 

# And typing the name of our object prints our map out in 'Plots'

mp                                                            

# We can custimize the world map in a variety of ways - 'colour', 'fill', and 'size' 
# let us specify different style options, we customize x and y axis labels the same 
# as any ggplot graph

mapWorld <- borders("world", colour="gray", fill="white", size = 0.1)
mp <- ggplot() +  mapWorld + xlab("Longitude") + ylab("Latitude")     
mp

# we can use ggplot themes to change global graph settings for all ggplot graphics
# lets set a theme for all the graphs and maps in ggplot and ggmaps below to make sure 
# we have white backgrounds and larger than normal axes labels
# 'theme_bw' converts the normal grey background to white, and 'base_size=...' 
# indicates the size of labels for all graphs

theme_set(theme_bw(base_size=20))

# check out how our map looks with the new theme:

mp

# We can also zoom in to the continental USA if we want... 

mapUSA <- borders("state", colour="gray", fill="white", size = 0.1)
mp <- ggplot() +  mapUSA + xlab("Longitude") + ylab("Latitude")     
mp

# Here are some other background map and zoming options using the package 'ggmap'
# We use the 'get_map' command to grab rasters from the internet to make the background map
# Specify the bounding box of your map with:
#'location <- c(left longitude, bottom latitude, right longitude, upper latitude)

myMap <- get_stamenmap(location<- c(-132,16,-47,56), zoom = 5, maptype="terrain",
          crop=TRUE) ## smaller zoom values require fewer tiles but show less detail

# view the map you just made
ggmap(myMap)

#### you can customize the ggmaps in a multitude of ways: check out the stamen maps website: http://maps.stamen.com/#toner/12/37.7706/-122.3782 
#### and check out this link to the ggmaps cheatsheet for some other options: https://www.nceas.ucsb.edu/sites/default/files/2020-04/ggmapCheatsheet.pdf

### Watercolor map of Alaska

myMap <- get_stamenmap(location<- c(-179,51,-136,73), zoom = 5, maptype="watercolor",crop=TRUE)
ggmap(myMap)

### Black and white map

myMap <- get_stamenmap(location<- c(-132,16,-47,56), zoom = 4, maptype="toner", crop=FALSE)
ggmap(myMap)

### And all maps can be made into black-and-white maps by specifying color = "bw"

## Lets move forward with a black and white terrain map, and lets zoom in on western Washington:
## Play around with the zoom levels to get your desired level of detail

myMap <- get_stamenmap(location<- c(-126,45,-120,50), zoom = 7,
         maptype="terrain-background",color = "bw", crop=TRUE)

ggmap(myMap)


# Now lets add our data to the background map. First, set the working directory to the 
# location where the sample data ('r6_salal_data.csv') is stored

# Your directory will differ from mine! Change the code below to select the folder with
# the sample data on your computer. Or go to 'Session'-> 'Set Working Directory' -> and
# select the folder that way. 

setwd("C:/Users/jprevey/Desktop/Graphics-in-R-tutorial-master")

dat <- read.csv("r6_salal_data.csv", header = TRUE, sep = ",")

# Now we have a new data frame called 'dat' loaded into our workspace with the raw data

#Lets look at a summary of our variables 

summary(dat)

# and now we add the plot locations from the .csv of data to our map with the geom_point function

ptmap <- ggmap(myMap) + geom_point(data=dat, aes(x=long, y=lat)) 

# view our new map with points

ptmap

# So the points are small and hard to see - lets fix that.
# We can increase the size of the points ('size = ..'), and color the plots by the year 
# they were sampled to provide more information (using "fill = year" in the asthetics 
# mapping. We can also make the points slighty transparent to show overlapping locations

ptmap <- ggmap(myMap) + geom_point(data=dat, aes(x=long, y=lat, fill = year), 
         pch = 21, color = "black", stroke = 1.1, size = 4.2, alpha = 0.7) 
ptmap

# The continous blue colors are OK, but they make it hard to distinguish between years.. 
# Lets customize!

# Using colors from the viridis package

newmap <- ptmap + scale_fill_viridis()
newmap


# Using colors from the colorRamps Package:

newmap <- ptmap  +  scale_fill_gradientn(colours= (blue2green2red(23)))
newmap

# Use 'rev' to reverse the scale

newmap <- ptmap  +  scale_fill_gradientn(colours= rev(blue2green2red(23)))
newmap

# We can also change year to a discrete variable and see if that helps:
# Designate year as a factor instead of number

dat$year <-factor(dat$year)

# Try again with year as a discrete variable

ptmap <- ggmap(myMap) + geom_point(data=dat, aes(x=long, y=lat, fill = year), pch = 21, color = "black", stroke = 1.1, size = 4.2, alpha = 0.8) 
ptmap

### That looks very bad......lets customize the colors!

newmap <- ptmap + scale_fill_viridis(discrete=TRUE) 

###Now Lets add better labels:

scdmap <- newmap + labs(x="Latitude",y= "Longitude", fill = "Sample Year") 
scdmap 

# It's hard to get a clear picture of how many plots were sampled per year
# To make it more clear, we can also show a histogram using the same colors 
# that shows the number of sampled plots per year 

# Make a bar graph showing the count of plots per year by specifying that you want 
# year on the x axis (x=year)

histo <- ggplot(data=dat, aes(x=year, fill=year)) + geom_bar()
histo

# quickly change to the same color scheme as above

bhisto <- histo + scale_fill_viridis(discrete=TRUE, guide=FALSE) 
bhisto

# Add better labels, remove the background grid, and change the x axis scale 
# so the numbers are visible

chisto <- bhisto + labs(x="Year",y= "Number of plots sampled") 
          + theme(panel.grid.major=element_blank(),panel.grid.minor=element_blank())+ 
          theme(axis.text.x=element_text(angle = -65, hjust = 0))
chisto


### And now we can place our map and histogram next to each other using the gridExtra package

grid.arrange(scdmap,chisto, ncol=2)

### And now we really don't need the legend on the map, since the colors for each year are already shown in the bar graph

smap <- scdmap + scale_fill_viridis(discrete=TRUE, guide=FALSE)

## Voila ###

grid.arrange(smap,chisto, ncol=2)


##################################### Other examples #######################################################################

## Perhaps we would like to show how the % cover of Salal varies over plot locations 
## and mean summer precipitation. We can color the plots by mean summer temperature, 
## but map the size of the points to the cover variable

ptmap <- ggmap(myMap) + geom_point(data=dat, aes(x=long, y=lat, fill = MSP_av, 
         size = cover), pch = 21, color = "black", stroke = 1.1, alpha = 0.7) 
ptmap

## Still hard to distinguish colors - reds to blues are good for precipitation data

newmap <- ptmap  +  scale_fill_gradientn(colours= rev(blue2green2red(23)))
newmap

## Add correct labels 

scdmap <- newmap + labs(x="Latitude",y= "Longitude", fill = "Summer precip.\n(mm)", size = "Percent Cover") 
scdmap

## Tweak the legend positions to suit our preference
## the coordinates for legend.position are x- and y- offsets from the bottom-left 
## of the plot, ranging from 0 - 1

thrdmap <- scdmap + theme(strip.text.x = element_blank(),
               strip.background = element_rect(colour="none", fill="none"),
               legend.position=c(.19,.19))

thrdmap

## We can also remove the white background of the legends, and change the size of 
## the legend titles

frthmap <- thrdmap + theme(legend.background = element_rect(fill=NA, size=0.5)) + 
           theme(legend.title = element_text(size=15))

frthmap 

## And for the last example with this data set - let's look at how the day of year 
## when open Salal flowers were observed on a plot relates to mean summer temperature

## create a new dataframe with only plots with flower observations

flower <- dat[dat$Phenophase=='Flower', ]

ptmap <- ggmap(myMap) + geom_point(data=flower, aes(x=long, y=lat, fill = DOY), pch = 21, 
                                   color = "black", stroke = 1.1, size = 5, alpha = 0.8) 
ptmap

### Let's create a color scheme that uses lighter colors for earlier flowering observations
## "direction = - 1" reverses the order of the color palette

newmap <- ptmap  + scale_fill_viridis(option="magma",  direction = - 1)
newmap

## Add correct labels and move legend

scdmap <- newmap + labs(x="Latitude",y="Longitude", fill = "DOY Flowering") 
scdmap

thrdmap <- scdmap + theme(strip.text.x = element_blank(), strip.background = 
           element_rect(colour="none", fill="none"),
           legend.position=c(.19,.19)) 
thrdmap

fthmap <- thrdmap  + theme(legend.background = element_rect(fill=NA, size=0.5)) + 
          theme(legend.title = element_text(size=15))
fthmap

## Now lets make a scatterplot to visualize if summer temperature is related to 
## flowering date of salal

scat <- ggplot(data=flower, aes(x=summer, y=DOY)) + geom_point(data=flower, 
        aes(x=summer, y=DOY, fill = DOY), pch = 21, color = "black", stroke = 1.1, 
        size = 5.5, alpha = 0.8)
scat

scat2 <- scat  + scale_fill_viridis(option="magma",  direction = - 1, guide=FALSE)
scat2

## We can use geom_smooth to plot the linear relationship between summer temperature 
## and the DOY that flowers were observed in plots. The grey band denotes the 95% 
## confidence intervals of the linear relationship between summer temp. and DOY

scat3 <- scat2 + geom_smooth(method = "lm",color = "black") 
scat3

## We can also alter the breaks and limits for the axes... 
## Below we can change the y axis to start near the beginning of June (DOY 152) 
## and go through the end of August (DOY 243)
## we can also use the breaks argument to dsignate how often the axes are labeled 
## (every 10 units here)

scat4 <- scat3 + scale_y_continuous(breaks=seq(150,243,by=10), limits=c(152,243)) + 
         theme(legend.position="none")

scat4

## Add better labels, remove the background grid, and change the x axis scale so 
## numbers are visible

sum <- scat4 + labs(x=expression("Summer temperature "( degree*C)),
       y="DOY Flowering") + theme(panel.grid.major=element_blank(),
       panel.grid.minor=element_blank()) 
sum 

## We could also look at the relationships between other seasonal temperatures as 
## well....


#Winter - let's put the legend back in for this one

scat <- ggplot(data=flower, aes(x=winter, y=DOY)) + geom_point(data=flower, 
              aes(x=winter, y=DOY, fill = DOY), pch = 21, color = "black", 
              stroke = 1.1,size = 5.5, alpha = 0.8)
scat2 <- scat + scale_fill_viridis(option="magma",  direction = - 1)
scat3 <- scat2 + geom_smooth(method = "lm",color = "black") 
scat4 <- scat3 + scale_y_continuous(breaks=seq(150,243,by=10), limits=c(152,243))+ 
         theme(legend.position="none")
scat5 <- scat4 + labs(x=expression("Winter temperature "( degree*C)),
         y= "DOY Flowering") + theme(panel.grid.major=element_blank(),
         panel.grid.minor=element_blank()) 
winter<- scat5 + theme(strip.text.x = element_blank(),
         strip.background = element_rect(colour="none", fill="none"),
         legend.position=c(.08,.25))  + theme(legend.title = element_text(size=10)) +  
         theme(legend.text = element_text(size=10))
winter

## Spring

scat <- ggplot(data=flower, aes(x=spring, y=DOY)) + geom_point(data=flower, 
        aes(x=spring, y=DOY, fill = DOY), pch = 21, color = "black", stroke = 1.1, 
        size = 5.5, alpha = 0.8)
scat2 <- scat  + scale_fill_viridis(option="magma",  direction = - 1, guide=FALSE)
scat3 <- scat2 + geom_smooth(method = "lm",color = "black") 
scat4 <- scat3 + scale_y_continuous(breaks=seq(150,243,by=10), limits=c(152,243)) +  
        theme(legend.position="none")
sprg <- scat4 + labs(x=expression("Spring temperature "( degree*C)), 
        y= "DOY Flowering") + theme(panel.grid.major=element_blank(),
        panel.grid.minor=element_blank()) 
sprg 

## Fall

scat <- ggplot(data=flower, aes(x=fall, y=DOY)) + geom_point(data=flower, aes(x=fall, 
        y=DOY, fill = DOY), pch = 21, color = "black", stroke = 1.1, size = 5.5, 
        alpha = 0.8)
scat2 <- scat  + scale_fill_viridis(option="magma",  direction = - 1, guide=FALSE)
scat3 <- scat2 + geom_smooth(method = "lm",color = "black") 
scat4 <- scat3 + scale_y_continuous(breaks=seq(150,243,by=10), limits=c(152,243)) +  
         theme(legend.position="none")
fll <- scat4 + labs(x=expression("Autumn temperature "( degree*C)),y= "DOY Flowering") + 
       theme(panel.grid.major=element_blank(),panel.grid.minor=element_blank()) 
fll



## And we can place our map and a graph together using the gridExtra package

grid.arrange(fthmap,sprg,ncol = 2)

## Or perhaps we would like to show the relationship between flowering and ALL four 
## seasons on a four panel graph....

grid.arrange(winter, sprg, sum, fll, nrow=2, ncol = 2)

########## Last Step! ###########################################################################################

## Save high resolution copies of your images, after figuring out the correct sizing 
## using the 'Export' option under 'Plots'
## 300 dpi or greater is good for publication quality graphs

## place the below line of the code before the line of code that displays the graphics you 
## would like to save 

tiff("Example.tiff", width = 12.9, height = 6.30, pointsize = 12, units = 'in', res = 300) ##this will save a .tiff file to your working directory

grid.arrange(fthmap,sprg,ncol = 2) ## then the line of code that displays the graphs

dev.off()  ## now the displayed graphics are saved to a file with the above name file

#############################################################################################################################################################################
###############################################################################################################################################################################

## A very brief introduction to visualizing raster data in R (adapted from code by Scott W. Anderson USGS)

install.packages(c("ggspatial", "prism", "raster"))

library(prism)
library(raster)
library(ggspatial)

## We can download precipitation data from PRISM at a 4km data using the prism package
## Lets look at monthly precipitation data for January 1980 and 1981
## More information about the prism package here: https://cran.r-project.org/web/packages/prism/prism.pdf 

## Tell prism where to store the rasters
options(prism.path = "C:\\Users\\jprevey\\Desktop\\Prism")

## Download January mean temperature for 1990 through 2000
get_prism_monthlys(type="tmean", years = 1990:2000, mon = 1, keepZip=FALSE)

## Show R where to get the 1990 .bil file to display as a raster 
prism1990 = "C:\\Users\\jprevey\\Desktop\\Prism\\PRISM_tmean_stable_4kmM3_199001_bil\\PRISM_tmean_stable_4kmM3_199001_bil.bil"
prism2000 = "C:\\Users\\jprevey\\Desktop\\Prism\\PRISM_tmean_stable_4kmM3_200001_bil\\PRISM_tmean_stable_4kmM3_200001_bil.bil"

# Read in 1990 data

tRas90 = raster(prism1990)
tRas90NW = crop(tRas90, extent(c(-125, -105, 30, 52)))

# Graph the raster quickly using base r graphics

plot(tRas90NW)

# Graph the data in ggplot, adding a north arrow

ggplot() + layer_spatial(tRas90NW) +
  scale_fill_gradientn(colors = terrain.colors(10), name = 'Temp. (C)') +
  annotation_north_arrow() +
  labs(title = 'January 1990 temperature') 

## Now suppose you want to compare January temperatures across teh decade

tRas00 = raster(prism2000)
tRas00NW = crop(tRas00, extent(c(-125, -105, 30, 52)))

# Graph the raster quickly using base r graphics

plot(tRas00NW)

# Use basic r commands to get the difference in monthley mean temperatures between 2000 and 1990

tRasdiff <- tRas00NW - tRas90NW

# Graph the data in ggplot, adding a north arrow

ggplot() + layer_spatial(tRasdiff) +
  scale_fill_gradientn(colors = terrain.colors(10), name = 'Temp. diff. (C)') +
  annotation_north_arrow() +
  labs(title = 'Difference in mean temp. between \nJanuary 1990 and 2000')

## Now you can continue to adjust axes labels, colors, etc., using what you learned 
## in the above examples!

