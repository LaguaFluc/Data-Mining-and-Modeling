# 导入包
library(mice)   
library(VIM)                                      
library(dplyr)
library(xlsx)
# ----------读取数据----------
setwd("D:/lagua/CODING/R-learn/R-code/Chap5_model")
data<-read.xlsx("./missing_data.xls", 1, 
                header=0,
                colClasses=rep("numeric",4))


# ----------查看数据, 并且查看数据缺失模式
data
summary(data)
md.pattern(data)
aggr(data,prop=T,numbers=T,col=c('blue','red'))  


# ----------准备使用mice进行插值
m <- 5
mi_data <- mice(data,m, seed=1)  
# 获取数据初始观察填补的数据
mi_data$imp
mi_data$imp$X1

# 查看数据之间的相关性
cor(data[complete.cases(data)==T,])

# ----------plot----------
# 画每个变量的折线分布图
library(tidyverse)
library(ggplot2)


x = seq(1, 21, 1)     # 自变量，变量个数
X1 = data[, 1]        # 一变量X1
X2 = data[, 2]
X3 = data[, 3]
ggplot(data=data)+
  geom_line(mapping=aes(x=x,y=X),data=data,show.legend=TRUE,color="red")+
  geom_line(mapping=aes(x=x,y=X2),data=data,show.legend=TRUE,color="blue")+
  geom_line(mapping=aes(x=x, y=X3),data=data,show.legend=TRUE,color="green")+
  guides(fill=guide_legend())
  # theme(legend.title=element_blank())
  # theme(legend.title = element_text(colour="blue", size=16, face="bold"))


# ----------查看插补数据在原始数据中的分布
stripplot(mi_data, col=c("grey",mdc(2)),pch=20)
# 利用回归查看插补之后的数据查看插补之后的分布
xyplot(mi_data , X1~X3 | .imp, pch=20,cex=1.2)
help("stripplot")

# -----------------with检测，单变量与自己回归-----------------
# 对X1自己
fit = with(mi_data, lm(X1~1))
# summary(fit)
fit %>% pool() %>% summary()

fit = with(mi_data, lm(X2~1))
fit %>% pool() %>% summary()

fit = with(mi_data, lm(X3~1))
fit %>% pool() %>% summary()

library(broom)
class(mi_data$imp$X1)
mi_data$imp$X1
glance(lm((mi_data$imp$X2)[1,]~1))
summary(fit)
pooled = pool(fit)
pool.r.squared(fit)

fit = with(mi_data, lm(X1~1))
summary(fit)
pooled = pool(fit)
pooled
pool.r.squared(fit)

fit = with(mi_data, lm(X2~1))
summary(fit)
pooled = pool(fit)
pooled
pool.r.squared(fit)

fit = with(mi_data, lm(X3~1))
summary(fit)
pooled = pool(fit)

pool.r.squared(fit)

# 选择一个方差比较小的变量
# 最后查看拟合之后的R^2大小
pooled = pool(fit)
pooled
pool.r.squared(fit)


# 根据方差，选择一个方差比较小的数据，这里选择第2组
complete.data = complete(mi_data, 2)
pooled = pool(fit)
write.table(complete.data, file='./complete_data.xls',row.names = F,quote=F, sep="\t")
help(write.table)





#------------------------------------------------TODO：UNDONE
# 想要自己创建拉格朗日插值函数，进行插值
data
# 找到行没有缺失的
no_na = data[complete.cases(data)==T,]
is_na = data[complete.cases(data)==F,]


# 计算插值基函数
my.lk.f = function(k, x, x.var){
  # 这里x是n+1维的
  a = 1
  # n = length(x)-1
  for(x.i in 1:length(x)){
    if (x.i==x[k]) next
    a = a*(x.var-x.i)/(x[k]-x.i)
  }
  return(a)
}

# 利用插值基函数构造拉格朗日插值多项式
my_lagr = function(x,y,x.var, k=12){
  ln = 0
  if (length(x) != length(y)){
    print(length(x))
    print(length(y))
    stop('x and y must be the same dimension!')
    }
  for (y.i in y){
    ln = ln + my.lk.f(k, x, x.var)*y.i
  }
  return(ln)
}


data[,1]
data[,1][is.na(data[,1])==F]


with(mi_data,lm(X1~1)) %>% pool() %>% summary()
with(mi_data,lm(X2~1)) %>% pool() %>% summary()
with(mi_data,lm(X3~1)) %>% pool() %>% summary()