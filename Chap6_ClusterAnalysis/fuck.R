# -----------读取数据
air_data = read.csv("D:/lagua/CODING/R-learn/R-code/Chap6_ClusterAnalysis/air_data.csv",
                    header=TRUE,quote = "",
                    sep=",",
                    encoding='UTF-8',
                    strip.white = TRUE
)
colnames(air_data)
col_need = c('LOAD_TIME', 'FFP_DATE','LAST_TO_END', 'FLIGHT_COUNT', 'SEG_KM_SUM', 'avg_discount')

air_data = subset(air_data, select=col_need)
air_data$LOAD_TIME = as.Date(air_data$LOAD_TIME)
air_data$FFP_DATE = as.Date(air_data$FFP_DATE)
str(air_data)


library(dplyr)
# -----------1、数据预处理
# 1 初始化数据
# 2 将数据转化成整数
# 3 删除列
# 4 重新命名
# 5 对列重新排序
new_air = air_data
new_air = na.omit(new_air)
new_air$L = (new_air$LOAD_TIME - new_air$FFP_DATE) %>% as.numeric()
new_air$FLIGHT_COUNT = as.numeric(new_air$FLIGHT_COUNT)
new_air = new_air[,-which(names(new_air) %in% c('LOAD_TIME', 'FFP_DATE'))]
new_air = rename(new_air, c("R"='LAST_TO_END', "F"='FLIGHT_COUNT', "M"='SEG_KM_SUM', 'C'='avg_discount'))
new_air = new_air[, c(5, 1, 2, 3, 4)]
colnames(new_air)
head(new_air)
str(new_air)

# 最大最小标准化
normalize <- function(x) {
  return((x - min(x)) / (max(x) - min(x)))
}

std_air = apply(new_air, 2, normalize)
head(std_air)
# L = LOAD_DATE - FFP_DATE
# R = LAST_TO_END
# F = FLIGHT_COUNT
# M = SEG_KM_SUM
# C = AVG_DISCOUNT
# L = LOAD_TIME - FFP_DATE

# -----------2、k均值聚类
K <- 5
clusterair <- kmeans(std_air,centers = K,iter.max = 99,nstart=25)
table(col=clusterair$cluster)

# -----画图
color = clusterair$cluster
L <- std_air[, 1]
R <- std_air[, 2]
p <- ggplot(data=as.data.frame(std_air), mapping=aes(x=L, y=R))
d <- p + geom_point(aes(colour=color)) + ggtitle(label="Air data after k-means cluster")+ scale_color_gradientn(colours =rainbow(4))
d
plot(std_air, col=clusterair$cluster)

