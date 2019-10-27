
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RHL30

An R Package for the RHL30 prognostic predictor in relapsed Hodgkin
lymphoma (RHL) samples. The predictor was published at:

Chan, F. C. et al. Prognostic Model to Predict Post-Autologous Stem-Cell
Transplantation Outcomes in Classical Hodgkin Lymphoma. J Clin Oncol
JCO2017727925 (2017) <doi:10.1200/JCO.2017.72.7925>.

# How to Install

To install this package, you need to first have the package `devtools`
installed, then you run:

``` r
devtools::install_github("tinyheero/RHL30")
```

# How to use

We will be use the BCCA RHL cohort (n=68) from the paper as an example
of how to generate RHL30 predictor score. The following steps will
reproduce the RHL30 scores from the paper.

First, let’s load the RHL30 package and the RHL30 model:

``` r
library("RHL30")
library("dplyr")
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
rhl30_model_df <- get_rhl30_model_coef_df()
rhl30_model_df
#> # A tibble: 30 x 4
#>    gene_name refseq_mrna_id gene_type   coefficient
#>    <chr>     <chr>          <chr>             <dbl>
#>  1 ACTB      NM_001101.2    housekeeper          NA
#>  2 ALAS1     NM_000688.4    housekeeper          NA
#>  3 CLTC      NM_004859.2    housekeeper          NA
#>  4 GAPDH     NM_002046.3    housekeeper          NA
#>  5 GUSB      NM_000181.1    housekeeper          NA
#>  6 PGK1      NM_000291.2    housekeeper          NA
#>  7 POLR2A    NM_000937.2    housekeeper          NA
#>  8 RPL19     NM_000981.3    housekeeper          NA
#>  9 RPLP0     NM_001002.3    housekeeper          NA
#> 10 SDHA      NM_004168.1    housekeeper          NA
#> # … with 20 more rows
```

The model contains a total of 30 genes:

  - 18 genes that make the model
  - 12 housekeeper genes that are used to normalize the data

Let’s load the expression data of the BCCA RHL cohort that is provided
as part of this package.

``` r
hk_genes <- 
  filter(rhl30_model_df, gene_type == "housekeeper") %>%
  pull("gene_name")

exprs_file <- 
  system.file("extdata", "bcca_rhl_rhl30_gene_exprs_mat.tsv", package = "RHL30")
exprs_mat <- load_exprs_mat(exprs_file)
#> Parsed with column specification:
#> cols(
#>   .default = col_double(),
#>   gene_name = col_character()
#> )
#> See spec(...) for full column specifications.
dim(exprs_mat)
#> [1] 30 68
```

The expression data contains the 30 genes (rows) and 68 samples
(columns). Next we calculate the normalizer values for each sample:

``` r
sample_normalizer_values <- get_sample_normalizer_value(exprs_mat, hk_genes)
#> [get_normalizer]: Generating the geometric mean of housekeeper genes
```

In the paper, a threshold of 35 was set to exclude poor quality samples.
This was done very low normalizer values often lead to very high
normalized expression values. We can apply this threshold to eliminate
poor quality samples:

``` r
high_quality_samples <- 
  names(sample_normalizer_values[sample_normalizer_values > 35])
filtered_exprs_mat <- exprs_mat[, high_quality_samples]
dim(filtered_exprs_mat)
#> [1] 30 66
```

This eliminates 2 poor quality samples leaving us with 66 samples.
**Note that the sample HL1120 did not receive ASCT and thus was not
reported in figure 4 of the paper. As such, the final number in figure 4
is 65 samples.**

Let’s normalize our expression matrix and generate the RHL30 scores for
each sample:

``` r
filtered_exprs_mat_norm <- 
  normalize_exprs_mat(filtered_exprs_mat, sample_normalizer_values)
#> [normalize_exprs_mat]: Normalizing the expression exprs_matrix
#> [normalize_exprs_mat]: Log2 transforming
rhl30_df <- get_rhl30_scores_df(filtered_exprs_mat_norm, rhl30_model_df)
head(rhl30_df)
#> # A tibble: 6 x 2
#>   sample_id score
#>   <chr>     <dbl>
#> 1 HL1013    10.3 
#> 2 HL1014    10.5 
#> 3 HL1015     9.77
#> 4 HL1017     9.80
#> 5 HL1018    11.3 
#> 6 HL1019     9.70
```

# R Session

