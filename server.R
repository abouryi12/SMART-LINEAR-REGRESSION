# ============================================
# SMART REGRESSION & DATA INSIGHT SYSTEM
# server.R - Server Logic
# ============================================

server <- function(input, output, session) {

  rv <- reactiveValues(data = NULL, model = NULL, model_summary = NULL, trained = FALSE)



  # === DATA LOADING ===

  observeEvent(input$file_upload, {
    req(input$file_upload)
    tryCatch({
      df <- read.csv(input$file_upload$datapath,
        header = input$header, sep = input$sep, stringsAsFactors = FALSE)
      rv$data <- df; rv$trained <- FALSE; rv$model <- NULL
      showNotification("Dataset loaded successfully!", type = "message", duration = 3)
    }, error = function(e) {
      showNotification(paste("Error:", e$message), type = "error", duration = 5)
    })
  })


  rv_manual <- reactiveValues(num_x = 1)
  
  observeEvent(input$add_x_btn, { rv_manual$num_x <- rv_manual$num_x + 1 })
  observeEvent(input$remove_x_btn, { if(rv_manual$num_x > 1) rv_manual$num_x <- rv_manual$num_x - 1 })
  
  output$manual_x_inputs <- renderUI({
    inputs <- lapply(1:rv_manual$num_x, function(i) {
      current_val <- isolate(input[[paste0("manual_x_", i)]])
      val <- if (!is.null(current_val)) current_val else if (i == 1) "1\n2\n3\n4\n5" else ""
      textAreaInput(paste0("manual_x_", i), paste("X", i), value = val, rows = 5, width = "75px")
    })
    do.call(tagList, inputs)
  })

  observeEvent(input$apply_manual, {
    tryCatch({
      y_vals <- as.numeric(trimws(unlist(strsplit(input$manual_y, "[,\n\r\t ]+"))))
      y_vals <- y_vals[!is.na(y_vals)]
      
      df <- data.frame(Y = y_vals)
      
      for(i in 1:rv_manual$num_x) {
        x_text <- input[[paste0("manual_x_", i)]]
        x_vals <- as.numeric(trimws(unlist(strsplit(x_text, "[,\n\r\t ]+"))))
        x_vals <- x_vals[!is.na(x_vals)]
        
        if(length(x_vals) > 0) {
          req(length(x_vals) == length(y_vals))
          df[[paste0("X", i)]] <- x_vals
        }
      }
      
      if(ncol(df) > 1) {
        df <- df[, c(setdiff(names(df), "Y"), "Y"), drop = FALSE]
      }
      
      req(ncol(df) >= 2)
      rv$data <- df
      rv$trained <- FALSE; rv$model <- NULL
      showNotification("Manual data applied successfully!", type = "message", duration = 3)
    }, error = function(e) {
      showNotification("Invalid format. Make sure all variables have the same number of values.", type = "error", duration = 4)
    })
  })

  output$data_info_badges <- renderUI({
    req(rv$data); df <- rv$data
    num_vars <- sum(sapply(df, is.numeric))
    tags$div(style = "display:flex;gap:10px;flex-wrap:wrap;",
      tags$span(class = "badge-status badge-success", paste(nrow(df), "rows")),
      tags$span(class = "badge-status badge-success", paste(ncol(df), "columns")),
      tags$span(class = "badge-status badge-warning", paste(num_vars, "numeric")))
  })

  output$data_table <- DT::renderDataTable({
    req(rv$data)
    DT::datatable(rv$data,
      selection = "none",
      options = list(pageLength = 10, scrollX = TRUE, dom = 'lfrtip',
        language = list(search = "Search:")),
      rownames = FALSE, class = "compact")
  })

  # === MODEL CONFIGURATION ===

  numeric_cols <- reactive({ req(rv$data); names(rv$data)[sapply(rv$data, is.numeric)] })

  output$y_var_ui <- renderUI({
    req(numeric_cols())
    selectInput("y_var", "Response Variable (Y)", choices = numeric_cols(), selected = numeric_cols()[1])
  })

  output$x_vars_ui <- renderUI({
    req(numeric_cols(), input$y_var)
    avail <- setdiff(numeric_cols(), input$y_var)
    checkboxGroupInput("x_vars", "Predictor Variables (X)", choices = avail, selected = avail[1])
  })

  output$model_type_display <- renderUI({
    n_x <- length(input$x_vars)
    type_text <- if (n_x <= 1) "Simple Linear Regression" else "Multiple Linear Regression"
    type_badge <- if (n_x <= 1) "badge-success" else "badge-warning"
    tags$div(
      tags$span(class = paste("badge-status", type_badge), 
        style = "font-size:14px;font-weight:700;padding:8px 16px;", type_text))
  })

  output$var_info_panel <- renderUI({
    req(rv$data, input$y_var, input$x_vars)
    y_data <- rv$data[[input$y_var]]
    y_html <- tags$p(style = "color:#a0aabf;font-size:12px;margin-bottom:6px;",
      sprintf("Y: %s | Mean: %.2f", input$y_var, mean(y_data, na.rm=T)))
    
    x_htmls <- lapply(input$x_vars, function(x) {
      x_data <- rv$data[[x]]
      tags$p(style = "color:#a0aabf;font-size:12px;margin-bottom:4px;",
        sprintf("X: %s | Mean: %.2f", x, mean(x_data, na.rm=T)))
    })
    
    tags$div(y_html, x_htmls)
  })

  # === MODEL TRAINING ===

  observeEvent(input$train_model, {
    req(rv$data, input$y_var, input$x_vars)
    tryCatch({
      formula_str <- paste(input$y_var, "~", paste(input$x_vars, collapse = " + "))
      model <- lm(as.formula(formula_str), data = rv$data)
      rv$model <- model; rv$model_summary <- summary(model); rv$trained <- TRUE
      showNotification("Model trained successfully in <0.01s!", type = "message", duration = 3)
    }, error = function(e) {
      showNotification(paste("Error:", e$message), type = "error", duration = 5)
    })
  })

  output$formula_display <- renderText({
    if (rv$trained) {
      coefs <- coef(rv$model)
      terms <- c()
      
      if (!is.na(coefs["(Intercept)"])) {
        terms <- c(terms, as.character(round(coefs["(Intercept)"], 4)))
      }
      
      for (var in names(coefs)) {
        if (var != "(Intercept)" && !is.na(coefs[var])) {
          val <- coefs[var]
          sign <- ifelse(val >= 0, "+", "-")
          terms <- c(terms, paste0(sign, " ", as.character(round(abs(val), 4)), "(", var, ")"))
        }
      }
      
      if (length(terms) == 0) return("No valid coefficients")
      
      eq <- paste(terms, collapse = " ")
      if (startsWith(eq, "+ ")) eq <- sub("\\+ ", "", eq)
      
      paste0(input$y_var, " = ", eq)
    } else {
      req(input$y_var, input$x_vars)
      paste(input$y_var, "=", "B0 +", paste(paste0("B", seq_along(input$x_vars), "(", input$x_vars, ")"), collapse = " + "))
    }
  })

  output$model_summary <- renderPrint({ req(rv$model); summary(rv$model) })

  output$coef_table_ui <- renderUI({
    req(rv$model_summary)
    coefs <- as.data.frame(rv$model_summary$coefficients)
    coefs$Variable <- rownames(coefs)
    rows <- lapply(seq_len(nrow(coefs)), function(i) {
      tags$tr(tags$td(coefs$Variable[i]), tags$td(as.character(round(coefs[i,1], 4))),
        tags$td(as.character(round(coefs[i,2], 4))), tags$td(as.character(round(coefs[i,3], 3))),
        tags$td(as.character(round(coefs[i,4], 6))))
    })
    tags$table(class = "coef-table",
      tags$thead(tags$tr(tags$th("Variable"), tags$th("Estimate"), tags$th("Std. Error"),
        tags$th("t value"), tags$th("Pr(>|t|)"))),
      tags$tbody(rows))
  })

  # === VISUALIZATION ===

  output$scatter_plot <- renderPlot({
    req(rv$model, input$y_var, input$x_vars)
    x1 <- input$x_vars[1]
    ggplot(rv$data, aes(x = .data[[x1]], y = .data[[input$y_var]])) +
      geom_point(color = "#cfa85f", alpha = 0.8, size = 3) +
      geom_smooth(method = "lm", color = "#cfa85f", fill = "#cfa85f14", linewidth = 1.2, se = TRUE) +
      labs(title = "Scatter Plot with Regression Line", subtitle = paste(input$y_var, "vs", x1), x = x1, y = input$y_var) +
      theme_premium()
  }, bg = "#080808")

  output$actual_vs_pred <- renderPlot({
    req(rv$model)
    actual <- rv$data[[input$y_var]]; predicted <- predict(rv$model)
    plot_df <- data.frame(Actual = actual, Predicted = predicted)
    rng <- range(c(actual, predicted))
    ggplot(plot_df, aes(x = Actual, y = Predicted)) +
      geom_point(color = "#ffffff", alpha = 0.8, size = 3) +
      geom_abline(slope = 1, intercept = 0, color = "#ff4040", linewidth = 1, linetype = "dashed") +
      labs(title = "Actual vs Predicted", subtitle = "Points on the dashed line = perfect prediction",
        x = "Actual Values", y = "Predicted Values") +
      coord_cartesian(xlim = rng, ylim = rng) + theme_premium()
  }, bg = "#080808")

  output$residual_plot <- renderPlot({
    req(rv$model)
    plot_df <- data.frame(Fitted = fitted(rv$model), Residuals = residuals(rv$model))
    ggplot(plot_df, aes(x = Fitted, y = Residuals)) +
      geom_hline(yintercept = 0, color = "#ff4040", linewidth = 0.8, linetype = "dashed") +
      geom_point(color = "#cfa85f", alpha = 0.8, size = 3) +
      geom_smooth(method = "loess", color = "#ff2020", se = FALSE, linewidth = 1) +
      labs(title = "Residuals vs Fitted Values", subtitle = "Ideally random scatter around zero",
        x = "Fitted Values", y = "Residuals") + theme_premium()
  }, bg = "#080808")

  output$residual_hist <- renderPlot({
    req(rv$model)
    plot_df <- data.frame(Residuals = residuals(rv$model))
    ggplot(plot_df, aes(x = Residuals)) +
      geom_histogram(fill = "#ff1a1a", color = "#050505", alpha = 0.8, bins = 20) +
      geom_density(aes(y = after_stat(count)), color = "#ff1a1a", linewidth = 1) +
      labs(title = "Residual Distribution", subtitle = "Should approximate a normal (bell) curve",
        x = "Residuals", y = "Frequency") + theme_premium()
  }, bg = "#080808")

  # === EVALUATION ===

  output$metric_r2 <- renderUI({
    req(rv$model_summary); r2 <- rv$model_summary$r.squared
    quality <- if(r2 >= 0.8) "Excellent" else if(r2 >= 0.6) "Good" else if(r2 >= 0.3) "Fair" else "Poor"
    metric_card_html("R\u00b2 (Goodness of Fit)", sprintf("%.4f", r2), quality, "val-blue")
  })

  output$metric_adjr2 <- renderUI({
    req(rv$model_summary)
    metric_card_html("Adjusted R\u00b2", sprintf("%.4f", rv$model_summary$adj.r.squared), "Penalized for complexity", "val-purple")
  })

  output$metric_se <- renderUI({
    req(rv$model_summary)
    metric_card_html("Residual Std. Error", sprintf("%.4f", rv$model_summary$sigma),
      paste("on", rv$model_summary$df[2], "df"), "val-green")
  })

  output$metric_fstat <- renderUI({
    req(rv$model_summary); f <- rv$model_summary$fstatistic
    p_val <- pf(f[1], f[2], f[3], lower.tail = FALSE)
    sig <- if(p_val < 0.001) "Highly Significant" else if(p_val < 0.05) "Significant" else "Not Significant"
    metric_card_html("F-Statistic", sprintf("%.2f", f[1]), sig, "val-blue")
  })

  output$ttest_table_ui <- renderUI({
    req(rv$model_summary)
    coefs <- as.data.frame(rv$model_summary$coefficients); coefs$Variable <- rownames(coefs)
    rows <- lapply(seq_len(nrow(coefs)), function(i) {
      p_val <- coefs[i, 4]
      decision <- if(p_val < 0.001) "Highly Significant" else if(p_val < 0.05) "Significant" else "Not Significant"
      tags$tr(tags$td(coefs$Variable[i]), tags$td(sprintf("%.3f", coefs[i,3])),
        tags$td(sprintf("%.6f", p_val)),
        tags$td(decision))
    })
    tags$table(class = "coef-table",
      tags$thead(tags$tr(tags$th("Variable"), tags$th("t value"), tags$th("p-value"), tags$th("Decision"))),
      tags$tbody(rows))
  })

  output$coef_importance_plot <- renderPlot({
    req(rv$model_summary)
    coefs <- as.data.frame(rv$model_summary$coefficients); coefs$Variable <- rownames(coefs)
    coefs <- coefs[coefs$Variable != "(Intercept)", , drop = FALSE]; req(nrow(coefs) > 0)
    coefs$AbsT <- abs(coefs[, "t value"]); coefs <- coefs[order(coefs$AbsT), ]
    coefs$Variable <- factor(coefs$Variable, levels = coefs$Variable)
    ggplot(coefs, aes(x = Variable, y = AbsT, fill = AbsT)) +
      geom_col(width = 0.6, show.legend = FALSE) +
      scale_fill_gradient(low = "#660000", high = "#ff1a1a") +
      coord_flip() +
      labs(title = "Feature Importance (|t-value|)", subtitle = "Higher = more statistically significant",
        x = NULL, y = "|t-value|") + theme_premium()
  }, bg = "#080808")

  output$qq_plot <- renderPlot({
    req(rv$model); res <- residuals(rv$model)
    qq_df <- data.frame(theoretical = qqnorm(res, plot.it = FALSE)$x,
      sample = qqnorm(res, plot.it = FALSE)$y)
    ggplot(qq_df, aes(x = theoretical, y = sample)) +
      geom_point(color = "#ffffff", alpha = 0.8, size = 3) +
      geom_abline(slope = sd(res), intercept = mean(res), color = "#ff4040", linewidth = 1, linetype = "dashed") +
      labs(title = "Normal Q-Q Plot", subtitle = "Points near the line suggest normally distributed residuals",
        x = "Theoretical Quantiles", y = "Sample Quantiles") + theme_premium()
  }, bg = "#080808")

  # === INSIGHTS ===

  output$insights_panel <- renderUI({
    req(rv$model, rv$trained)
    insights <- generate_insights(rv$model, rv$data, input$y_var, input$x_vars)
    tags$div(lapply(insights, function(ins) insight_html(ins$title, ins$text, ins$type)))
  })

  output$health_score_ui <- renderUI({
    req(rv$model_summary)
    r2 <- rv$model_summary$r.squared; adj_r2 <- rv$model_summary$adj.r.squared
    se_rel <- rv$model_summary$sigma / mean(abs(rv$data[[input$y_var]]), na.rm = TRUE)
    score <- min(100, round((r2 * 40) + (adj_r2 * 30) + (max(0, 1 - se_rel) * 30)))
    color <- if(score >= 80) "#ffaa00" else if(score >= 60) "#ff6b2b" else "#ff1a1a"
    label <- if(score >= 80) "Healthy" else if(score >= 60) "Moderate" else "Needs Improvement"
    tags$div(style = "text-align:center;",
      tags$div(style = paste0("width:120px;height:120px;border-radius:50%;margin:0 auto 16px;",
        "display:flex;align-items:center;justify-content:center;flex-direction:column;",
        "border:4px solid ", color, ";box-shadow:0 0 25px ", color, "44;"),
        tags$div(style = paste0("font-size:32px;font-weight:800;color:", color,
          ";font-family:'JetBrains Mono',monospace;text-shadow:0 0 15px ", color, "66"), score),
        tags$div(style = "font-size:10px;color:#5c6b8a;text-transform:uppercase;letter-spacing:1px", "/ 100")),
      tags$div(style = paste0("font-size:14px;font-weight:600;color:", color), label))
  })

  output$quick_summary_ui <- renderUI({
    req(rv$model_summary, rv$trained); s <- rv$model_summary
    n_sig <- sum(s$coefficients[-1, 4] < 0.05); n_total <- nrow(s$coefficients) - 1
    row_style <- "display:flex;justify-content:space-between;padding:10px 0;border-bottom:1px solid rgba(255,0,60,.15)"
    tags$div(
      tags$div(style = row_style,
        tags$span(style = "color:#ffffff;font-size:14px;font-weight:500", "Observations"),
        tags$span(style = "color:#ffffff;font-weight:700;font-size:15px;font-family:'JetBrains Mono',monospace", nrow(rv$data))),
      tags$div(style = row_style,
        tags$span(style = "color:#ffffff;font-size:14px;font-weight:500", "Predictors"),
        tags$span(style = "color:#ffffff;font-weight:700;font-size:15px;font-family:'JetBrains Mono',monospace", n_total)),
      tags$div(style = row_style,
        tags$span(style = "color:#ffffff;font-size:14px;font-weight:500", "Significant (p<0.05)"),
        tags$span(style = "color:#cfa85f;font-weight:700;font-size:15px;font-family:'JetBrains Mono',monospace", paste(n_sig, "/", n_total))),
      tags$div(style = row_style,
        tags$span(style = "color:#ffffff;font-size:14px;font-weight:500", "R\u00b2"),
        tags$span(style = "color:#ffffff;font-weight:700;font-size:15px;font-family:'JetBrains Mono',monospace",
          sprintf("%.4f", s$r.squared))),
      tags$div(style = "display:flex;justify-content:space-between;padding:10px 0",
        tags$span(style = "color:#ffffff;font-size:14px;font-weight:500", "Residual SE"),
        tags$span(style = "color:#ffffff;font-weight:700;font-size:15px;font-family:'JetBrains Mono',monospace",
          sprintf("%.4f", s$sigma))))
  })

  # Force background rendering for quick texts and tables only (keeps training instant)
  opts <- c("metric_r2", "metric_adjr2", "metric_se", "metric_fstat", "ttest_table_ui", "quick_summary_ui")
  for (id in opts) {
    outputOptions(output, id, suspendWhenHidden = FALSE)
  }
}
