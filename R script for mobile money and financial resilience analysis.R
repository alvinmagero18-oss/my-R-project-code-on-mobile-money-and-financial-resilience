# ============================================
# MOBILE MONEY & FINANCIAL RESILIENCE ANALYSIS
# ============================================

# ---------------------------
# 1. LOAD PACKAGES
# ---------------------------
library(readxl)
library(dplyr)
library(ggplot2)
library(survey)
library(car)

# ---------------------------
# 2. LOAD DATA
# ---------------------------
data_path <- "C:/Users/ADMIN/Downloads/finacces 2024 datasets.xlsx"
data <- read_excel(data_path)

# ---------------------------
# 3. SELECT VARIABLES (FIXED)
# ---------------------------
data <- data %>%
  select(
    indWeight,   # CORRECT weight
    B2A,
    Age,
    Sex,
    A20,
    B1A,
    C3,
    county,
    B1C1, B1Dii, C1_10, C1_11, C1_12
  ) %>%
  rename(weight = indWeight)
# ---------------------------
# 4. SAFE NUMERIC CONVERSION
# ---------------------------
data <- data %>%
  mutate(across(everything(), ~ suppressWarnings(as.numeric(.))))

# ---------------------------
# 5. CLEAN VARIABLES
# ---------------------------
invalid <- c(97, 98, 99)

data <- data %>%
  mutate(
    mm_send    = ifelse(C1_10 == 1, 1, 0),
    mm_receive = ifelse(C1_11 == 1, 1, 0),
    mm_pay     = ifelse(C1_12 == 1, 1, 0),
    
    mobile_money_use = ifelse(
      mm_send == 1 | mm_receive == 1 | mm_pay == 1,
      1, 0
    )
  )

# ---------------------------
# 6. RECODE DEMOGRAPHICS
# ---------------------------
data <- data %>%
  mutate(
    Sex = factor(Sex, labels = c("Male", "Female")),
    
    Education = case_when(
      A20 %in% c(1,2,3) ~ "Primary",
      A20 %in% c(4,5,6) ~ "Secondary",
      A20 %in% c(7,8,9,10) ~ "Tertiary",
      TRUE ~ NA_character_
    ),
    
    Wealth = case_when(
      B1A %in% c(1,2) ~ "Low",
      B1A %in% c(3,4,5) ~ "Middle",
      B1A %in% c(6,7,8) ~ "High",
      TRUE ~ NA_character_
    ),
    
    Employment = case_when(
      C3 %in% c(1,2) ~ "Employed",
      C3 %in% c(3,4) ~ "Self-employed",
      C3 %in% c(5,6,7) ~ "Unemployed",
      TRUE ~ NA_character_
    ),
    
    urban = ifelse(county %in% c(47,1,42,32), 1, 0)
  )

# ---------------------------
# 7. MOBILE MONEY USE (CORRECT VARIABLE)
# ---------------------------
# NOTE: Adjust if codebook confirms differently

data <- data %>%
  mutate(
    mobile_money_use = case_when(
      B1C1 == 1 ~ 1,
      B1C1 == 2 ~ 0,
      TRUE ~ NA_real_
    )
  )

# ---------------------------
# 8. RESILIENCE (EXCLUDE B1C1)
# ---------------------------
data <- data %>%
  mutate(
    B1Dii = ifelse(B1Dii == 1, 1, ifelse(B1Dii == 2, 0, NA)),
    C1_10 = ifelse(C1_10 == 1, 1, ifelse(C1_10 == 2, 0, NA)),
    C1_11 = ifelse(C1_11 == 1, 1, ifelse(C1_11 == 2, 0, NA)),
    C1_12 = ifelse(C1_12 == 1, 1, ifelse(C1_12 == 2, 0, NA))
  )

data <- data %>%
  mutate(
    resilience_score = rowMeans(
      select(., B1Dii, C1_10, C1_11, C1_12),
      na.rm = TRUE
    ),
    resilient = ifelse(resilience_score >= 0.6, 1, 0)
  )

# ---------------------------
# 9. FINAL ANALYSIS DATA
# ---------------------------
final_data <- data %>%
  filter(
    !is.na(resilient),
    !is.na(mobile_money_use),
    !is.na(weight)
  )

cat("Final sample size:", nrow(final_data), "\n")

# ---------------------------
# 10. CREATE SURVEY DESIGN
# ---------------------------
design <- svydesign(
  ids = ~1,
  weights = ~weight,
  data = final_data
)

# ---------------------------
# 11. WEIGHTED DESCRIPTIVE STATS
# ---------------------------

# Mobile money
svytable(~mobile_money_use, design)

# Resilience
svytable(~resilient, design)

# Cross-tabulation
svytable(~resilient + mobile_money_use, design)

# ---------------------------
# 12. WEIGHTED CHI-SQUARE TEST
# ---------------------------
svychisq(~resilient + mobile_money_use, design)

# ---------------------------
# 13. WEIGHTED LOGISTIC REGRESSION
# ---------------------------
model_weighted <- svyglm(
  resilient ~ mobile_money_use + Age + Sex +
    Education + Wealth + Employment + urban,
  design = design,
  family = quasibinomial()
)

summary(model_weighted)

# ---------------------------
# 14. ODDS RATIOS
# ---------------------------
exp(coef(model_weighted))

# Confidence intervals
exp(confint(model_weighted))

# ---------------------------
# 15. MULTICOLLINEARITY CHECK
# ---------------------------
# (Run on unweighted glm version for VIF only)

model_check <- glm(
  resilient ~ mobile_money_use + Age + Sex +
    Education + Wealth + Employment + urban,
  data = final_data,
  family = binomial
)

vif(model_check)

# ---------------------------
# 16. VISUALS (UNWEIGHTED)
# ---------------------------
ggplot(final_data, aes(x = factor(mobile_money_use), y = resilience_score)) +
  geom_boxplot(fill = "lightblue") +
  labs(
    x = "Mobile Money Use",
    y = "Resilience Score",
    title = "Financial Resilience by Mobile Money Use"
  ) +
  theme_minimal()

ggplot(final_data, aes(x = factor(mobile_money_use), fill = factor(resilient))) +
  geom_bar(position = "fill") +
  labs(
    x = "Mobile Money Use",
    y = "Proportion",
    fill = "Resilient",
    title = "Resilience Share by Mobile Money Use"
  ) +
  theme_minimal()

summary(data$weight)
table(is.na(data$weight))