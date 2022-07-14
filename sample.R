n <- 1028
maxT <- 20

pop <- runif(n*3)
pop %>% length %>% print
for(i in 1:maxT)  pop <- sample(pop,n*3,replace=T)
pop %>% hist
pop %>% unique %>% length %>% print

#	
#	1s=12f
#	1m=60s=720f
#	10m=600s=4580s
