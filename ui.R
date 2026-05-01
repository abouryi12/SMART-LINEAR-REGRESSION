# ============================================
# SMART REGRESSION & DATA INSIGHT SYSTEM
# ui.R - User Interface
# ============================================

ui <- fluidPage(
  tags$head(
    tags$link(rel = "icon", href = "beta_regression_icon.svg", type = "image/svg+xml"),
    tags$link(rel = "stylesheet", href = "styles.css?v=5"),
    tags$title("Smart Regression System")
  ),

  # Background
  tags$div(class = "bg-pattern"),
  # Header
  tags$div(class = "hero-header",
    tags$div(class = "bg-watermark", "REGRESSION"),
    tags$div(class = "hero-title",
      tags$span(class = "text-white", "SMART"),
      tags$span(class = "text-red", "LINEAR"),
      tags$span(class = "text-outline", "REGRESSION")
    )
  ),
  # Main Content
  tags$div(class = "main-container",
    tabsetPanel(id = "mainTabs", type = "tabs",

      # TAB 1: DATA INPUT
      tabPanel(title = "Data Input", value = "tab_data",
        tags$br(),
        fluidRow(
          column(4,
            tags$div(class = "card",
              tags$div(class = "card-title",
                tags$span(class = "icon icon-blue", "IN"), "Data Source"
              ),
              radioButtons("data_source", "How do you want to load data?",
                choices = c("Upload CSV" = "csv", "Manual Entry" = "manual"),
                selected = "csv"
              ),
              hr(),
              conditionalPanel(
                condition = "input.data_source == 'csv'",
                tags$div(class = "custom-dropzone",
                  fileInput("file_upload", NULL,
                    buttonLabel = "Browse Files",
                    placeholder = "",
                    accept = c("text/csv", ".csv")
                  ),
                  tags$div(class = "dropzone-hint",
                    tags$span(style = "font-size:28px;", "\U0001F4C2"),
                    tags$span("Click here or Drag & Drop your CSV file")
                  )
                ),
                checkboxInput("header", "First row is header", TRUE),
                radioButtons("sep", "Separator",
                  choices = c(Comma = ",", Semicolon = ";", Tab = "\t"),
                  selected = ",", inline = TRUE
                )
              ),
              conditionalPanel(
                condition = "input.data_source == 'manual'",
                tags$p(style = "color:#a0aabf;font-size:12px;margin-bottom:12px",
                  "Enter values separated by spaces or Enter. You can add multiple X variables for Multiple Regression!"
                ),
                tags$style("
                  textarea { font-family: 'JetBrains Mono', monospace !important; font-size: 16px !important; font-weight: 700 !important; text-align: center !important; letter-spacing: 1px; }
                  .manual-boxes .form-group { margin-bottom: 0 !important; }
                  .manual-boxes label { display: block !important; text-align: center !important; width: 100% !important; font-size: 14px !important; color: #fff !important; }
                "),
                tags$div(class = "manual-boxes", style = "display: flex; gap: 15px; overflow-x: auto; padding-bottom: 10px;",
                  uiOutput("manual_x_inputs", style = "display: flex; gap: 15px;"),
                  textAreaInput("manual_y", "Y", value = "2.1\n4.0\n5.8\n8.2\n9.8", rows = 5, width = "75px")
                ),
                fluidRow(
                  column(6, actionButton("add_x_btn", "+ Add X", class = "btn-secondary", style = "width:100%;margin-bottom:12px")),
                  column(6, actionButton("remove_x_btn", "- Remove X", class = "btn-secondary", style = "width:100%;margin-bottom:12px"))
                ),
                actionButton("apply_manual", "Apply Manual Data", class = "btn-primary", style = "width:100%")
              )
            )
          ),
          column(8,
            tags$div(class = "card",
              tags$div(class = "card-title",
                tags$span(class = "icon icon-green", "DT"), "Dataset Preview"
              ),
              uiOutput("data_info_badges"),
              tags$br(),
              DT::dataTableOutput("data_table")
            )
          )
        )
      ),

      # TAB 2: MODEL TRAINING
      tabPanel(title = "Model Training", value = "tab_config",
        tags$br(),
        fluidRow(
          column(4,
            tags$div(class = "card",
              tags$div(class = "card-title",
                tags$span(class = "icon icon-blue", "XY"), "Variable Selection"
              ),
              uiOutput("y_var_ui"),
              uiOutput("x_vars_ui"),
              hr(),
              tags$div(class = "card-title",
                tags$span(class = "icon icon-cyan", "LM"), "Model Type"
              ),
              uiOutput("model_type_display"),
              hr(),
              actionButton("train_model", "Train Model",
                class = "btn-primary btn-run",
                style = "width:100%;font-size:14px!important;padding:14px!important"
              )
            ),
            tags$div(class = "card",
              tags$div(class = "card-title",
                tags$span(class = "icon icon-green", "VI"), "Variable Info"
              ),
              uiOutput("var_info_panel")
            )
          ),
          column(8,
            tags$div(class = "card",
              tags$div(class = "card-title",
                tags$span(class = "icon icon-purple", "FX"), "Model Formula"
              ),
              verbatimTextOutput("formula_display")
            ),
            tags$div(class = "card",
              tags$div(class = "card-title",
                tags$span(class = "icon icon-orange", "CT"), "Coefficient Table"
              ),
              uiOutput("coef_table_ui")
            ),
            tags$div(class = "card",
              tags$div(class = "card-title",
                tags$span(class = "icon icon-blue", "SM"), "Model Summary"
              ),
              verbatimTextOutput("model_summary")
            )
          )
        )
      ),

      # TAB 3: EVALUATION
      tabPanel(title = "Evaluation", value = "tab_eval",
        tags$br(),
        tags$div(class = "grid-4", id = "metrics_grid",
          uiOutput("metric_r2"),
          uiOutput("metric_adjr2"),
          uiOutput("metric_se"),
          uiOutput("metric_fstat")
        ),
        tags$br(),
        fluidRow(
          column(12,
            tags$div(class = "card",
              tags$div(class = "card-title",
                tags$span(class = "icon icon-blue", "TT"), "T-Test: Coefficient Significance"
              ),
              uiOutput("ttest_table_ui")
            )
          )
        ),
        fluidRow(
          column(6,
            tags$div(class = "plot-container",
              tags$div(class = "card-title",
                tags$span(class = "icon icon-purple", "CI"), "Coefficient Importance"
              ),
              plotOutput("coef_importance_plot", height = "350px")
            )
          ),
          column(6,
            tags$div(class = "plot-container",
              tags$div(class = "card-title",
                tags$span(class = "icon icon-cyan", "QQ"), "Q-Q Plot (Normality Check)"
              ),
              plotOutput("qq_plot", height = "350px")
            )
          )
        )
      ),

      # TAB 4: VISUALIZATION
      tabPanel(title = "Visualization", value = "tab_viz",
        tags$br(),
        fluidRow(
          column(6,
            tags$div(class = "plot-container",
              tags$div(class = "card-title",
                tags$span(class = "icon icon-blue", "SC"), "Scatter Plot with Regression Line"
              ),
              plotOutput("scatter_plot", height = "400px")
            )
          ),
          column(6,
            tags$div(class = "plot-container",
              tags$div(class = "card-title",
                tags$span(class = "icon icon-green", "AP"), "Actual vs Predicted"
              ),
              plotOutput("actual_vs_pred", height = "400px")
            )
          )
        ),
        tags$br(),
        fluidRow(
          column(6,
            tags$div(class = "plot-container",
              tags$div(class = "card-title",
                tags$span(class = "icon icon-purple", "RF"), "Residuals vs Fitted"
              ),
              plotOutput("residual_plot", height = "400px")
            )
          ),
          column(6,
            tags$div(class = "plot-container",
              tags$div(class = "card-title",
                tags$span(class = "icon icon-orange", "RD"), "Residual Distribution"
              ),
              plotOutput("residual_hist", height = "400px")
            )
          )
        )
      ),

      # TAB 5: INSIGHTS
      tabPanel(title = "AI Insights", value = "tab_insights",
        tags$br(),
        fluidRow(
          column(8,
            tags$div(class = "card",
              tags$div(class = "card-title",
                tags$span(class = "icon icon-purple", "AI"), "Intelligent Analysis Report"
              ),
              tags$p(style = "color:#ffffff;font-size:14px;font-weight:600;margin-bottom:20px;background:rgba(255,26,26,0.1);padding:10px;border-radius:4px;border-left:3px solid #ff1a1a;",
                "Auto-generated insights based on your trained model. Train a model first to see results."
              ),
              uiOutput("insights_panel")
            )
          ),
          column(4,
            tags$div(class = "card",
              tags$div(class = "card-title",
                tags$span(class = "icon icon-green", "HS"), "Model Health Score"
              ),
              uiOutput("health_score_ui")
            ),
            tags$div(class = "card",
              tags$div(class = "card-title",
                tags$span(class = "icon icon-orange", "QS"), "Quick Summary"
              ),
              uiOutput("quick_summary_ui")
            )
          )
        )
      )
    )
  ),

  tags$script(src = "custom.js")
)
