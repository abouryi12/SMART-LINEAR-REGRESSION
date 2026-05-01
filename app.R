# ============================================
# SMART REGRESSION & DATA INSIGHT SYSTEM
# app.R - Entry Point
# ============================================

# Install missing packages
required <- c("shiny", "ggplot2", "DT")
for (pkg in required) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cran.r-project.org")
  }
}

# Source modules
source("global.R")
source("ui.R")
source("server.R")

# Launch
shinyApp(ui = ui, server = server)
