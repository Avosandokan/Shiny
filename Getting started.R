# RESOURCE https://mastering-shiny.org/preface.html


# Shiny is an R package that allows you to easily create rich, interactive web apps. 
# Shiny allows you to take your work in R and expose it via a web browser so that anyone can use it. 


# These are some of the basic packages that you need for running a Shiny App
install.packages(c(
  "gapminder", "ggforce", "gh", "globals", "openintro", "profvis", 
  "RSQLite", "shiny", "shinycssloaders", "shinyFeedback", 
  "shinythemes", "testthat", "thematic", "tidyverse", "vroom", 
  "waiter", "xml2", "zeallot" ))

# The goal of the next four chapters is to get you writing Shiny apps as quickly as possible. 
# In Chapter 1, I’ll start small, but complete, showing you all the major pieces of an app and how they fit together. 
# Then in Chapters 2 and 3 you’ll start to get into the details of the two major parts of a Shiny app: the frontend (what the user sees in the browser) 
# and the backend (the code that makes it all work). 
# We’ll finish up in Chapter 4 with a case study to help cement the concepts you’ve learned so far.


##############################################################################################################
# CHAPTER 1
################################################################################################################

# I’ll start by showing you the minimum boilerplate needed for a Shiny app..
# Next you’ll learn the two key components of every Shiny app: the UI, and the server function. 
# Shiny uses reactive programming to automatically update outputs when inputs change: reactive expressions.

install.packages("shiny")
# check that you have version 1.5.0 or greater.
library(shiny)
# Create a new directory and an app.R file containing a basic app in one step by clicking File | New Project, then selecting New Directory and Shiny Web Application.



# 1.2 APP DIRECTORY AND FILE ####
# There are several ways to create a Shiny app. The simplest is to create a new directory for your app, and put a single file called app.R in it. 
# This app.R file will be used to tell Shiny both how your app should look, and how it should behave.

ui <- fluidPage( "Hello, world!")
    # It defines the user interface, the HTML webpage that humans interact with(containing the words “Hello, world!”)
server <- function(input, output, session) {}
        # It specifies the behaviour of our app by defining a server function. It’s currently empty, so our app doesn’t do anything
shinyApp(ui, server)
 #executes shinyApp(ui, server) to construct and start a Shiny application from UI and server.




# 1.3 UI CONTROLS #####

#  We’re going to make a very simple app that shows you all the built-in data frames included in the datasets package.
# Replace your ui with this code:
  
  ui <- fluidPage( 
       # fluidPage() is a layout function that sets up the basic visual structure of the page
    selectInput("dataset", label = "Dataset", choices = ls("package:datasets")),
       # selectInput() is an input control that lets the user interact with the app by providing a value
       # verbatimTextOutput() and tableOutput() are output controls that tell Shiny where to put rendered output
    verbatimTextOutput("summary"), # verbatimTextOutput() displays code
    tableOutput("table")) #  tableOutput() displays tables
  server <- function(input, output, session) {}
  shinyApp(ui, server)
  # We only see the input, not the two outputs, because we haven’t yet told Shiny how the input and outputs are related.
  
  
  
  
  # 1.4 ADDING BEHAVIOUR ######
  
  # Shiny uses reactive programming to make apps interactive.  
  # just be aware that it involves telling Shiny how to perform a computation, not ordering Shiny to actually go do it.
  
  # We’ll tell Shiny to output two commands in this case. 1) A summary of the data selected; 2) a table of the data
  server <- function(input, output, session) {
   # 1) first output, a summary
    output$summary <-  # each "output$" suggests a render function to produce the desired output(text,table,plot,etc...) 
      renderPrint({ #and is followed by a render {} function
      dataset <- get(input$dataset, "package:datasets")
      summary(dataset)
    })
    #2 ) second output, a table
    output$table <- renderTable({
      dataset <- get(input$dataset, "package:datasets")
      # renderTable() is paired with tableOutput() to show the input data in a table.
      dataset
    })
  }
  
  
