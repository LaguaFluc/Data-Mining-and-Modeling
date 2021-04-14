air_data = read.csv("D:/lagua/CODING/R-learn/R-code/Chap6_ClusterAnalysis/air_data.csv",
                    header=TRUE,quote = "",
                    sep=",",
                    encoding='UTF-8',
                    strip.white = TRUE
                    )
help(read.csv)
colnames(air_data)
col_need = c('LOAD_TIME', 'FFP_DATE','LAST_TO_END', 'FLIGHT_COUNT', 'SEG_KM_SUM', 'avg_discount')

air_data = subset(air_data, select=col_need)
air_data$LOAD_TIME = as.Date(air_data$LOAD_TIME)
air_data$FFP_DATE = as.Date(air_data$FFP_DATE)
str(air_data)
# air_data = scale(air_data, center=T, scale=T)

library(dplyr)
# 1����ʼ������
# 2��������
# 3��ɾ����
# 4��������
# 5��������
new_air = air_data
new_air$L = (new_air$LOAD_TIME - new_air$FFP_DATE) %>% as.integer()
new_air = new_air[,-which(names(new_air) %in% c('LOAD_TIME', 'FFP_DATE'))]
new_air = rename(new_air, c("R"='LAST_TO_END', "F"='FLIGHT_COUNT', "M"='SEG_KM_SUM', 'C'='avg_discount'))
new_air %>% select("L", 'R', 'F', 'M', 'C')
new_air = new_air[, c(2, 3,)]
colnames(new_air)

L = LOAD_DATE - FFP_DATE
R = LAST_TO_END
F = FLIGHT_COUNT
M = SEG_KM_SUM
C = AVG_DISCOUNT
L = LOAD_TIME - FFP_DATE
str(air_data)
air_data$LOAD_TIME

# 对前四列数据做聚�?
##k均值聚�?
K <- 4
cluster.iris <- kmeans(air_data,centers = K,iter.max = 99,nstart=25)
cluster.iris$size
#使用kmeans函数对数据集air_data进行k均值聚类：
#  centers=5表示聚为5个类别；
#  iter.max=99表示算法最多循�?99次；
#  nstart=25表示进行25次随机初始化，取目标函数值最小的聚类结果�?

##查看cluster.iris包含的分析结果项
# names(cluster.iris)
# cluster.iris$cluster
# cluster.iris$centers
# cluster.iris$totss
# 
# cluster.iris$tot.withins
# cluster.iris$betweenss
# cluster.iris$size
#cluster.iris$cluster记录了各个观测所属的类别�?
#cluster.iris$centers记录了各个类别的中心�?
#cluster.iris$totss记录了总平方和SST�?
#cluster.iris$tot.withinss记录了组内平方和SSW�?
#cluster.iris$betweenss记录了组间平方和SST-SSW�?
#cluster.iris$size记录了各个类别的观测数�?
plot(air_data, col=cluster.iris$cluster)



data = air_data



plot_data = function(data, k=4){
  # 找到前四列的数据
  # 我希望来画图
  # 将聚的类添加到最后一�?
  cluster.data <- kmeans(data,centers = 5,iter.max = 99,nstart=25)
  print(length(cluster.data$cluster))
  sepal = data[, 1:2]
  petal = data[, 3:4]
  color = cluster.data$cluster
  plot(sepal, xlab=colnames(sepal)[1], ylab=colnames(sepal)[2], 
       main=paste("Scatter of " , colnames(sepal)[1], "and", colnames(sepal)[2]),
       col=color)
  plot(petal, xlab=colnames(petal)[1], ylab=colnames(petal)[2], 
       main=paste("Scatter of " , colnames(petal)[1] , "and", colnames(petal)[2]),
       col=color)
  return(data)
  
} 

plot_data(air_data)

# 找到最优刻�?
N <- dim(air_data)[1]
pseudo_li = seq(2, 8, 1)
i = 1
for (k in 2:8){
  clustercars <- kmeans(air_data,centers = k,iter.max = 99,nstart=25)
  pseudo = (clustercars$betweenss / (k - 1)) / (clustercars$tot.withinss / (N - k))
  pseudo_li[i] = pseudo
  print(paste(k, ": ", pseudo))
  i = i + 1
}

plot(seq(2, 8, 1), pseudo_li)



# 多维标度分析
help("cmdscale")
help(dist)
library(ggplot2)
# 1、对原始维度的变量进行k-means聚类
# 2、对聚类之后的数据，通过多维标度分析转化�?2�?
# 3、对2维数据画图，颜色为第几类变量
cluster.data <- kmeans(air_data, centers = 3, iter.max = 99,nstart=25)
color = cluster.data$cluster
m.data = as.matrix(data[, 1:4])
dis.data = dist(m.data)
MD = cmdscale(dis.data, k=2)
p <- ggplot(data=as.data.frame(MD), mapping=aes(x=MD[, 1], y=MD[, 2]))
d <- p + geom_point(aes(colour=color)) + ggtitle(label="2-D points after Multidimensional scaling analysis") + scale_color_gradientn(colours =rainbow(4))
d

# ----------层次聚类法�?
help("hclust")
tree <- hclust(dist(air_data),method = "average")
tree <- hclust(dist(air_data),method = "average")
tree <- hclust(dist(air_data),method = "average")
#使用hclust函数对数据集air_data进行层次聚类�?
#dist函数计算air_data中各个观测之间的距离的矩阵，
#  缺省使用的距离度量为欧式距离�?
#method="average"指定使用平均连接法�?

##画聚类树图�?
plot(tree)

##类别数为5时所得的聚类结果�?
out <- cutree(tree,k = 2)
out
table(out)

help("cmdscale")
help(dist)
library(ggplot2)
# 1、对原始维度的变量进行k-means聚类
# 2、对聚类之后的数据，通过多维标度分析转化�?2�?
# 3、对2维数据画图，颜色为第几类变量
m.data = as.matrix(air_data)
dis.data = dist(m.data)
MD = cmdscale(dis.data, k=2)
color = out
p <- ggplot(data=as.data.frame(MD), mapping=aes(x=MD[, 1], y=MD[, 2]))
d <- p + geom_point(aes(colour=color)) + ggtitle(label="2-D points after Multidimensional scaling analysis")+ scale_color_gradientn(colours =rainbow(4))
d

#out记录了类别数�?5时，各个观测所属的类别�?



##使用NbClust函数进行聚类�?
library(NbClust)
#加载程序包NbClust，其中含有NbClust函数�?
help(NbClust)
nbcluster <- NbClust(air_data,method = "average")
#NbClust函数根据给定的观测之间距离的度量（由distance选项指定，这里取
#  缺省�?"euclidean"，即欧式距离）和聚类方法（由method选项指定，这里取�?
#  "average"，表示使用平均连接的层次聚类法），将数据进行聚类�?
#  接着，它根据多个判断最佳类别数的指标，进行综合分析，给出最终的最佳类别数�?
#屏幕上将显示一个摘要性的结果，另外Plots框中将显示某些指标和类别数的散点图�?

##查看nbcluster包含的分析结果项
names(nbcluster)
#nbcluster$All.index记录了各个指标在各类别数下的值；
#nbcluster$Best.nc记录了各个指标给出的最佳类别数以及
#  在该类别数下对应的指标值；
#nbcluster$Best.partition记录了综合各个指标所得的最佳类别数下，
#  各个观测所属的类别�?

##查看综合各个指标所得的最佳类别数下，各个观测所属的类别
nbcluster$Best.partition