# Master code generative modeling thesis
# By: Harold Achicanoy
# Universidad del Valle

options(warn = -1, scipen = 999)
suppressMessages(library(readr))

# Run StyleGAN function
run_stylegan <- function(source_domain = "paintings", target_domain = "young_faces", pretrained_model = "network-snapshot-008040.pkl", resolution = 512, last_iteration = 8040, target_iteration = 9000, learning_rate = lr, minibatch_rep = mb_rep){
  
  system('git clone https://github.com/NVlabs/stylegan.git')
  wk_dir <- paste0('stylegan_from_', source_domain, '_to_', target_domain)
  file.rename(from = 'stylegan', to = wk_dir)
  
  # Move to specific dir
  setwd(paste0('./', wk_dir))
  
  # Create .tfrecords files
  system(paste0('python dataset_tool.py create_from_images datasets/smalls/ ', paste0(root, '/images/', target_domain, "/", resolution)))
  
  # Modify training_loop.py
  training_loop <- readLines('./training/training_loop.py')
  training_loop[127] <- gsub(pattern = '4', replacement = minibatch_rep, x = training_loop[127]) # Minibatch repeats
  training_loop[136] <- gsub(pattern = "None,", replacement = paste0("'", root, '/pretrained/', pretrained_model, "',"), x = training_loop[136]) # Path where pretrained model is
  training_loop[138] <- gsub(pattern = "0.0", replacement = last_iteration, x = training_loop[138]) # Last iteration to start transfer learning
  readr::write_lines(training_loop, './training/training_loop.py')
  rm(training_loop)
  
  # Modify train.py
  train <- readLines('./train.py')
  train[32] <- paste0("    #metrics       = [metric_base.fid50k]                                                   # Options for MetricGroup.")
  train[37] <- paste0("    desc += '-custom';     dataset = EasyDict(tfrecord_dir='smalls', resolution=", resolution,");              train.mirror_augment = True") # Preparing new dataset with determined resolution
  train[46] <- paste0("    desc += '-1gpu'; submit_config.num_gpus = 1; sched.minibatch_base = 4; sched.minibatch_dict = {4: 128, 8: 128, 16: 128, 32: 64, 64: 32, 128: 16, 256: 8, 512: 4}") # Enabling 1-GPU setting
  train[49] <- paste0("    #desc += '-8gpu'; submit_config.num_gpus = 8; sched.minibatch_base = 32; sched.minibatch_dict = {4: 512, 8: 256, 16: 128, 32: 64, 64: 32}") # Disabling 8-GPU setting
  train[52] <- gsub(pattern = '25000', replacement = target_iteration, x = train[52]) # Total lenght of the training
  train[54] <- gsub(pattern = '0.003', replacement = learning_rate, x = train[54]) # Adjusting Learning Rates for both Generator and Discriminator networks
  
  # Disabling non-used parameters
  train[96]  <- "    #metrics       = [metric_base.fid50k]                                           # Options for MetricGroup."
  train[101] <- "    #desc += '-celebahq';            dataset = EasyDict(tfrecord_dir='celebahq'); train.mirror_augment = True"
  train[148] <- "    #desc += '-preset-v2-1gpu'; submit_config.num_gpus = 1; sched.minibatch_base = 4; sched.minibatch_dict = {4: 128, 8: 128, 16: 128, 32: 64, 64: 32, 128: 16, 256: 8, 512: 4}; sched.G_lrate_dict = {1024: 0.0015}; sched.D_lrate_dict = EasyDict(sched.G_lrate_dict); train.total_kimg = 12000"
  train[154] <- "    #desc += '-fp32'; sched.max_minibatch_per_gpu = {256: 16, 512: 8, 1024: 4}"
  train[180] <- "    kwargs.update(dataset_args=dataset, sched_args=sched, grid_args=grid, tf_config=tf_config)"
  readr::write_lines(train, './train.py')
  rm(train)
  
  system('python train.py')
  cat(paste0('Experiment ', wk_dir, ' finished successfully!\n'))
  setwd(paste0(root, '/simulations'))
  
}

