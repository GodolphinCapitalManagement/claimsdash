## This is the server logic for a Shiny web application.
## You can find out more about building applications with Shiny here:
##
## http://shiny.rstudio.com
##


shinyServer(function(input, output, session) {
    cdata = session$clientData
    
    ## claims tab
    source(file.path("server", "claims.R"), local = TRUE)
    output$claims <- claims
})
