# Make sure to instakll debrowser and viafoundry to run this shiny example
# install.packages("viafoundry")
# if (!require("BiocManager", quietly = TRUE))
#   install.packages("BiocManager")
# BiocManager::install("debrowser")

library(debrowser)
library(viafoundry)

options(warn=-1)
header <- dashboardHeader(
  title = "Heatmap"
)
sidebar <- dashboardSidebar(  getJSLine(), sidebarMenu(id="DataAssessment",
                                                       menuItem("Heatmap", tabName = "Heatmap"),
                                                       plotSizeMarginsUI("heatmap"),
                                                       heatmapControlsUI("heatmap")))
body <- dashboardBody(
  tabItems(
    tabItem(tabName="Heatmap",  getHeatmapUI("heatmap"),
            column(4,
                   verbatimTextOutput("heatmap_hover"),
                   verbatimTextOutput("heatmap_selected")
            )
    )
  ))

ui <- dashboardPage(header, sidebar, body, skin = "blue")

server <- function(input, output, session) {
  selected <- reactiveVal()
  
  ######## Fetch the Report Data #########
  reportID <- 1
  report <- fetchReportData(reportID)
  rsem_data <- loadFile(report, "RSEM_module", "genes_expression_expected_count.tsv")
  data<-rsem_data
  rownames(data) <- data$gene
  dat <- data[rowSums(data[,3:8])>10, 3:8]
  ########################################
  
  
  observe({
    withProgress(message = 'Creating plot', style = "notification", value = 0.1, {
      selected(callModule(debrowserheatmap, "heatmap", dat))
    })
  })
  output$heatmap_hover <- renderPrint({
    if (!is.null(selected()) && !is.null(selected()$shgClicked()) && 
        selected()$shgClicked() != "")
      return(paste0("Clicked: ",selected()$shgClicked()))
    else
      return(paste0("Hovered:", selected()$shg()))
  })
  output$heatmap_selected <- renderPrint({
    if (!is.null(selected()))
      selected()$selGenes()
  })
}

shinyApp(ui, server)