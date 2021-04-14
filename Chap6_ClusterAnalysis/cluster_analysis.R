# -----------1、获取数据并标准化
iris.4 = iris[, 1:4]
iris.4 = scale(iris.4, center=T, scale=T)
# -----------2、对前四列数据做聚类
##k均值聚类
K <- 4
cluster.iris <- kmeans(iris.4,centers = K,iter.max = 99,nstart=25)
cluster.iris$size
# -----------3、画图
plot(iris.4, col=cluster.iris$cluster)
plot_data = function(data, k=4){
  # 找到前四列的数据
  # 我希望来画图
  # 将聚的类添加到最后一列
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
plot_data(iris.4)

# -----------4、找到最优刻度
N <- dim(iris.4)[1]
pseudo_li = seq(2, 8, 1)
i = 1
for (k in 2:8){
  clustercars <- kmeans(iris.4,centers = k,iter.max = 99,nstart=25)
  pseudo = (clustercars$betweenss / (k - 1)) / (clustercars$tot.withinss / (N - k))
  pseudo_li[i] = pseudo
  print(paste(k, ": ", pseudo))
  i = i + 1
}

plot(seq(2, 8, 1), pseudo_li)



# -----------5、多维标度分析，清晰可视化
library(ggplot2)
# 1、对原始维度的变量进行k-means聚类
# 2、对聚类之后的数据，通过多维标度分析转化为2维
# 3、对2维数据画图，颜色为第几类变量
cluster.data <- kmeans(iris.4, centers = 3, iter.max = 99,nstart=25)
color = cluster.data$cluster
m.data = as.matrix(data[, 1:4])
dis.data = dist(m.data)
MD = cmdscale(dis.data, k=2)
p <- ggplot(data=as.data.frame(MD), mapping=aes(x=MD[, 1], y=MD[, 2]))
d <- p + geom_point(aes(colour=color)) + ggtitle(label="2-D points after Multidimensional scaling analysis") + scale_color_gradientn(colours =rainbow(4))
d

# ---------6、层次聚类法。
help("hclust")
tree <- hclust(dist(iris.4),method = "average")
# method="average"指定使用平均连接法。

# 画聚类树图。
plot(tree)

# 类别数为2时所得的聚类结果。
out <- cutree(tree,k = 2)
out
table(out)    # 查看多少类

# -----------7、多维标度分析，查看层次聚类之后的结果
library(ggplot2)
m.data = as.matrix(iris.4)
dis.data = dist(m.data)
MD = cmdscale(dis.data, k=2)
color = out
p <- ggplot(data=as.data.frame(MD), mapping=aes(x=MD[, 1], y=MD[, 2]))
d <- p + geom_point(aes(colour=color)) + ggtitle(label="2-D points after Multidimensional scaling analysis")+ scale_color_gradientn(colours =rainbow(4))
d




# -----------使用NbClust函数进行聚类，实际是找最优类别数K
library(NbClust)
#加载程序包NbClust，其中含有NbClust函数。
help(NbClust)
nbcluster <- NbClust(iris.4,method = "average")
# "average"，表示使用平均连接的层次聚类法），将数据进行聚类。
# 查看nbcluster包含的分析结果项
names(nbcluster)
# 查看综合各个指标所得的最佳类别数下，各个观测所属的类别
nbcluster$Best.partition

















# 作废
multi_scale_plot <- function(data, k=3){
  cluster.data <- kmeans(data,centers = k, iter.max = 99,nstart=25)
  data[["cluster"]] = cluster.data$cluster
  m.data = as.matrix(data[, 1:4])
  dis.data = dist(m.data)
  MD = cmdscale(dis.data, k=2)
  # p <- ggplot(data=as.data.frame(MD), mapping=aes(x=MD[, 1], y=MD[, 2]))
  # d <- p + geom_point(aes(colour=data$cluster))
  ggplot(data=as.data.frame(MD), mapping=aes(x=MD[, 1], y=MD[, 2])) + geom_point(aes(colour=data$cluster))
  # qplot(MD[, 1], MD[, 2], data = as.data.frame(MD), colour = data$cluster)
  # plot(MD[, 1], MD[, 2])
  # plot(MD, col=data$cluster,
  #      main="2-D points after Multidimensional scaling analysis")
  # return(data)
}

iris.cluster = multi_scale_plot(iris.4)


# 找到最优的k
help("kmeans")
for (k in 2:8){
  clustercars <- kmeans(iris.4,centers = k,iter.max = 99,nstart=25)
  pseudo = (clustercars$betweenss / (k - 1)) / (clustercars$tot.withinss / (N - k))
  print(pseudo)
  
}