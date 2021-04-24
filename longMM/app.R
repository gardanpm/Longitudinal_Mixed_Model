## app.R ##

# Library
library(shiny)
library(shinydashboard)
library(shinythemes)
library(tidyverse)
library(DT)
library(lme4)
library(jsonlite)
load('models1.Rdata')
load('models2.Rdata')


# UI function
ui <- dashboardPage( skin = "blue",
                     dashboardHeader(title = "Mixed Models for Longitudinal Data", titleWidth =350),
                     dashboardSidebar(
                         sidebarMenu(
                             id = "tabs",
                             
                             menuItem("Background", tabName="Background", 
                                      icon = icon("Background")),
                             
                             menuItem("CHNS Example", icon = icon("th"), tabName = "Example"),
                             
                             menuItem("Bonus", icon = icon("th"),
                                      tabName = "Bonus")
                             
                         ),
                         textOutput("res")
                     ),
                     dashboardBody(
                         tags$head(
                             tags$style(HTML('#do{background-color:blue}',
                                             '#do{border-color:blue}',
                                             '#do{color: #ffffff}',
                                             '#do2{background-color:blue}',
                                             '#do2{border-color:blue}',
                                             '#do2{color: #ffffff}',
                                             '#do3{background-color:blue}',
                                             '#do3{border-color:blue}',
                                             '#do3{color: #ffffff}'))
                         ),
                         
                         tags$style(HTML("
                    .dataTables_wrapper .dataTables_length, .dataTables_wrapper .dataTables_filter, .dataTables_wrapper .dataTables_info, .dataTables_wrapper .dataTables_processing, .dataTables_wrapper .dataTables_paginate {
                    color: #000000;
                    }

                    thead {
                    color: #000000;
                    }

                     tbody {
                    color: #000000;
                    }

                   "
                                         
                                         
                         )),
                         
                         tabItems(
                             # Intro tab
                             tabItem(tabName = "Background",
                                     includeHTML("Introduction.html")),
                             
                             #   #     #     #     #     #     #     #     #     #     #       #      
                             # Example tab
                             tabItem(tabName ="Example",
                                     includeHTML("Example1.html"),
                                     h2(""),
                                     div(align = "center", radioButtons(
                                         inputId = "samp1",
                                         label = h4("Visualize Predictions:"),
                                         choices = c("Overall Trend",
                                                     "Randomly selected HH"),
                                         selected = "Overall Trend")),
                                     div(align = "center", actionButton(
                                         inputId = "search",
                                         label   = strong("Go!"))),
                                     h6("Keep clicking after selecting 'Randomly selected HH' to see different households. The overall trend might take a few second to appear."),
                                     div(align = "center", plotOutput(outputId = "plot1", 
                                                                      width = "60%")),
                                     includeHTML("Example2.html"),
                                     div(align = "center", 
                                         h4("Visualize Predictions:")),
                                     div(align = "center", actionButton(
                                         inputId = "search2",
                                         label   = strong("Go!"))),
                                     h6("Keep clicking after selecting 'Randomly selected HH' to see different households"),
                                     div(align = "center", plotOutput(outputId = "plot2",
                                                                      width = "60%"))),
                             
                             #   #     #     #     #     #     #     #     #     #     #       #    
                             
                             # Bonus tab
                             tabItem(tabName ="Bonus",
                                     includeHTML("Bonus.html"))
                             
                             
                         )
                     )
)
#   #   #   #   #   #   #   #   #   #   #   #   #   #   #   #   #   #   #   #   #   

server <- function(input, output) {
    
    head_data = eventReactive(input$search,
                              {
                                  if(input$samp1 == "Randomly selected HH"){
                                      samp <- sashhinc %>% group_by(hhid) %>%
                                          dplyr::summarize(n=n()) %>%
                                          dplyr::filter(n>5) %>% 
                                          dplyr::select(hhid) %>%
                                          unlist() %>% sample(.,1)
                                      to_plot <- sashhinc %>% dplyr::filter(hhid==samp) %>%
                                          dplyr::select(thousands_croot, cyear, hhid)
                                      predicted <- predict(fit.1,to_plot[,2:3])
                                      return(cbind(to_plot, predicted))}
                                  
                                  else{NULL}
                              })
    
    output$plot1 = renderPlot({
        if (is.null(head_data())){
            ggplot(data=sashhinc, aes(x=cyear,y=thousands_croot,group=hhid)) +
                ylim(-10,13) + 
                geom_point(alpha=0.05) +
                geom_line(alpha=0.1) +
                geom_abline(data=sashhinc, aes(intercept=sum1$coefficients[[1]],
                                               slope=sum1$coefficients[[2]]),
                            col="green") +
                xlab("Years Since 1989") + 
                ylab("Cube Root of Income (thousands of yuan)") + 
                ggtitle("CHNS Household Income by Year", 
                        "The green line represents the prediction of the model for a new household")
        }
        else{
            ggplot(data=head_data(), aes(x=cyear, y=predicted)) +
                ylim(-10,13) + 
                geom_line(colour="green") +
                geom_point(data=head_data(), aes(x=cyear,y=thousands_croot)) +
                xlab("Years Since 1989") +
                ylab("Cube Root of Income (thousands of yuan)") + 
                ggtitle("CHNS Household Income by Year & Estimation of our Model",
                        paste0("For household ", head_data()$hhid))
        }
    })
    
    #######################################################################
    
    head_data2 = eventReactive(input$search2,
                               {
                                   samp2 <- sashhinc %>% group_by(hhid) %>%
                                       dplyr::summarize(n=n()) %>%
                                       dplyr::filter(n>5) %>% 
                                       dplyr::select(hhid) %>%
                                       unlist() %>% sample(.,1)
                                   to_plot2 <- sashhinc %>% filter(hhid==samp2) %>%
                                       dplyr::select(thousands_croot, cyear, hhid,
                                              area_urban, Prov_2)
                                   predicted1 <- predict(fit.1,to_plot2[,2:3])
                                   predicted2 <- predict(fit.10,to_plot2[,2:5])
                                   to_plot2 <- cbind(to_plot2, predicted1)
                                   return(cbind(to_plot2, predicted2))
                               })
    
    output$plot2 = renderPlot({
        ggplot(data=head_data2(), aes(x=cyear, y=predicted1)) +
            ylim(-10,13) + 
            geom_line(colour="green") +
            geom_point(data=head_data2(), aes(x=cyear,y=thousands_croot)) +
            geom_line(aes(x=cyear, y=predicted2),colour="red") +
            xlab("Years Since 1989") +
            ylab("Cube Root of Income (thousands of yuan)") + 
            ggtitle("CHNS Household Income by Year & Estimation of our Models",
                    paste0("For household ", head_data()$hhid))
    })
    
}

# Calling Shiny App
shinyApp(ui, server)