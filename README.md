
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RHL30

An R Package for the RHL30 prognostic predictor. The predictor is a gene
expression-based prognostic model for predicting post-autologous
stem-cell transplantation outcomes. **It designed to be used on RHL30
NanoString expression count data on relapsed Hodgkin lymphoma (RHL)
samples**.

The predictor was published at:

Chan FC\*, Mottok A\*, et al. Prognostic Model to Predict
Post-Autologous Stem-Cell Transplantation Outcomes in Classical Hodgkin
Lymphoma. J Clin Oncol JCO2017727925 (2017)
<doi:10.1200/JCO.2017.72.7925>. \*Contributed equally to this work.

# How to Install

To install this package, you need to first have the package `devtools`
installed, then you run:

``` r
devtools::install_github("tinyheero/RHL30")
```

# How to use

We will be using the BCCA RHL30 training cohort from the paper as an
example of how to generate RHL30 predictor score. The following steps
will reproduce the RHL30 scores from the paper.

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

The next step is to load the expression data you want to generate RHL30
scores on. The expression data should be a tab-separated values file.
The first line should be a header line with `gene_name` as the first
column followed by the sample identifiers. Each row should then be the
name of the gene and then the respectively raw expression values for
each sample.

The expression data of the [BCCA RHL30 training cohort is provided as an
example](https://github.com/tinyheero/RHL30/blob/master/inst/extdata/bcca_rhl_rhl30_gene_exprs_mat.tsv).
Let’s load that data:

``` r
exprs_file <- 
  system.file("extdata", "bcca_rhl_rhl30_gene_exprs_mat.tsv", package = "RHL30")
exprs_mat <- load_exprs_mat(exprs_file)
dim(exprs_mat)
#> [1] 30 68
```

The expression data contains the 30 genes (rows) and 68 samples
(columns). Next we calculate the normalizer values (geometric mean of
the 12 housekeepers) for each sample:

``` r
hk_genes <- 
  filter(rhl30_model_df, gene_type == "housekeeper") %>%
  pull("gene_name")

sample_normalizer_values <- get_sample_normalizer_value(exprs_mat, hk_genes)
#> [get_normalizer]: Generating the geometric mean of housekeeper genes
```

In the paper, a threshold of 35 was set to exclude poor quality samples.
This was done because very low normalizer values often lead to very high
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
#> ─ Session info ───────────────────────────────────────────────────────────────
#>  setting  value                       
#>  version  R version 3.6.2 (2019-12-12)
#>  os       macOS Sierra 10.12.6        
#>  system   x86_64, darwin16.7.0        
#>  ui       unknown                     
#>  language (EN)                        
#>  collate  en_GB.UTF-8                 
#>  ctype    en_GB.UTF-8                 
#>  tz       Europe/London               
#>  date     2020-02-29                  
#> 
#> ─ Packages ───────────────────────────────────────────────────────────────────
#>  package     * version    date       lib source                          
#>  assertthat    0.2.1      2019-03-21 [1] CRAN (R 3.6.2)                  
#>  backports     1.1.5      2019-10-02 [1] CRAN (R 3.6.2)                  
#>  callr         3.4.2      2020-02-12 [1] CRAN (R 3.6.2)                  
#>  cli           2.0.1      2020-01-08 [1] CRAN (R 3.6.2)                  
#>  crayon        1.3.4      2017-09-16 [1] CRAN (R 3.6.2)                  
#>  desc          1.2.0      2018-05-01 [1] CRAN (R 3.6.2)                  
#>  devtools      2.2.2      2020-02-17 [1] CRAN (R 3.6.2)                  
#>  digest        0.6.25     2020-02-23 [1] CRAN (R 3.6.2)                  
#>  dplyr       * 0.8.4      2020-01-31 [1] CRAN (R 3.6.2)                  
#>  ellipsis      0.3.0      2019-09-20 [1] CRAN (R 3.6.2)                  
#>  evaluate      0.14       2019-05-28 [1] CRAN (R 3.6.2)                  
#>  fansi         0.4.1      2020-01-08 [1] CRAN (R 3.6.2)                  
#>  fs            1.3.1      2019-05-06 [1] CRAN (R 3.6.2)                  
#>  glue          1.3.1      2019-03-12 [1] CRAN (R 3.6.2)                  
#>  hms           0.5.3      2020-01-08 [1] CRAN (R 3.6.2)                  
#>  htmltools     0.4.0      2019-10-04 [1] CRAN (R 3.6.2)                  
#>  knitr       * 1.28       2020-02-06 [1] CRAN (R 3.6.2)                  
#>  magrittr      1.5        2014-11-22 [1] CRAN (R 3.6.2)                  
#>  memoise       1.1.0      2017-04-21 [1] CRAN (R 3.6.2)                  
#>  pillar        1.4.3      2019-12-20 [1] CRAN (R 3.6.2)                  
#>  pkgbuild      1.0.6      2019-10-09 [1] CRAN (R 3.6.2)                  
#>  pkgconfig     2.0.3      2019-09-22 [1] CRAN (R 3.6.2)                  
#>  pkgload       1.0.2      2018-10-29 [1] CRAN (R 3.6.2)                  
#>  prettyunits   1.1.1      2020-01-24 [1] CRAN (R 3.6.2)                  
#>  processx      3.4.2      2020-02-09 [1] CRAN (R 3.6.2)                  
#>  ps            1.3.2      2020-02-13 [1] CRAN (R 3.6.2)                  
#>  purrr         0.3.3      2019-10-18 [1] CRAN (R 3.6.2)                  
#>  R6            2.4.1      2019-11-12 [1] CRAN (R 3.6.2)                  
#>  Rcpp          1.0.3      2019-11-08 [1] CRAN (R 3.6.2)                  
#>  readr         1.3.1      2018-12-21 [1] CRAN (R 3.6.2)                  
#>  remotes       2.1.1      2020-02-15 [1] CRAN (R 3.6.2)                  
#>  RHL30       * 0.0.0.9000 2020-02-29 [1] Github (tinyheero/RHL30@2d9e3bc)
#>  rlang         0.4.4      2020-01-28 [1] CRAN (R 3.6.2)                  
#>  rmarkdown     2.1        2020-01-20 [1] CRAN (R 3.6.2)                  
#>  rprojroot     1.3-2      2018-01-03 [1] CRAN (R 3.6.2)                  
#>  sessioninfo   1.1.1      2018-11-05 [1] CRAN (R 3.6.2)                  
#>  stringi       1.4.6      2020-02-17 [1] CRAN (R 3.6.2)                  
#>  stringr       1.4.0      2019-02-10 [1] CRAN (R 3.6.2)                  
#>  testthat      2.3.1      2019-12-01 [1] CRAN (R 3.6.2)                  
#>  tibble        2.1.3      2019-06-06 [1] CRAN (R 3.6.2)                  
#>  tidyselect    1.0.0      2020-01-27 [1] CRAN (R 3.6.2)                  
#>  usethis       1.5.1      2019-07-04 [1] CRAN (R 3.6.2)                  
#>  utf8          1.1.4      2018-05-24 [1] CRAN (R 3.6.2)                  
#>  vctrs         0.2.3      2020-02-20 [1] CRAN (R 3.6.2)                  
#>  withr         2.1.2      2018-03-15 [1] CRAN (R 3.6.2)                  
#>  xfun          0.12       2020-01-13 [1] CRAN (R 3.6.2)                  
#>  yaml          2.2.1      2020-02-01 [1] CRAN (R 3.6.2)                  
#> 
#> [1] /usr/local/Cellar/r/3.6.2/lib/R/library
```
