library(arules)
library(arulesViz)

# ----------1 读取数据
setwd("D:/lagua/CODING/R-learn/R-code/Chap4_AssociationRule")
shopBasket = read.csv("shop_basket.csv", sep=",")
# 去除前7个与购买商品无关的数据
shopBasket = shopBasket[, -seq(1, 7, 1)]

# ----------2 查看数据、转换数据、画图查看
# ----------2 查看数据
# 查看前4个观测数据顾客购买的商品
# 等价于inspect(shopBasket[1:4])
for (i in 1:4){
  print(names(shopBasket[i,])[shopBasket[i,]==1])
}

# ----------2 转换数据
# 将数据每一行字段取值为1的列名拿出来，这些列名代表每一条观测购买的商品
shopBasket <- apply(shopBasket,1,function(x) names(x)[x==1])
# 或者直接list(shopBasket)
# 再shopBaseket = as(shopBasket, "transactions")
# 转换成Apriori可以识别的数据类型
shopBasket = as(shopBasket, "transactions")

# 查看的概览
summary(shopBasket)
inspect(shopBasket[1:4])

# ----------2 画图查看
help("itemFrequencyPlot")
itemFrequencyPlot(shopBasket, support=0.01, 
                  main="Relative Itemeq Plot",
                  type="absolute")


# ----------3 关联分析 调整sup_min, conf_min
# 关联分析 初步分析
help(apriori)
rules <- apriori(shopBasket, 
                 parameter=list(support=0.01, confidence=0.1,target="rules"))
summary(rules)

# 固定min_conf 设置support为0.031（上三分位数）
rules <- apriori(shopBasket, 
                 parameter=list(support=0.031, confidence=0.1,target="rules"))
summary(rules)

# 调整min_sup之后并固定 设置confidence为0.5233（上三分位数）
rules <- apriori(shopBasket, 
                 parameter=list(support=0.031, confidence=0.5233,target="rules"))
summary(rules)


# ----------4 查看关联规则，按照support, confidence, lift排序
# 把所有规则按照lift（提升度）排序查看关联规则
shopBasket.sorted<-sort(x=rules,by="lift",decreasing=TRUE)
inspect(shopBasket.sorted)

# 逐条查看数据集shopBasket.sorted的前6条记录
# 这其实跟前面排序是等价的
inspect(head(shopBasket.sorted))

# 查看分析结果
options(digits=4)
#设置输出小数位数为4位数
inspect(head(rules,by="lift"))
# inspect函数逐条查看关联规则
#  by="lift"指定按提升值降序排列。


# ----------5 关联分析结果可视化
plot(rules)
# 对关联规则的支持度、置信度和提升值进行可视化