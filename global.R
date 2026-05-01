# ============================================
# SMART REGRESSION & DATA INSIGHT SYSTEM
# global.R - Helper Functions & Theme
# ============================================

suppressPackageStartupMessages({
  library(shiny)
  library(ggplot2)
  library(DT)
})

# ggplot2 Premium Dark Theme
theme_premium <- function() {
  theme_minimal(base_family = "sans") +
    theme(
      plot.background = element_rect(fill = "#080808", color = NA),
      panel.background = element_rect(fill = "#080808", color = NA),
      panel.grid.major = element_line(color = "#ff1a1a20", linewidth = 0.3),
      panel.grid.minor = element_blank(),
      text = element_text(color = "#ffffff"),
      axis.text = element_text(color = "#ffcccc", size = 10),
      axis.title = element_text(color = "#ffcccc", size = 11, face = "bold"),
      plot.title = element_text(color = "#ffffff", size = 14, face = "bold", margin = margin(b = 8)),
      plot.subtitle = element_text(color = "#ff9999", size = 10, margin = margin(b = 12)),
      legend.background = element_rect(fill = "#080808", color = NA),
      legend.text = element_text(color = "#ffcccc", size = 9),
      legend.title = element_text(color = "#ffffff", size = 10),
      plot.margin = margin(16, 16, 16, 16)
    )
}

# Metric Card HTML
metric_card_html <- function(label, value, sub = "", color_class = "val-blue") {
  tags$div(class = "metric-card",
    tags$div(class = "metric-label", label),
    tags$div(class = paste("metric-value", color_class), value),
    if (nchar(sub) > 0) tags$div(class = "metric-sub", sub) else NULL
  )
}

# Insight Block HTML
insight_html <- function(title, text, type = "") {
  cls <- if (type == "success") "insight-block success"
         else if (type == "warning") "insight-block warning"
         else if (type == "danger") "insight-block danger"
         else "insight-block"
  tags$div(class = cls, tags$h4(title), tags$p(HTML(text)))
}

