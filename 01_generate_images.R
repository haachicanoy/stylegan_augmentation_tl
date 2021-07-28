# Copyright (c) 2021. All rights reserved.
#
# This work is licensed under the Creative Commons Attribution-NonCommercial
# 4.0 International License. To view a copy of this license, visit
# http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to
# Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.

options(warn = -1, scipen = 999)
suppressMessages(library(readr))

# Grid of experiments
cases2evaluate <- data.frame(Source = c(c('portraits','pokemon','paintings','cats','bedrooms'),
                                        c('paintings','bedrooms','cats'),
                                        c('portraits','pokemon','paintings','cats','bedrooms')),
                             Target = c(rep('beans',5),
                                        rep('chars',3),
                                        rep('young_faces',5)))
# The unsuccessful experiments are excluded
cases2evaluate <- cases2evaluate[c(3:10,12,13),]

# Define working directory
root <<- '.'
setwd(root)
setwd('./simulations')

# Function to generate images
generate_images <- function(source_domain = "paintings",
                            target_domain = "young_faces",
                            number_images = 1000,
                            trunc_psi = 0.7)
{
  cat('>>> Set working directory\n')
  wk_dir <- paste0('stylegan_from_', source_domain, '_to_', target_domain)
  setwd(paste0('./', wk_dir))
  
  cat('>>> Set output directory\n')
  if(!dir.exists(paste0('./generated_images/psi_',trunc_psi))){
    dir.create(paste0('./generated_images/psi_',trunc_psi), recursive = T)
  }
  
  cat('>>> Generate seeds\n')
  set.seed(1235)
  seeds <- sample(0:4000000, number_images, replace = F)
  
  models <- list.files('./results/00000-sgan-custom-1gpu', pattern = '^network-')
  
  if('network-final.pkl' %in% models){
    model <- 'network-final.pkl'
  } else {
    model <- list.files('./results/00000-sgan-custom-1gpu', pattern = '^network-')
    model <- model[length(model)]
  }
  
  for(i in 1:length(seeds)){
    cat('>>> Set up generating images function\n')
    file.copy(from = paste0(root, '/scripts/generating_imgs.py'), to = './generating_imgs.py', overwrite = T)
    generating_imgs     <- readr::read_lines('./generating_imgs.py')
    generating_imgs[11] <- gsub('in',paste0('./results/00000-sgan-custom-1gpu/',model),generating_imgs[11])
    generating_imgs[16] <- gsub('123',seeds[i],generating_imgs[16])
    outfile <- paste0('./generated_images/psi_',trunc_psi,'/img_',i,'_',seeds[i],'.jpg')
    generating_imgs[20] <- gsub('out',outfile,generating_imgs[20])
    readr::write_lines(generating_imgs, './generating_imgs.py')
    system('python generating_imgs.py')
  }
  return(cat(paste0('Images generated for run: ',source_domain,' to ',target_domain,'\n')))
  
  root <<- '.'
  setwd(root)
  setwd('./simulations')
  
}

# Run all possible simulations
for(j in 1:nrow(cases2evaluate)){
  generate_images(source_domain = cases2evaluate$Source[j],
                  target_domain = cases2evaluate$Target[j],
                  number_images = 1000,
                  trunc_psi     = 0.7)
}

# ------------------------------------------------------------------------------------------------
# Run an individual case
# # Generate young faces images from transfered learning model pre-trained on paintings
# generate_images(source_domain = 'paintings',
#                 target_domain = 'young_faces',
#                 model         = 'network-final.pkl',
#                 number_images = 1000,
#                 trunc_psi     = 0.7)