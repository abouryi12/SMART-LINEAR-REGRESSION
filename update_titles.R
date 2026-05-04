txt <- readLines("ui.R", encoding = "UTF-8")

# Mapping of old titles to clearer ones
title_map <- list(
  "Variable Selection" = "Choose Your Variables",
  "Model Type" = "Detected Model Type",
  "Variable Info" = "Data Summary & Statistics",
  "Model Formula" = "Mathematical Formula",
  "Coefficient Table" = "Model Coefficients (Weights)",
  "Model Summary" = "Overall Model Performance",
  "T-Test: Coefficient Significance" = "Statistical Significance (P-Values)",
  "Coefficient Importance" = "Which Variable is Most Important?",
  "Q-Q Plot (Normality Check)" = "Q-Q Plot (Are Errors Normal?)",
  "Scatter Plot with Regression Line" = "Scatter Plot (Data Trend)",
  "Actual vs Predicted" = "Actual vs Predicted (Model Accuracy)",
  "Residuals vs Fitted" = "Residuals vs Fitted (Linearity Check)",
  "Residual Distribution" = "Error Distribution (Bell Curve Check)",
  "Intelligent Analysis Report" = "Smart AI Insights Report",
  "Quick Summary" = "Key Takeaways"
)

# Loop over the mapping and do precise replacements
for (old_title in names(title_map)) {
  new_title <- title_map[[old_title]]
  
  # We just replace the exact string `), "Old Title"` with `), "New Title"`
  # Regex to escape parentheses and spaces properly
  pattern <- sprintf('\\), "%s"', old_title)
  replacement <- sprintf('), "%s"', new_title)
  
  txt <- gsub(pattern, replacement, txt)
}

writeLines(txt, "ui.R")
