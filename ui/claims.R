tabPanel(
  "Claims",
  fluidRow(
    column(width = 12,
           wellPanel(
             highchartOutput("claims")
           )
    )
  )
)
