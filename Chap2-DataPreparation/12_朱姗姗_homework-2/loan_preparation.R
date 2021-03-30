library(dplyr)
library(purrr)
library(xlsx)


# ----------读取数据----------
# Sys.setlocale("LC_ALL","Chinese") 
setwd("D:/lagua/CODING/R-learn/R-code/Chap2-DataPreparation")

bankLoan = read.csv("bankloan.csv", header=TRUE,
                     fileEncoding ="GBK")


# ----------数据观察：数据空值检查----------
# ----------列检查----------
# 注意：需要检查一下数据是否有列是NA，
# 使用：以下查看
colnames(bankLoan)
length(colnames(bankLoan))
# 如果是，
# 1，手动将看到的最后几列（这里是3列）删除，无论是否看见有数据
# 2. 使用na.omit()直接将所有的具有空的行或者列删除。有风险！！！
# 参考：[R语言 -- 删除 dataFrame/matrix 中含有NA或全为NA的行或列]
# (https://www.jianshu.com/p/26edb1b1e6c7)

# ----------行检查----------
# 行中是否有空的值也需要查看，使用summary(bankLoan)查看
colnames(bankLoan) = c("Age", "Edu", "WorkAge",
                       "Address", "Income",
                       "DebtRatio", "CreditDebt",
                       "OtherDebt", "Default")

# ----------列检查----------
summary(bankLoan)

# 调整数据框列的类型
bankLoan = bankLoan %>% 
  mutate_at(.vars = vars("Address"),
            .fun = as.factor) %>%
  mutate_at(.vars = vars("Age", "WorkAge", "Income", 
                      "DebtRatio","CreditDebt","OtherDebt"),
            .fun = as.numeric) %>%
  mutate_at(.vars = vars("Age", "Edu", "WorkAge"),
            .fun = as.integer)


# ----------查看数据----------
# 找出列变量的所有整数型或者数值型的数据
loan.nvars <- bankLoan[,lapply(bankLoan,class)=="integer"
                       | lapply(bankLoan,class)=="numeric"]
summary(loan.nvars)


# ----------查看数据描述----------
descrip <- function(nvar)
{
  nmiss <- length(which(is.na(nvar)))
  mean <- mean(nvar,na.rm=TRUE)
  std <- sd(nvar,na.rm=TRUE)
  min <- min(nvar,na.rm=TRUE)
  Q1 <- quantile(nvar,0.25,na.rm=TRUE)
  median <- median(nvar,na.rm=TRUE)
  Q3 <- quantile(nvar,0.75,na.rm=TRUE)
  max <- max(nvar,na.rm=TRUE)
  return(c(nmiss,mean,std,min,Q1,median,Q3,max))
}

loan_nvars_description <- lapply(loan.nvars,descrip) %>% 
  as.data.frame() %>% t()

colnames(loan_nvars_description) <- c("nmiss","mean","std","min","Q1",
                                      "median","Q3","max")
loan_nvars_description


# ----------异常值检测----------
library(vioplot)
# 主要使用直方图来查看异常值的大致分布
for (col in colnames(bankLoan)[-c(4, 9)]){
  # vioplot(bankLoan[[col]], ylab=col)
  hist(bankLoan[[col]], xlab=col,
       main=paste("Histogram of ", col, sep=""))
}

# a = cut(bankLoan$Age, breaks = seq(10, 60, 10)) %>% unique()
# hist(cut(bankLoan$Age, breaks = seq(10, 60, 10)))


# ----------极值处理：（观察）数值变量直方图输出----------
library(showtext)
library(sysfonts)
library(showtextdb)
font_add("SIMHEI","SIMHEI.ttf")
font_add("SIMSUN","SIMSUN.TTC")
font_add("kaishu","simkai.ttf")
par(family='STKaiti')
# 设置family='GB1'
pdf("./ch2_case2-2_histogram.pdf",family='GB1')

par(c(3, 3))
for (i in 1:length(loan.nvars)){
  hist(loan.nvars[,i],
       xlab=names(loan.nvars)[i],
       main=paste("Histogram of",names(loan.nvars)[i]),
       col = "grey")
}
dev.off()


# ----------极值处理----------
colnames(bankLoan)
colnames(loan.nvars)

library(MASS)
par(c(1, 3))
# log.vars = c("Income", "CreditRatio", "OtherDebt")
log.vars = c(4, 6, 7)
# new_col = list()
for (i in log.vars){
  var.names = colnames(loan.nvars)
  cur_name = paste(var.names[i],  '.', 1, sep = '')
  new_col = log(loan.nvars[, i] + 1)
  loan.nvars[[cur_name]] = new_col
  hist(loan.nvars[[cur_name]],
       xlab=paste(var.names[i],  '.', 1, sep = ''),
       main=paste("Histogram of",cur_name),
       col = "grey")
}

loanNew = cbind(bankLoan, loan.nvars[,9:11])
loanNew = loanNew[, -c(5, 7, 8)]
colnames(loanNew)


# ----------数据分箱----------
# TODO


# ----------变量选择----------
##删除冗余变量,生成新数据集loanNew
# > colnames(loanNew)
# [1] "Age"          "Edu"          "WorkAge"      "Address"     
# [5] "Income"       "DebtRatio"    "CreditDebt"   "OtherDebt"   
# [9] "Default"      "Income.1"     "CreditDebt.1" "OtherDebt.1" 
# ----------第一步：数值型变量筛选：卡方检验----------
chisq.test(table(loanNew$Address, loanNew$Default))


# ----------变量筛选第一步：画相关系数图----------
cor(loanNew[,-c(4)])
cor.test(loanNew[,-c(4)])

library(corrplot)
corrplot(corr=cor(loanNew[,-c(4)]))
corrplot(corr=cor(loanNew[,-c(4)]), method="number")

# ----------变量筛选第二步：进行t检验----------
test_vars = c("Age", "Edu", "Income.1", "OtherDebt.1")
t.test(loanNew$Age ~ loanNew$Default)
t.test(loanNew$Edu ~ loanNew$Default)
t.test(loanNew$Income.1 ~ loanNew$Default)
t.test(loanNew$OtherDebt.1 ~ loanNew$Default)


# ----------欠采样与过采样----------
##进行欠抽样使得响应者的比例达到1/3
loan1 <- loanNew[loanNew$Default==1,]
loan0 <- loanNew[loanNew$Default==0,]
n1 <- dim(loan1)[1]
n0 <- 2*n1
# 响应观测数是非响应观测数的1/2
loan0 <- loan0[sample(1:dim(loan0)[1],n0),]
loanNew1 <- rbind(loan1,loan0)


# ----------存储数据----------
write.csv(loan_nvars_description,"static/loan_nvars_description.csv")
write.csv(loanNew,"static/loanNew.csv",row.names=FALSE)
write.csv(loanNew1,"static/loanNew1.csv",row.names=FALSE)
