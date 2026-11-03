# ============================================================
# Project 02: Randomized Clinical Trial Analysis
# Statistical Analysis
# ============================================================

# Load simulated dataset
rct_data <- read.csv("rct_data.csv")

# ------------------------------------------------------------
# 1. Baseline characteristics
# ------------------------------------------------------------

format_mean_sd <- function(x) {
  sprintf("%.1f (%.1f)", mean(x), sd(x))
}

format_n_pct <- function(x, level) {
  n <- sum(x == level)
  pct <- 100 * n / length(x)
  sprintf("%d (%.1f%%)", n, pct)
}

control <- rct_data[rct_data$treatment == "Control", ]
treatment <- rct_data[rct_data$treatment == "Treatment", ]

baseline_table <- data.frame(
  Characteristic = c(
    "N",
    "Age, mean (SD)",
    "Female, n (%)",
    "Baseline Score, mean (SD)"
  ),
  Control = c(
    nrow(control),
    format_mean_sd(control$age),
    format_n_pct(control$sex, "Female"),
    format_mean_sd(control$baseline_score)
  ),
  Treatment = c(
    nrow(treatment),
    format_mean_sd(treatment$age),
    format_n_pct(treatment$sex, "Female"),
    format_mean_sd(treatment$baseline_score)
  )
)

# ------------------------------------------------------------
# 2. Primary endpoint analysis
# ------------------------------------------------------------

x_control <- sum(control$primary_success)
n_control <- nrow(control)

x_treatment <- sum(treatment$primary_success)
n_treatment <- nrow(treatment)

p_control <- x_control / n_control
p_treatment <- x_treatment / n_treatment

risk_difference <- p_treatment - p_control

# Two-sided test for difference in proportions
primary_test <- prop.test(
  x = c(x_treatment, x_control),
  n = c(n_treatment, n_control),
  correct = FALSE
)

# Approximate 95% CI for risk difference
se_rd <- sqrt(
  p_treatment * (1 - p_treatment) / n_treatment +
    p_control * (1 - p_control) / n_control
)

z <- qnorm(0.975)

rd_lower <- risk_difference - z * se_rd
rd_upper <- risk_difference + z * se_rd

primary_endpoint <- data.frame(
  Measure = c(
    "Treatment Success",
    "Control Success",
    "Risk Difference",
    "95% CI Lower",
    "95% CI Upper",
    "P-value"
  ),
  Result = c(
    sprintf("%d/%d (%.1f%%)",
            x_treatment, n_treatment, 100 * p_treatment),
    sprintf("%d/%d (%.1f%%)",
            x_control, n_control, 100 * p_control),
    sprintf("%.1f%%", 100 * risk_difference),
    sprintf("%.1f%%", 100 * rd_lower),
    sprintf("%.1f%%", 100 * rd_upper),
    sprintf("%.4f", primary_test$p.value)
  )
)

# ------------------------------------------------------------
# 3. Export results
# ------------------------------------------------------------

write.csv(
  baseline_table,
  "baseline_table.csv",
  row.names = FALSE
)

write.csv(
  primary_endpoint,
  "primary_endpoint.csv",
  row.names = FALSE
)

# ------------------------------------------------------------
# 4. Display results
# ------------------------------------------------------------

cat("\nBASELINE CHARACTERISTICS\n")
print(baseline_table)

cat("\nPRIMARY ENDPOINT ANALYSIS\n")
print(primary_endpoint)

# ------------------------------------------------------------
# 5. Treatment effect figure
# ------------------------------------------------------------

success_rates <- c(
  Control = mean(rct_data$primary_success[rct_data$treatment == "Control"]),
  Treatment = mean(rct_data$primary_success[rct_data$treatment == "Treatment"])
)

png("treatment_effect.png", width = 800, height = 600)

barplot(
  success_rates,
  ylim = c(0, 1),
  ylab = "Primary Endpoint Success Rate",
  main = "Primary Endpoint by Treatment Group"
)

abline(
  h = seq(0, 1, 0.2),
  lty = 3
)

dev.off()