# Run it all together to ensure the output is correct
  ui <- fluidPage( selectInput("dataset", label = "Dataset", choices = ls("package:datasets")),
                   verbatimTextOutput("summary"), # verbatimTextOutput() displays code
                   tableOutput("table")) #  tableOutput() displays tables
  
  server <- function(input, output, session) {
    output$summary <-  # each "output$" suggests a render function to produce the desired output(text,table,plot,etc...) 
      renderPrint({ #and is followed by a render {} function
        dataset <- get(input$dataset, "package:datasets")
        summary(dataset) })
    
    output$table <- renderTable({
      dataset <- get(input$dataset, "package:datasets")
      # renderTable() is paired with tableOutput() to show the input data in a table.
      dataset})}
  
  shinyApp(ui, server)
  
  
  # 1.5 REDUCE DUPLICATION #######
  #  we have some code that’s duplicated: the following line is present in both outputs.
  # dataset <- get(input$dataset, "package:datasets")
  # it’s poor practice to have duplicated code. The app behaves identically, but works a little more efficiently
  
  # create a reactive expression by wrapping a block of code in reactive({...}) and assigning it to a variable
  ui <- fluidPage( selectInput("dataset", label = "Dataset", choices = ls("package:datasets")),
                   verbatimTextOutput("summary"),
                   tableOutput("table"))
  
  server <- function(input, output, session) {
    # Create a reactive expression
    dataset <- reactive({ get(input$dataset, "package:datasets")})
    
    output$summary <- renderPrint({
      # Use a reactive expression by calling it like a function
      summary(dataset()) })
    
    output$table <- renderTable({dataset()}) }
  
  shinyApp(ui, server)
  
  
  
  # 1.6  EXERCISE ########
  # 1) Create an app that greets the user by name and by age
 ui <- fluidPage(
    textInput("name", "What's your name?"), 
    textOutput("greeting"),
    
    numericInput("age", "How old are you?", value = NA),
    textOutput("congrats"))
 
 server <- function(input, output, session) {
   output$greeting <- renderText({
     paste0("Hello ", input$name) })
 
 output$congrats <- renderText({paste0(input$age, "years young!")})}
   
 shinyApp(ui, server)
 
  
 # 2) Suppose your friend wants to design an app that allows the user to set a number (x) between 1 and 50, 
 ui <- fluidPage(
   sliderInput("x", label = "If x is", min = 1, max = 50, value = 30),
   "then x times 5 is",
   textOutput("product"))
 
 server <- function(input, output, session) {
   output$product <- renderText({input$x * 5 })}
 
 shinyApp(ui, server)
 
 
 # 3) Extend the app from the previous exercise to allow the user to set the value of the multiplier, y, so that the app yields the value of x * y.
 ui <- fluidPage(
   sliderInput("x", label = "If x is", min = 1, max = 50, value = 30), 
   textOutput("product"),
   
   sliderInput("y", label = "and y is", min = 1, max = 50, value = 30), 
   "then, x times y is", 
   textOutput("product"))
 
 server <- function(input, output, session) {
   output$product <- renderText({input$x * input$y })}
 
 shinyApp(ui, server)
 
 
 # 4) Take the following app which adds some additional functionality to the last app described in the last exercise. 
 # What’s new? How could you reduce the amount of duplicated code in the app by using a reactive expression.

 ui <- fluidPage(
   sliderInput("x", "If x is", min = 1, max = 50, value = 30),
   sliderInput("y", "and y is", min = 1, max = 50, value = 5),
   "then, (x * y) is", textOutput("product"),
   "and, (x * y) + 5 is", textOutput("product_plus5"),
   "and (x * y) + 10 is", textOutput("product_plus10"))
 
 server <- function(input, output, session) {
   product <- reactive({input$x * input$y})
   output$product <- renderText({ 
     product() # after every reactive object you need to close with ()! other wise it will porduce an error
   })
   output$product_plus5 <- renderText({ 
     product() + 5
   })
   output$product_plus10 <- renderText({ 
     product() + 10
   })
 }
 
 shinyApp(ui, server)
 
 
 # 5)Select a dataset from a package (this time we’re using the ggplot2 package) and the app prints out a summary and plot of the data. 
 # It also follows good practice and makes use of reactive expressions to avoid redundancy of code. 
 # However there are three bugs in the code provided below. Can you find and fix them?
 
 
 # Original code 
 library(shiny)
 library(ggplot2)
 
 datasets <- c("economics", "faithfuld", "seals")
 ui <- fluidPage(
   selectInput("dataset", "Dataset", choices = datasets),
   verbatimTextOutput("summary"),
   tableOutput("plot")
 )
 
 server <- function(input, output, session) {
   dataset <- reactive({
     get(input$dataset, "package:ggplot2")
   })
   output$summmry <- renderPrint({
     summary(dataset())
   })
   output$plot <- renderPlot({
     plot(dataset)
   }, res = 96)
 }
 
 shinyApp(ui, server)
 
 
 
 # corrected code

 datasets <- c("economics", "faithfuld", "seals")
 ui <- fluidPage(
   selectInput("datasets", "Dataset", # assign the dataset into the UI element called "Dataset"
               choices = datasets), # select the choices from the datasets list
   verbatimTextOutput("summary"),
   plotOutput("plot"))
 
 server <- function(input, output, session) {
   dataset <- reactive({ get(input$datasets, "package:ggplot2")
   })
   output$summary <- renderPrint({
     summary(dataset())
   })
   output$plot <- renderPlot({
     plot(dataset())
   }, res = 96)
 }
 
 shinyApp(ui, server) 
 