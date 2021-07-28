# Copyright (c) 2021. All rights reserved.
#
# This work is licensed under the Creative Commons Attribution-NonCommercial
# 4.0 International License. To view a copy of this license, visit
# http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to
# Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.

options(warn = -1, scipen = 999)

suppressPackageStartupMessages(library(googlesheets))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(RColorBrewer))

# Get FID metrics
googlesheets4::gs4_auth()
metrics <- googlesheets4::read_sheet('https://docs.google.com/spreadsheets/d/17XVqT8Oc6T7_zn3q6TWJHURcjhhotkuCEjP9mwVPR1c/edit#gid=0')
metrics %>% dplyr::glimpse()
metrics <- metrics %>% dplyr::mutate(FID = FID/1e4)

# Barplot graph (english version)
metrics_en <- metrics
metrics_en$Origen[metrics_en$Origen == 'Pinturas'] <- 'Paintings'
metrics_en$Origen[metrics_en$Origen == 'Retratos'] <- 'Portraits'
metrics_en$Origen[metrics_en$Origen == 'Habitaciones'] <- 'Bedrooms'
metrics_en$Origen[metrics_en$Origen == 'Gatos'] <- 'Cats'

metrics_en$Objetivo[metrics_en$Objetivo == 'Semillas'] <- 'Bean seeds'
metrics_en$Objetivo[metrics_en$Objetivo == 'Carbonizados'] <- 'Chars'
metrics_en$Objetivo[metrics_en$Objetivo == 'Rostros'] <- 'Young faces'

metrics_en %>%
  dplyr::group_by(Origen, Objetivo) %>%
  dplyr::summarise(FID_mdn = median(FID, na.rm = T),
                   FID_mad = mad(FID, na.rm = T)) %>%
  dplyr::ungroup() %>%
  tibble::add_row(., Origen = 'Portraits', Objetivo = 'Chars', FID_mdn = 0, FID_mad = 0) %>%
  tibble::add_row(., Origen = 'Pokemon', Objetivo = 'Chars', FID_mdn = 0, FID_mad = 0) %>%
  ggplot2::ggplot(aes(x = factor(Objetivo, levels = c('Bean seeds','Chars','Young faces')), y = FID_mdn, fill = factor(Origen, levels = c('Paintings','Portraits','Pokemon','Bedrooms','Cats')))) +
  ggplot2::geom_bar(stat = "identity", position = position_dodge()) +
  ggplot2::geom_errorbar(aes(ymin = FID_mdn-FID_mad, ymax = FID_mdn+FID_mad), width = .2, position = position_dodge(.9)) +
  ggplot2::scale_fill_brewer(palette = 'Set1', drop = F) +
  ggplot2::scale_x_discrete(drop = F) +
  ggplot2::scale_y_continuous(expand = c(0,0), limits = c(0, 70)) +
  ggplot2::theme_bw() +
  ggplot2::theme(axis.text = element_text(size = 17),
                 axis.title = element_text(size = 20),
                 legend.text = element_text(size = 17),
                 legend.title = element_text(size = 20)) +
  ggplot2::xlab('Target domain') +
  ggplot2::ylab('FID (median)') +
  ggplot2::labs(fill = 'Source domain') +
  ggplot2::ggsave(filename = "./FID_median_transfer_learning_en.png", device = "png", width = 8, height = 6, units = "in")

# Time series graph (english version)
metrics_en %>%
  dplyr::mutate(Objetivo = factor(Objetivo, levels = c('Bean seeds','Chars','Young faces'))) %>%
  dplyr::mutate(Origen = factor(Origen, levels = c('Paintings','Portraits','Pokemon','Bedrooms','Cats'))) %>%
  dplyr::group_by(Origen, Objetivo) %>%
  dplyr::mutate(Duración = (Iteración-min(Iteración))) %>%
  ggplot2::ggplot(aes(x = Duración, y = FID, group = Origen, colour = Origen)) +
  ggplot2::geom_line(size = 1.2) +
  ggplot2::xlim(0, 1000) +
  # ggplot2::geom_vline(xintercept = c(24, 48), linetype="dotted", size = 1.2) +
  ggplot2::facet_wrap(~Objetivo, scales = 'fixed') +
  ggplot2::theme_bw() +
  ggplot2::theme(axis.text = element_text(size = 17),
                 axis.title = element_text(size = 20),
                 legend.text = element_text(size = 17),
                 legend.title = element_text(size = 20),
                 strip.text = element_text(size = 20),
                 legend.position = "bottom") +
  ggplot2::scale_colour_brewer(palette = 'Set1') +
  ggplot2::xlab('Iteration') +
  ggplot2::labs(colour = 'Source domain') +
  ggplot2::ggsave(filename = "./FID_over_time_transfer_learning_en.png", device = "png", width = 12, height = 6, units = "in")
