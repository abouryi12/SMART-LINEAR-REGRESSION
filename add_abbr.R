txt <- readLines("ui.R", encoding = "UTF-8")

# Mapping of specific titles to the desired 2-letter abbreviations
abbr_map <- list(
  "Data Source" = "DS",
  "Dataset Preview" = "DP",
  "Variable Selection" = "VS",
  "Model Type" = "MT",
  "Variable Info" = "VI",
  "Model Formula" = "MF",
  "Coefficient Table" = "CT",
  "Model Summary" = "MS",
  "T-Test: Coefficient Significance" = "TT",
  "Coefficient Importance" = "CI",
  "Q-Q Plot (Normality Check)" = "QQ",
  "Scatter Plot with Regression Line" = "SP",
  "Actual vs Predicted" = "AP",
  "Residuals vs Fitted" = "RF",
  "Residual Distribution" = "RD",
  "Intelligent Analysis Report" = "IA",
  "Model Health Score" = "HS",
  "Quick Summary" = "QS"
)

# Loop over the mapping and do precise replacements
for (title in names(abbr_map)) {
  abbr <- abbr_map[[title]]
  
  # Example target to replace:
  # tags$span(class = "icon icon-blue"), "Data Source"
  # into:
  # tags$span(class = "icon icon-blue", "DS"), "Data Source"
  
  # Regex to find: tags$span(class = "icon icon-SOMETHING"), "Title"
  pattern <- sprintf('(tags\\$span\\(class = "icon icon-[a-z]+")(?:,\\s*"[A-Z]*")?\\),\\s*"%s"', title)
  replacement <- sprintf('\\1, "%s"), "%s"', abbr, title)
  
  txt <- gsub(pattern, replacement, txt)
}

writeLines(txt, "ui.R")