# Generate Intelligent Insights
generate_insights <- function(model, data, y_var, x_vars) {
  s <- summary(model)
  r2 <- s$r.squared
  adj_r2 <- s$adj.r.squared
  se <- s$sigma
  coefs <- as.data.frame(s$coefficients)
  n <- nrow(data)
  p <- length(x_vars)
  insights <- list()

  # 1. Model Strength
  strength <- if (r2 >= 0.85) "Strong" else if (r2 >= 0.6) "Moderate" else if (r2 >= 0.3) "Weak" else "Very Weak"
  strength_type <- if (r2 >= 0.6) "success" else if (r2 >= 0.3) "warning" else "danger"
  insights[[length(insights) + 1]] <- list(
    title = paste0("Model Strength: ", strength),
    text = sprintf("R\u00b2 = %.4f \u2014 The model explains <b>%.1f%%</b> of the variance in <b>%s</b>. %s",
      r2, r2 * 100, y_var,
      if (r2 >= 0.85) "Excellent predictive power."
      else if (r2 >= 0.6) "Good fit, but some variance remains unexplained."
      else "Consider adding more relevant features or transforming variables."),
    type = strength_type)

  # 2. Adjusted R2 vs R2
  gap <- r2 - adj_r2
  if (gap > 0.05) {
    insights[[length(insights) + 1]] <- list(
      title = "Possible Overfitting Detected",
      text = sprintf("Gap between R\u00b2 (%.4f) and Adjusted R\u00b2 (%.4f) is %.4f. Some predictors may not add real value. Consider removing weak features.",
        r2, adj_r2, gap),
      type = "warning")
  }

  # 3. Most Influential Variables
  if (p >= 1) {
    coef_names <- rownames(coefs)
    non_int <- coef_names[coef_names != "(Intercept)"]
    if (length(non_int) > 0) {
      t_vals <- abs(coefs[non_int, "t value"])
      names(t_vals) <- non_int
      sorted <- sort(t_vals, decreasing = TRUE)
      top <- names(sorted)[1]
      p_val <- coefs[top, "Pr(>|t|)"]
      
      sig_text <- "Not statistically significant at alpha = 0.05."
      if (!is.na(p_val) && length(p_val) > 0) {
        if (p_val < 0.001) sig_text <- "Highly significant."
        else if (p_val < 0.05) sig_text <- "Statistically significant."
      }
      
      insights[[length(insights) + 1]] <- list(
        title = "Most Influential Variable",
        text = sprintf("The strongest predictor is <b>%s</b> (|t| = %.2f, p = %.4f). %s",
          top, sorted[1], p_val, sig_text),
        type = "")
    }
  }

  # 4. Significance Check
  if (p >= 1) {
    non_int <- rownames(coefs)[rownames(coefs) != "(Intercept)"]
    p_vals <- coefs[non_int, "Pr(>|t|)", drop = TRUE]
    non_sig <- names(p_vals[p_vals >= 0.05])
    if (length(non_sig) > 0) {
      insights[[length(insights) + 1]] <- list(
        title = "Non-Significant Predictors",
        text = sprintf("Variables with p > 0.05: <b>%s</b>. These may not contribute meaningfully. Consider removing them for a simpler model.",
          paste(non_sig, collapse = ", ")),
        type = "warning")
    }
  }

  # 5. Residual SE
  se_ratio <- se / mean(abs(data[[y_var]]), na.rm = TRUE)
  se_type <- if (se_ratio < 0.1) "success" else if (se_ratio < 0.25) "" else "danger"
  insights[[length(insights) + 1]] <- list(
    title = "Estimation Accuracy",
    text = sprintf("Residual Standard Error = %.4f. Relative to mean |%s| = %.2f, this is a <b>%.1f%%</b> error rate.",
      se, y_var, mean(abs(data[[y_var]]), na.rm = TRUE), se_ratio * 100),
    type = se_type)

  # 6. Multicollinearity Warning
  if (p >= 2) {
    num_x <- data[, x_vars, drop = FALSE]
    num_x <- num_x[, sapply(num_x, is.numeric), drop = FALSE]
    if (ncol(num_x) >= 2) {
      cor_mat <- cor(num_x, use = "complete.obs")
      diag(cor_mat) <- 0
      max_cor <- max(abs(cor_mat))
      if (max_cor > 0.8) {
        idx <- which(abs(cor_mat) == max_cor, arr.ind = TRUE)[1, ]
        insights[[length(insights) + 1]] <- list(
          title = "Multicollinearity Warning",
          text = sprintf("High correlation (r = %.2f) between <b>%s</b> and <b>%s</b>. This can inflate standard errors and make coefficients unstable. Consider removing one.",
            max_cor, colnames(cor_mat)[idx[1]], colnames(cor_mat)[idx[2]]),
          type = "danger")
      }
    }
  }

  # 7. Sample Size
  if (n < 30) {
    insights[[length(insights) + 1]] <- list(
      title = "Data Quality Note",
      text = sprintf("Only %d observations. Results may be unreliable. Aim for at least 30+ observations for robust inference.", n),
      type = "warning")
  }

  # 8. Recommendation
  rec <- if (r2 >= 0.85 && gap <= 0.05) "The model performs well. Monitor for new data and validate on a holdout set."
         else if (r2 >= 0.6) "Good model. Consider feature engineering or polynomial terms to improve further."
         else if (p >= 3 && gap > 0.05) "Model may be overfitting. Try removing non-significant predictors or using regularization."
         else "Weak model. Investigate data quality, add relevant features, or try non-linear approaches."
  insights[[length(insights) + 1]] <- list(
    title = "Recommendation",
    text = rec,
    type = if (r2 >= 0.6) "success" else "warning")

  insights
}
