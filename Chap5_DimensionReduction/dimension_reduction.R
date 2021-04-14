##加载程序包
library(dplyr)
library(ggplot2)

# ---------读入数据---------
setwd("D:/lagua/CODING/R-learn/R-code/Chap5_DimensionReduction")
street <- read.csv("LANeighborhoods.csv", header=T, skip=1)
colnames(street)
# 去除掉第一列，因为后面需要计算相关系数矩阵
street = street[, -1]
summary(street)


# ---------主成分分析---------
help("princomp")
streetout <- princomp(street,cor = T,scores = T)
summary(streetout,loadings=T)

streetout <- princomp(scale(street),cor = T,scores = T)
#streetout$scores记录了每个观测的主成分得分。
streetout$scores
##显示分析结果
summary(streetout,loadings=T)

##画崖底碎石图
screeplot(streetout,type = "lines")

##画前两个主成分的双标图
biplot(streetout,choices = 1:2,col="black")
help(biplot)


# ---------因子分析---------
# help("factanal")
# 使用极大似然估计，
# 因子旋转：方差最大
streetout <- factanal(scale(street),fm="ml",factors = 8,rotation = "varimax")
streetout # 查看结果
# 画碎石图，查看方差变化情况，以便选择因子个数
plot(c(3.037,   2.183,   1.311,   1.265,   1.099,   1.082,   1.081,   0.188),
     type="o",
     xlab="factor",
     ylab="Variance")

# 选择因子个数为7
streetout <- factanal(scale(street),fm="ml",factors = 4,rotation = "varimax")
streetout
plot(c(3.037,   2.183,   1.311,   1.265),
     type="o",
     xlab="factor",
     ylab="Variance")


# 显示分析结果
streetout
#streetout数据集包含两个公共因子的载荷矩阵Loadings,
summary(streetout)


# ---------多维标度分析---------
tmpstreet <- t(scale(street))
help(dist)
# 求出距离矩阵， 使用L_1范数--曼哈顿距离
diststreet <- dist(tmpstreet,method = "manhattan") 


# ---------度量形式
# help("cmdscale")
out <- cmdscale(diststreet) %>% as.data.frame()
#使用cmdscale函数进行多维标度分析。

ggplot(out,aes(x=V1,y=V2))+
  geom_point()+
  geom_text(aes(y=V2+5,label=row.names(out)))

# ---------非度量形式
library(MASS)
D = as.matrix(diststreet) # 转化为矩阵形式
help("isoMDS")
MDS = isoMDS(D, k=2) # 非度量形式的多维标度分析
# MDS
MDS$stress # 查看应力值
x = MDS$points[, 1]
y = MDS$points[, 2]
# 对代表高维空间数据的低维空间数据画图
ggplot(out,aes(x=x,y=y))+
  geom_point()+
  geom_text(aes(y=y+5,label=row.names(D)))


# 查看其他更低维度的应力值
for (i in 3:9){
  MDS = isoMDS(D, k=i) # 非度量形式的多维标度分析
  # MDS
  print(MDS$stress) # 查看应力值
}

