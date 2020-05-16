claims <- renderHighchart({
    ## generate Nelson-Aalen hazards

    res = project_claims(input$state, 1.0, sum_df, epi_enc, trace, F)
    last_date = res[[2]]
    st_df = data.table(res[[1]])

    do_highcharter(st_df, last_date)
})

do_highcharter <- function(st_df, last_date) {
    do_series(st_df, last_date)
}

do_series <- function(st_df, last_date) {
    
    aaa <- st_df[, c("obsdate", "5th", "50th", "95th"), with=FALSE]
    aaa[, obsdate := as.Date(obsdate)]
    colnames(aaa) <- c("obsdate", "lower", "median", "upper")
    ymax = max(aaa[, upper])
    
    chart_title = paste0("Weekly Claims: ")
    chart_subtitle = paste0("Data as of: ",  last_date)
    
    x <- c("Min: ", "Mean: ", "Max: ")
    y <- sprintf("{point.%s: .0f}", c("lower", "median", "upper"))
    tltip <- tooltip_table(x, y)
    
    hchart(aaa, type = "columnrange",
           hcaes(x = obsdate, low = lower, high = upper, color = median)) %>% 
        hc_yAxis(title=list(text="Weekly claims"),
                 tickPositions = seq(0, ymax, 5.0e5),
            gridLineColor = "#B71C1C",
            labels = list(format = "{value}", useHTML = TRUE)) %>% 
        hc_tooltip(
            useHTML = TRUE,
            headerFormat = as.character(tags$small("{point.x: %B %d, %Y}")),
            pointFormat = tltip
        ) %>% 
        hc_xAxis(title=list(text="Date")) %>%
        hc_add_theme(hc_theme_ft()) %>%
        hc_title(text = chart_title) %>%
        hc_subtitle(text = chart_subtitle)
}
    
