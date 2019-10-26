
#' Get the RHL30 Model Coefficients
#'
#' Return the RHL30 model coefficients as a data frame
#'
#' @export
#' @return Data frame of the RHL30 coefficients
get_RHL30_model_coef_df <- function() {
  structure(
    list(
      gene_name = 
        c(
          "ABCA3", "ABCG1", "APOE", "BACH2", "CCL20", "CR2", "CSF1", "CX3CL1", 
          "GCS", "IGSF3", "IL13RA1", "IL3RA", "LGMN", "NGK2D", "RNF144B", 
          "SDC4", "SOD2", "TNFSF9"
        ), 
      coefficient = 
        c(
          0.118514252096935, 0.00678524312415628, 0.0977608756988918, 
          -0.0970736660718595, 0.0601204445696382, -0.0301980923909464,
          0.282480739676071, 0.0651576842789112, 0.152117325885877, 
          0.0543152852731469, 0.0644693169147704, 0.0458709339799457, 
          0.0748446274704466, -0.000636062087683578, 0.104732223627018, 
          0.12175967271576, 0.0484320148407741, 0.213505755430869
        )
    ), 
    row.names = c(NA, -18L), 
    class = c("tbl_df", "tbl", "data.frame")
  )
}
