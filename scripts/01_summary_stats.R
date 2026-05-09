##After opening through working directory Summer 2026 Onet Project, load dataset
#Click sidebar to see Level 1-3 Headers
library(arrow)
github_data <- read_parquet("C10_02_GitHub_task_count.parquet")

# Inspect Data Structure #####
nrow(github_data) #1179111 observations
colnames(github_data)
#View by each variable
n_distinct(github_data$repo_lower)
n_distinct(github_data$task_topic)
n_distinct(github_data$month)

# Summary Statistics #####
## Summary of Task Counts =====
# Are there observations that have 0 task counts?
sum(github_data$repo_task_count == 0, na.rm = TRUE)
### Overall Summary -----
summary(github_data$repo_task_count)
mean(github_data$repo_task_count, na.rm = TRUE)
sd(github_data$repo_task_count, na.rm = TRUE)
median(github_data$repo_task_count, na.rm = TRUE)
#Similar to Jinci's paper(and through subsequent analyses data is right-skewed, I add a 95-percentile summary stats)
quantile(github_data$repo_task_count,
         probs = 0.95,
         na.rm = TRUE)
#Organize into a clean table
library(dplyr)
library(gt)

summary_table <- data.frame(
  Variable = c("Task Count"),
  
  N = c(sum(!is.na(github_data$repo_task_count))),
  
  Mean = c(mean(github_data$repo_task_count, na.rm = TRUE)),
  
  SD = c(sd(github_data$repo_task_count, na.rm = TRUE)),
  
  Median = c(median(github_data$repo_task_count, na.rm = TRUE)),
  
  P75 = c(quantile(github_data$repo_task_count,
                   0.75,
                   na.rm = TRUE)),
  
  P95 = c(quantile(github_data$repo_task_count,
                   0.95,
                   na.rm = TRUE)),
  
  Max = c(max(github_data$repo_task_count,
              na.rm = TRUE))
)

gt(summary_table) %>%
  fmt_number(
    columns = c(Mean, SD, Median, P75, P95, Max),
    decimals = 2
  ) %>%
  tab_header(
    title = "Descriptive Statistics"
  )

### Histograms of Task Count Frequency -----
#After doing a preliminary histogram, I realize the data is extremely right skewed. 
#Therefore, I log the data and then put the diagrams side by side for a clean comparison.
#Since there's no 0 in task count, log function is defined. I directly log task count for each observation. 
#Histogram
par(mfrow = c(1,2))

hist(github_data$repo_task_count,
     main = "Raw Task Counts",
     xlab = "repo_task_count")

hist(log(github_data$repo_task_count),
     main = "Log(Task Counts)",
     xlab = "log(repo_task_count)")

### density plot----
par(mfrow = c(1,2))

plot(density(github_data$repo_task_count),
     main = "Raw Density",
     xlab = "repo_task_count")

plot(density(log(github_data$repo_task_count)),
     main = "Log Density",
     xlab = "log(repo_task_count)")

### boxplot -----
par(mfrow = c(1,2))

boxplot(github_data$repo_task_count,
        main = "Raw Boxplot")

boxplot(log(github_data$repo_task_count),
        main = "Log Boxplot")
### Conclusion: most repositories do little activity but a small number account for massive task production.----

# Outlier Inspection (ie task counts that are unusually high) ####
## Identification =====
### Sort descending -----
github_data %>%
  arrange(desc(repo_task_count)) %>%
  select(repo_lower, month, task_topic, repo_task_count) %>%
  head(20)
#After this preliminary inspection I realize that there are too many counts in the thousands, therefore it's hard to inspect them one by one.
#I want to set a cutoff/threshold to have a sense of how many. Instead of manually setting a threshold I realize the box plot rule is a good way to do this (Q3+1.5IQR)
outliers <- boxplot.stats(github_data$repo_task_count)$out
#However, this is still not precise as I want to know exactly where large numbers start to appear.
#To have better sense of this I use：
### Percentile/distribution approach ----
task_quantiles <- quantile(
  github_data$repo_task_count,
  probs = c(0.90, 0.95, 0.99, 0.999),
  na.rm = TRUE
)
#Even at 99.9% task count is still in the hundreds (836), so I want to inspect the 'structure' of the upper tail in a distribution. 
## Upper Tail Distribution ====
### Cutoff value at n=1000 ----
#Set a threshold and organize into a new dataset
tail_data <- github_data %>%
  filter(repo_task_count > 1000)
#Plotting the tail separately into histograms and density functions
hist(tail_data$repo_task_count,
     main = "Extreme Upper Tail",
     xlab = "repo_task_count")
plot(density(tail_data$repo_task_count),
     main = "Density of Extreme Task Counts")
#They corresond to a new discovery: we seem task counts peaking around n=2000. 
#how many observations of this exist
nrow(tail_data)
#Number being 825
#also calculate as a proportion (though this is very small)
mean(github_data$repo_task_count > 1000)

### Cutoff value at n=2000 ----
tail_data <- github_data %>%
  filter(repo_task_count > 2000)
#Plotting the tail separately into histograms and density functions
hist(tail_data$repo_task_count,
     main = "Extreme Upper Tail",
     xlab = "repo_task_count")
plot(density(tail_data$repo_task_count),
     main = "Density of Extreme Task Counts")
#They corresond to a new discovery: we seem task counts peaking around n=2000. 
#how many observations of this exist
nrow(tail_data)
#Number being 209 (we can see of all the outliers above 1000, around 1/4 of them are between 1000-2000.)
#also calculate as a proportion (though this is very small)
mean(github_data$repo_task_count > 2000)

##We conclude that a majority of the outliers lie between Task Count=1000-2000. 

# Error Check ####
#Are there missing values? No.
colSums(is.na(github_data))
#Are there duplicate rows? No. 
github_data %>%
  count(repo_name, month, task_topic) %>%
  filter(n > 1)
#Month: Are there missing months? No, from Dec 22 to Nov 23.
format(sort(unique(github_data$month)), "%Y-%m")
#Task type: are there typos? Only values are 0 to 9 so no. 
table(github_data$task_topic)
#Task count: Are there negative values or non-integers? No. 
sum(github_data$repo_task_count < 0,
    na.rm = TRUE)
sum(github_data$repo_task_count %% 1 != 0,
    na.rm = TRUE)
