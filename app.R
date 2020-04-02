library(shinydashboard)
library(shinyjs)
if (!require(shinyglide))
  remotes::install_github("juba/shinyglide")

controls <- glideControls(
  list(
    shiny::actionButton("prev_screen_btn", "Next", class = "prev-screen"),
    shiny::actionButton("first_screen_btn", "First screen !", class = "btn-danger first-screen")
  ),
  list(
    shiny::actionButton("next_screen_btn", "Next", class = "next-screen"),
    shiny::actionButton("last_screen_btn", "Last screen...",
                        class = "btn-success last-screen", icon = icon("ok", lib = "glyphicon"))
  )
)


screens <- list(
  shinyglide::screen(
    p("Please choose a value for n :"),
    numericInput("n", "n :", value = 100)
  ),
  shinyglide::screen(
    p("Here is your plot :"),
    plotOutput("plot")
  ),
  shinyglide::screen(
    p("3rd screen")
  )
)


top_buttons <- list(actionButton("scr1", "Screen 1"), actionButton("scr2", "Screen 2"), actionButton("scr3", "Screen 3"))

for (i in 1:length(screens)) {
  screens[[i]]$attribs$id <- paste0("screen_", i)
  top_buttons[[i]]$attribs$onclick <- "function() {console.log('>>>>>');}"
}

screens$custom_controls <- controls
screens$id <- "glider"

jsCode <- "shinyjs.activeScreen = function(params) {
            Shiny.setInputValue('activeScreen', $('.glide__slide.glide__slide--active').attr('id'));
          }

          shinyjs.trigger = function() {
            console.log('<<<<');
            $('#glider').trigger('custom');
          }"


ui <- dashboardPage(
  dashboardHeader(title = "Example shinyglide app"),
  dashboardSidebar(
    sidebarMenu(
      id = "main_menu",
      menuItem("Welcome Page", tabName = "welcome_page"),
      menuItem("Menu 1", tabName = "menu1"),
      menuItem("Menu 2", tabName = "menu2"),
      menuItem("Menu 3", tabName = "menu3")
    )
  ),
  dashboardBody(
    tags$head(
      shinyjs::useShinyjs(),
      shinyjs::extendShinyjs(text = jsCode, functions = c("activeScreen", "trigger")),
      # tags$script(HTML(
      #   '$( "#glider" ).on( "custom", function() {
      #     console.log(">>>>");
      #     console.log("id: " + $("#glider > .glide__track > .glide__slides").find("li.glide__slide--active").attr("id"));
      #   });'
      # )),
      # tags$script(src= "trigger.js")
      includeScript(path = "www/trigger.js")
    ),
    tabItems(
      tabItem(
        tabName = "welcome_page",
        box(width = 12,
              top_buttons
        ),
        box(width = 12,
            do.call(shinyglide::glide, screens)
        )
      ),
      tabItem(
        tabName = "menu1",
      ),
      tabItem(
        tabName = "menu2",
      ),
      tabItem(
        tabName = "menu3",
      )
    )
  )
)

server <- function(input, output, session) {
  output$plot <- renderPlot({
    print(">>>>>> rendering plot")
    hist(rnorm(input$n), main = paste("n =", input$n))
  })
  observeEvent(list(input$next_screen_btn, input$prev_screen_btn), {
    print(">>>>>> clicked next button")
    js$trigger()
  })
  observeEvent(input$activeScreen, {
    print(sprintf("active screen: %s", input$activeScreen))
  })
}

shinyApp(ui = ui, server = server)