# Define working directory
root <<- '/media/argos/DATA/HTH'
setwd(root) # Harold THesis

# Original domain - pretrained models from Google Drive
# tl_models <- list(portraits = '1R2nJe2Ho3Eleg0e6eP_hlKuVmu8NAoDG',
#                   pokemon   = '1fRR5mOCbD4pKsbN4CpexZVzLCX-9wKpB',
#                   paintings = '1_Up_g8a_xn1uudcvZIBOluZprpl8Eksr',
#                   cats      = '1MQywl0FNt6lHu8E_EUqnRbviagS7fbiJ',
#                   bedrooms  = '1MOSKeGF0FJcivpBI7s63V9YHloUTORiF')

# Source domain info
source_domain <- list(portraits = list(network          = 'network-snapshot-011125.pkl',
                                       last_iteration   = 11125,
                                       target_iteration = 12000,
                                       resolution       = 512),
                      pokemon   = list(network          = 'network-snapshot-007961.pkl',
                                       last_iteration   = 7961,
                                       target_iteration = 9000,
                                       resolution       = 512),
                      paintings = list(network          = 'network-snapshot-008040.pkl',
                                       last_iteration   = 8040,
                                       target_iteration = 9000,
                                       resolution       = 512),
                      cats      = list(network          = 'karras2019stylegan-cats-256x256.pkl',
                                       last_iteration   = 7000,
                                       target_iteration = 8000,
                                       resolution       = 256),
                      bedrooms  = list(network          = 'karras2019stylegan-bedrooms-256x256.pkl',
                                       last_iteration   = 7000,
                                       target_iteration = 8000,
                                       resolution       = 256))

# Target domain info
target_domain <- list(beans       = 'beans',
                      chars       = 'chars',
                      young_faces = 'young_faces',
                      elder_faces = 'elder_faces')

# Hyperparameters to modify
lr     <- 0.001 # Learning rates for Generator and Discriminator networks c(0.001, 0.0003)
mb_rep <- 1     # Minibatch repetitions

# Move to simulations folder
setwd('./simulations')

# ------------------------------------------------------------------------------------------------
# Run all possible simulations
for(tg in names(target_domain)){
  
  for(sc in names(source_domain)){
    
    run_stylegan(source_domain    = sc,
                 target_domain    = tg,
                 pretrained_model = source_domain[names(source_domain)==sc][[1]]$network,
                 resolution       = source_domain[names(source_domain)==sc][[1]]$resolution,
                 last_iteration   = source_domain[names(source_domain)==sc][[1]]$last_iteration,
                 target_iteration = source_domain[names(source_domain)==sc][[1]]$target_iteration,
                 learning_rate    = lr,
                 minibatch_rep    = mb_rep)
    
  }
  
}

# ------------------------------------------------------------------------------------------------
# Run an individual simulation

options(warn = -1, scipen = 999)
suppressMessages(library(readr))

# Define working directory
root <<- '/media/argos/DATA/HTH'
setwd(root) # Harold THesis

# Move to simulations folder
setwd('./simulations')

# Define hyperparameters
lr     <<- 0.001 # Learning rates for Generator and Discriminator networks c(0.001, 0.0003)
mb_rep <<- 1     # Minibatch repetitions

run_stylegan(source_domain    = "paintings",
             target_domain    = "young_faces",
             pretrained_model = "network-snapshot-008040.pkl",
             resolution       = 512,
             last_iteration   = 8040,
             target_iteration = 9000,
             learning_rate    = lr,
             minibatch_rep    = mb_rep)
run_stylegan(source_domain    = "paintings",
             target_domain    = "chars",
             pretrained_model = "network-snapshot-008040.pkl",
             resolution       = 512,
             last_iteration   = 8040,
             target_iteration = 9000,
             learning_rate    = lr,
             minibatch_rep    = mb_rep)