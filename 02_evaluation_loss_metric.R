# Copyright (c) 2021. All rights reserved.
#
# This work is licensed under the Creative Commons Attribution-NonCommercial
# 4.0 International License. To view a copy of this license, visit
# http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to
# Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.

options(warn = -1, scipen = 999)

suppressPackageStartupMessages(library(googlesheets4))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(RColorBrewer))

# Get loss scores
googlesheets4::gs4_auth()
metrics <- googlesheets4::read_sheet('https://docs.google.com/spreadsheets/d/17XVqT8Oc6T7_zn3q6TWJHURcjhhotkuCEjP9mwVPR1c/edit#gid=0')
metrics %>% dplyr::glimpse()

# Graph scores
gg <- metrics %>%
  dplyr::filter(Metric %in% c('Loss scores real','Loss scores fake')) %>%
  dplyr::mutate(Metric = factor(Metric, levels = c('Loss scores real','Loss scores fake'))) %>%
  dplyr::group_by(Source, Target) %>%
  dplyr::mutate(Time = (Step-min(Step)),
                Source = factor(Source, levels = c('Paintings','Portraits','Pokemon','Bedrooms','Cats'))) %>%
  ggplot2::ggplot(aes(x = Time/1000, y = Value, colour = Source)) +
  ggplot2::geom_line(aes(linetype = Metric), size = 1.2) +
  ggplot2::facet_wrap(~Target) +
  ggplot2::xlim(0, 1000) +
  ggplot2::xlab('Iteration') +
  ggplot2::ylab('Loss scores') +
  ggplot2::geom_hline(yintercept = 0, linetype = 'dashed') +
  ggplot2::scale_color_brewer(palette = 'Set1') +
  ggplot2::theme_bw() +
  ggplot2::theme(axis.text = element_text(size = 17),
                 axis.title = element_text(size = 20),
                 legend.text = element_text(size = 17),
                 legend.title = element_text(size = 20),
                 strip.text.x = element_text(size = 20))
ggplot2::ggsave(filename = "./Loss_scores.png", plot = gg, device = "png", width = 14, height = 8, units = "in")
