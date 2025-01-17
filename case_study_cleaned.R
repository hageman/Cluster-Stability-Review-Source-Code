rm(list=ls())
set.seed(1234)

data("iris")
x0 <- iris[,1:4] # take out the category column

# Take the category as reference labels
label_0 <- as.factor(iris[,5])
# Change the category of iris into 1,2,3's
label_ref = sapply(as.character(label_0),switch,
       "setosa" = 1,
       "versicolor" = 2,
       "virginica" = 3,
       USE.NAMES = F)

# Perform a PCA for visualization
iris_pca <- prcomp(scale(x0))
scores <- iris_pca$x


##########################################
# Bagclust
#########################################

# The Bagclust method package, the link is followed
# https://cran.r-project.org/web/packages/clue/index.html
library(clue)
nk = 3

# This is the call function for Bagclust1
party <- cl_bag(x0,50,nk)

# Plotting the clustering membership of Bagclust
# Here the cl_class_ids() function determins the cluster label by the max of each row in "party"
plot(scores[,1:2],col = cl_class_ids(party), xlab = "PC1", ylab = "PC2",main = "BagClust")

# Plotting the real labels for comparison
plot(scores[,1:2],col = label_ref,main = "Real")

# A metric that is similar to observation level stability
bagclust_stab = apply(party$.Data, 1, max)
bagclust_stab


###################################
# clusterboot by Hennig
###################################
library(fpc)
# The fpc contains Hennig's cluster-wise similarity, Fang's clustering instability, and Tibshirani's prediction strength
# The link for fpc: 
# https://cran.r-project.org/web/packages/fpc/index.html

  hennig = clusterboot(x0,clustermethod=kmeansCBI,krange = 3)
  
  # This is the clustering membership
  hennig$partition
  
  # This is the cluster-wise stability
  hennig$bootmean

  # Plotting the cluster membership for clusterboot results
  plot(scores[,1:2],col = hennig$partition, xlab = "PC1", ylab = "PC2",main = "Hennig")
  
  # Plotting the real labels
  plot(scores[,1:2],col = label_ref,main = "Real")
  



######################
# Fang
#######################

# The fpc contains Fang's clustering instability, Hennig's cluster-wise similarity, and Tibshirani's prediction strength
# The link for fpc: 
# https://cran.r-project.org/web/packages/fpc/index.html

# Fang's method only provides nselect functions
fang = nselectboot(x0,B=50,clustermethod=kmeansCBI,
            classification="centroid",krange=2:10)

# This is the optimal k
fang$kopt

# This is the overal stability for each k
fang$stabk

#########################
# Han
###########################

library(bootcluster)

# The package page is followed:
# https://cran.r-project.org/web/packages/bootcluster/index.html

han = stability(x0,k=3,B = 50)

# This is the observation-level stability
han$obs_wise

# This is the overall-level stability
han$overall

# Plotting the bootcluster results
plot(scores[,1:2],col = han$membership, xlab = "PC1", ylab = "PC2",main = "Han")

# Plotting the real results
plot(scores[,1:2],col = label_ref,main = "Real")


###########################
# Clest by Dudoit
###########################
# This is the package containing Clest()
# The following is the package page:
# https://cran.r-project.org/web/packages/RSKC/index.html

library(RSKC)
# The following is the clest function
dudoit<-Clest(data.matrix(data.frame(x0)),10,B=50,alpha = 0,B0=10, beta = 0.05,nstart=100,pca=TRUE,silent=TRUE)

# The results are collected as a table
dudoit$result.table

# This is the optimal k, it is the k where the p-value is smallest in the table above
dudoit$K


#################################
# Prediction strength
#################################
# Prediction strength is contained in fpc as well.
# The page for fpc:
# https://cran.r-project.org/web/packages/fpc/index.html

# This is the prediction strength call function
tib <- prediction.strength(x0, Gmin=2, Gmax=10, M=50,
                           clustermethod=kmeansCBI,
                           classification="centroid", centroidname = NULL,
                           cutoff=0.8)

# This is the prediction strength for each k
tib$mean.pred

# This is the optimal k
tib$optimalk

  
################################
# OT by Jia Li
##############################
# This is a particularly difficult one to read
# The package page:
# https://cran.r-project.org/web/packages/OTclust/index.html
library(OTclust)

# do a PCA for visualization
pc_fit <- prcomp(scale(iris[,1:4]))

# This is the first 2 principal components
pc12 <- pc_fit$x[,1:2]

# Mark them as x1 and x2
x1=pc12[,1]
x2=pc12[,2]

# This is the call function for OT bootstrap clustering
OT_k = clustCPS(as.matrix(iris[,1:4]), k=3, l=FALSE, pre=FALSE, noi="after", vis=cbind(x1,x2), nPCA = 2, nEXP = 50)

# This is the overall stability
OT_k$tight_all

# This is the cluster-wise stability
OT_k$tight

# CPS analysis on selection of visualization methods
c=visCPS(OT_k$vis, OT_k$ref)

# visualization of the results
library(geneplotter)

# This is the heat map for cluster #1
quartz()
mplot(c,1)
# This is the heat map for cluster #2
quartz()
mplot(c,2)
# This is the heat map for cluster #3
qartz()
mplot(c,3)

# One can also generate the covering point set plot for each cluster using the following commands
# This is the covering point set plot for cluster #1
qartz()
cplot(c,1)
# This is the covering point set plot for cluster #2
qartz()
cplot(c,2)
# This is the covering point set plot for cluster #3
qartz()
cplot(c,3)


