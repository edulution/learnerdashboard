fluidPage(
  shinyFeedback::useShinyFeedback(),
  tags$head(includeHTML(("google_analytics.html"))),
  tags$link(
    rel="shortcut icon",
    href = "https://storage.googleapis.com/inventory_static_files/favicon.png"),
  theme = shinytheme("flatly"),
  sidebarLayout(
    sidebarPanel(
      textInput("username","Please enter your Username: "),
      actionButton("show_stats_btn", "Show Progress"),
      br(),
      br(),
      h3(textOutput("full_name")),
      br(),
      h6(textOutput("disclaimer"))
    ),
    mainPanel(
      tabsetPanel(
        tabPanel(
          "Time Spent",
          withSpinner(plotOutput("time_plot")),
          br(),
          br(),
          withSpinner(plotOutput("time_prop_pieplot"))
        ),        
        tabPanel(
          "Progress",
          withSpinner(plotOutput("progress_plot"))
        ),
        tabPanel(
          "Baseline Tests",
          withSpinner(DT::DTOutput("tests_table"))
        )
      )
    )
  )
)
