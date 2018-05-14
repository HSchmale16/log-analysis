# Log Stats Viewer
# Allows user to interactively browse the results of a log parse.
# Henry J Schmale

library(shiny)
library(dplyr)
library(ggplot2)
library(lubridate)

articleViews <- read.csv('../articleViews.csv', header = FALSE)
colnames(articleViews) <- c('path', 'date', 'hits')
articleViews$date <- as.Date(articleViews$date)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Log Analysis"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         sliderInput("range",
                     "Date Range:",
                     min = min(articleViews$date),
                     max = max(articleViews$date),
                     value = c(min(articleViews$date), max(articleViews$date))),
         selectInput("group_by_ts",
                     "Group By Time Unit:",
                     c("day", "week", "month"))
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("plot"),
         verbatimTextOutput('text')
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
   output$plot <- renderPlot({
      rng <- input$range
      
      x <- filter(articleViews, date >= rng[1], date <= rng[2]) %>%
        group_by(path, date = floor_date(date, input$group_by_ts)) %>%
        summarise(hits = sum(hits))
      
      ggplot(x, aes(x = path, y = date, fill = hits)) +
        geom_tile() +
        coord_flip()
   })
   
   output$text <- renderText({
     input$group_by_ts
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

