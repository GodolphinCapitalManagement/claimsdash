
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

shinyUI(
  fluidPage(theme = shinythemes::shinytheme('united'),
            tags$head(tags$style(
              HTML('#sidebar {padding: 9px; max-width: 265px;}')
            )),
    headerPanel(title="", windowTitle = "Initial Claims"),
    sidebarLayout(
      sidebarPanel(id = "sidebar",
        selectInput("state", "State:",
                    choices = c("US", states),
                    selected = "US", width = '180px'),
        hr(),
        includeHTML("disclaimer.html"),
        width = 2),
      mainPanel(
        tabsetPanel(type = 'tabs',
                    ## Claims Tab
                    source(file.path("ui", "claims.R"), local = TRUE)$value
        ), # tabsetPanel
        width = 10) #mainPanel
    ) #sidebarLayout
  ) #fluidPage
) #shinyUI
