library(arrow)
library(dplyr)
library(tidyr)

install.packages("writexl")
library(writexl)

github_data <- read_parquet("c10_02_GitHub_task_count.parquet")

# organize by same repo/team to aggregate total task counts
repo_total_counts <- github_data %>%
  group_by(repo_lower) %>%
  summarise(
    total_task_count = sum(repo_task_count, na.rm = TRUE),
    .groups = "drop"
  )

# aggregate counts within repo × task
repo_task_counts <- github_data %>%
  group_by(repo_lower, task_topic) %>%
  summarise(
    total_task_count = sum(repo_task_count, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  
  # convert task topics into columns
  pivot_wider(
    names_from = task_topic,
    values_from = total_task_count,
    values_fill = 0,
    names_prefix = "task_"
  )
#We don't directly start calculating shares as we are seeing many 0s in counts already. Instead we pivot to team level. 
#We eyeball the data and see that if inspecting by repository, counts in respective task types are too small (many 0) to construct a meaningful distribution.
#Therefore, we group at team instead of repository level.
#Extract the team column through separating team/repo
library(stringr)

github_data <- github_data %>%
  mutate(
    team = str_extract(repo_lower, "^[^/]+")
  )
#Aggregate task counts by team
team_task_counts <- github_data %>%
  group_by(team, task_topic) %>%
  summarise(
    task_count = sum(repo_task_count, na.rm = TRUE),
    .groups = "drop"
  )
#Export
write_xlsx(
  team_task_counts,
  "output/team_task_counts_long.xlsx",
)
#Aggregate task within each team, wide format
team_task_counts_wide <- team_task_counts %>%
  pivot_wider(
    names_from = task_topic,
    values_from = task_count,
    values_fill = 0,
    names_prefix = "task_count_"
  )
#Export
write_xlsx(
  team_task_counts_wide,
  "output/team_task_counts_wide.xlsx",
)
#Compute task shares by team from task counts
team_task_shares <- team_task_counts %>%
  group_by(team) %>%
  mutate(
    total_team_tasks = sum(task_count),
    task_share = task_count / total_team_tasks
  ) %>%
  ungroup()
#Export
write_xlsx(
  team_task_shares,
  "output/team_task_shares_long.xlsx",
)
#convert to wide format
team_task_shares_wide <- team_task_shares %>%
  select(team, task_topic, task_share) %>%
  pivot_wider(
    names_from = task_topic,
    values_from = task_share,
    values_fill = 0,
    names_prefix = "task_share_"
  )
#Export
write_xlsx(
  team_task_shares_wide,
  "output/team_task_shares_wide.xlsx",
)
#There are 47,905 teams left so it's still hard to interpret. Therefore, we try to do summary statistics.
#Mean task activity by type: what fraction of activity belongs to each task?
overall_distribution <- team_task_shares %>%
  group_by(task_topic) %>%
  summarise(
    mean_share = mean(task_share),
    .groups = "drop"
  )%>%
arrange(desc(mean_share))

#Save this mean table to Github
write_xlsx(
  overall_distribution,
  "output/overall_distribution.xlsx",
)
#SD of task activity by type: how much variation is there across teams for the same task?
heterogeneity <- team_task_shares %>%
  group_by(task_topic) %>%
  summarise(
    sd_share = sd(task_share),
    .groups = "drop"
  )%>%
arrange(desc(sd_share))
#Save this sd table to Github
write_xlsx(
  heterogeneity,
  "output/task_heterogeneity.xlsx",
)