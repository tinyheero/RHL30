# Generic Recipe to Render Single HTML File
%.html : %.Rmd
	Rscript --slave -e "rmarkdown::render('$<')"