``` r
devtools::session_info()
#> ─ Session info ──────────────────────────────────────────────────────────
#>  setting  value                       
#>  version  R version 3.5.1 (2018-07-02)
#>  os       macOS Sierra 10.12.6        
#>  system   x86_64, darwin13.4.0        
#>  ui       unknown                     
#>  language (EN)                        
#>  collate  en_GB.UTF-8                 
#>  ctype    en_GB.UTF-8                 
#>  tz       Europe/London               
#>  date     2019-10-27                  
#> 
#> ─ Packages ──────────────────────────────────────────────────────────────
#>  package     * version    date       lib source        
#>  assertthat    0.2.1      2019-03-21 [1] CRAN (R 3.5.1)
#>  backports     1.1.4      2019-04-10 [1] CRAN (R 3.5.1)
#>  callr         3.3.0      2019-07-04 [1] CRAN (R 3.5.1)
#>  cli           1.1.0      2019-03-19 [1] CRAN (R 3.5.1)
#>  crayon        1.3.4      2017-09-16 [1] CRAN (R 3.5.1)
#>  desc          1.2.0      2018-05-01 [1] CRAN (R 3.5.1)
#>  devtools      2.1.0      2019-07-06 [1] CRAN (R 3.5.1)
#>  digest        0.6.20     2019-07-04 [1] CRAN (R 3.5.1)
#>  dplyr       * 0.8.3      2019-07-04 [1] CRAN (R 3.5.1)
#>  evaluate      0.14       2019-05-28 [1] CRAN (R 3.5.1)
#>  fansi         0.4.0      2018-10-05 [1] CRAN (R 3.5.1)
#>  fs            1.3.1      2019-05-06 [1] CRAN (R 3.5.1)
#>  glue          1.3.1      2019-03-12 [1] CRAN (R 3.5.1)
#>  hms           0.5.0      2019-07-09 [1] CRAN (R 3.5.1)
#>  htmltools     0.3.6      2017-04-28 [1] CRAN (R 3.5.1)
#>  knitr       * 1.23       2019-05-18 [1] CRAN (R 3.5.1)
#>  magrittr      1.5        2014-11-22 [1] CRAN (R 3.5.1)
#>  memoise       1.1.0      2017-04-21 [1] CRAN (R 3.5.1)
#>  pillar        1.4.2      2019-06-29 [1] CRAN (R 3.5.1)
#>  pkgbuild      1.0.3      2019-03-20 [1] CRAN (R 3.5.1)
#>  pkgconfig     2.0.2      2018-08-16 [1] CRAN (R 3.5.1)
#>  pkgload       1.0.2      2018-10-29 [1] CRAN (R 3.5.1)
#>  prettyunits   1.0.2      2015-07-13 [1] CRAN (R 3.5.1)
#>  processx      3.4.0      2019-07-03 [1] CRAN (R 3.5.1)
#>  ps            1.3.0      2018-12-21 [1] CRAN (R 3.5.1)
#>  purrr         0.3.2      2019-03-15 [1] CRAN (R 3.5.1)
#>  R6            2.4.0      2019-02-14 [1] CRAN (R 3.5.1)
#>  Rcpp          1.0.1      2019-03-17 [1] CRAN (R 3.5.1)
#>  readr         1.3.1      2018-12-21 [1] CRAN (R 3.5.1)
#>  remotes       2.1.0      2019-06-24 [1] CRAN (R 3.5.1)
#>  RHL30       * 0.0.0.9000 2019-10-27 [1] local         
#>  rlang         0.4.0      2019-06-25 [1] CRAN (R 3.5.1)
#>  rmarkdown     1.14       2019-07-12 [1] CRAN (R 3.5.1)
#>  rprojroot     1.3-2      2018-01-03 [1] CRAN (R 3.5.1)
#>  sessioninfo   1.1.1      2018-11-05 [1] CRAN (R 3.5.1)
#>  stringi       1.4.3      2019-03-12 [1] CRAN (R 3.5.1)
#>  stringr       1.4.0      2019-02-10 [1] CRAN (R 3.5.1)
#>  testthat      2.1.1      2019-04-23 [1] CRAN (R 3.5.1)
#>  tibble        2.1.3      2019-06-06 [1] CRAN (R 3.5.1)
#>  tidyselect    0.2.5      2018-10-11 [1] CRAN (R 3.5.1)
#>  usethis       1.5.1      2019-07-04 [1] CRAN (R 3.5.1)
#>  utf8          1.1.4      2018-05-24 [1] CRAN (R 3.5.1)
#>  vctrs         0.2.0      2019-07-05 [1] CRAN (R 3.5.1)
#>  withr         2.1.2      2018-03-15 [1] CRAN (R 3.5.1)
#>  xfun          0.8        2019-06-25 [1] CRAN (R 3.5.1)
#>  yaml          2.2.0      2018-07-25 [1] CRAN (R 3.5.1)
#>  zeallot       0.1.0      2018-01-28 [1] CRAN (R 3.5.1)
#> 
#> [1] /Users/fongchan/miniconda3/envs/rhl/lib/R/library
```
