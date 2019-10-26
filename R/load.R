#' Loads an expression matrix
#'
#' This function loads a file as a matrix. It assumes that the first column
#' contains the rownames and the subsequent columns are the sample identifiers.
#' Any rows with duplicated row names will be dropped with the first one being
#' kepted.
#'
#' @param infile Path to the input file
#' @return A matrix of the infile
#' @export
load_exprs_mat <- function(infile){
  exprs_df <- readr::read_tsv(infile)

  if (! "gene_name" %in% colnames(exprs_df)) {
    stop("[load_exprs_mat]: Unable to find the gene_name column")
  }

  exprs_mat <- data.matrix(dplyr::select(exprs_df, -gene_name))
  rownames(exprs_mat) <- exprs_df[["gene_name"]]
  return(exprs_mat)
}
