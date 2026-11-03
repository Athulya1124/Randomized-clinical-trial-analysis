# ============================================================
# Project 02: Randomized Clinical Trial Analysis
# Synthetic Data Generation
# ============================================================

set.seed(2026)

# Study size
n <- 300

# Subject ID
subject_id <- sprintf("SUBJ%03d", 1:n)

# 1:1 randomized treatment assignment
treatment <- sample(
  rep(c("Control", "Treatment"), each = n / 2)
)

# Baseline characteristics
age <- round(rnorm(n, mean = 62, sd = 11))
sex <- sample(
  c("Female", "Male"),
  n,
  replace = TRUE,
  prob = c(0.48, 0.52)
)

baseline_score <- round(
  rnorm(n, mean = 55, sd = 10),
  1
)

# Binary primary efficacy endpoint
# Treatment group has a higher probability of success
success_probability <- ifelse(
  treatment == "Treatment",
  0.72,
  0.58
)

primary_success <- rbinom(
  n,
  size = 1,
  prob = success_probability
)

# Continuous secondary endpoint:
# change from baseline
change_score <- ifelse(
  treatment == "Treatment",
  rnorm(n, mean = 12, sd = 8),
  rnorm(n, mean = 8, sd = 8)
)

change_score <- round(change_score, 1)

# Create analysis dataset
rct_data <- data.frame(
  subject_id,
  treatment,
  age,
  sex,
  baseline_score,
  primary_success,
  change_score
)

# Inspect dataset
head(rct_data)

# Treatment counts
table(rct_data$treatment)

# Primary endpoint counts
table(
  rct_data$treatment,
  rct_data$primary_success
)

# Save synthetic dataset
write.csv(
  rct_data,
  "rct_data.csv",
  row.names = FALSE
)
