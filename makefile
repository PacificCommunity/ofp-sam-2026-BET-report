# ------------------------------------------------------------
# Makefile for BET-2026 pipeline
# ------------------------------------------------------------

DOCKER_IMAGE=ghcr.io/pacificcommunity/bet-2026:v1.2
WORKDIR=/workspace

# ------------------------------------------------------------
# 1. Local pipeline
# ------------------------------------------------------------


collect:
	Rscript collect_results.R

# Sensitivity plots (no dependency)
plot_sens:
	Rscript -e "rmarkdown::render('plot/plots_sens.rmd')"

# Grid plots (no dependency)
plot_grid:
	Rscript -e "rmarkdown::render('plot/plots_grid.rmd')"

# Report (no dependency)
report:
	quarto render report/bet-2026.qmd

# Clean outputs
clean:
	rm -rf model
	rm -rf results_rds
	rm -f $(STAMP_FILE)
	rm -rf report/Figures/sens/*.png
	rm -rf report/Figures/grid/*.png

# ------------------------------------------------------------
# 2. Docker pipeline
# ------------------------------------------------------------

docker-plot_sens:
	docker run --rm -v "$(CURDIR):$(WORKDIR)" -w $(WORKDIR) $(DOCKER_IMAGE) \
		Rscript -e "rmarkdown::render('plot/plots_sens.rmd')"

docker-plot_grid:
	docker run --rm -v "$(CURDIR):$(WORKDIR)" -w $(WORKDIR) $(DOCKER_IMAGE) \
		Rscript -e "rmarkdown::render('plot/plots_grid.rmd')"

docker-report:
	docker run --rm -v "$(CURDIR):$(WORKDIR)" -w $(WORKDIR) $(DOCKER_IMAGE) \
		quarto render report/bet-2026.qmd

# ------------------------------------------------------------
# PHONY targets
# ------------------------------------------------------------
.PHONY: collect plot_sens plot_grid report clean \
        docker-plot_sens docker-plot_grid docker-report
