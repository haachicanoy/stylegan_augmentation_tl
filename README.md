# StyleGAN data augmentation with transfer learning in industrial applications

![Teaser image](./stylegan_tl.png)
**Picture:** *Generated target images from the source pre-trained domains.*

## Paper
> **StyleGANs and transfer learning for generating synthetic images in industrial applications**
> 
> Harold Achicanoy, Deisy Chavez, and Maria Trujillo
> 
> **Abstract:** *Deep learning applications on computer vision involve the use of a large volume and representative data to obtain state-of-art results due to the massive number of parameters to optimise in deep models.  However, data is limited with asymmetric distributions in industrial applications due to rare cases, legal restrictions, and high image acquisition costs. Data augmentation based on deep learning generative adversarial networks, such as StyleGAN, has been arise as a way to create training data with symmetric distributions that may improve the generalisation capability of the built models. StyleGAN generates highly realistic images  in a variety of domains as a data aumentation strategy but requires a large amount of data to build image generators. Thus, transfer learning in conjunction with generative models has been used to build models with small datasets.  However, there are not reports on the impact of pre-trained generative models using transfer learning. In this paper, we evaluate a StyleGAN generative model with transfer learning on different application domains ---training with paintings, portraits, pokemon, bedrooms, and cats--- to generate target images with different levels of content variability ---bean seeds (low variability), faces of subjects between 5 and 19 years (medium variability), charcoal (high variability). We used the first version of StyleGAN due to the large number of publicly available pre-trained models. The Fréchet Inception Distance was used for evaluating the quality of synthetic images.  We found that StyleGAN with transfer learning produced good quality images being an alternative for generating realistic synthetic images in the evaluated domains.*

## System requirements

GPU used:
- NVIDIA TITAN Xp 11 GB

Software:
- Operative System: Ubuntu 18.04
- TensorFlow 1.13.1
- CUDA 10.1
- NVIDIA driver version 435.21
- cuDNN 7.6.3
- The official code implementation from: https://github.com/NVlabs/stylegan

## Dependencies
- R Statistical software
- RStudio IDE
- 'readr' package

## Code/Use instructions

### Folder structure

```
.
└── images
	└────── beans
			└──── 256
			└──── 512
	└────── chars
			└──── 256
			└──── 512
	└────── young_faces
			└──── 256
			└──── 512
└── pkl
└── pretrained
└── scripts
└── simulations
    └────────── stylegan_from_bedrooms_to_beans
    ...
    └────────── stylegan_from_portraits_to_young_faces
```

The 'images' folder contains the target image domains with .jpg images at two resolutions: 256x256 and 512x512 pixels.

The 'pkl' folder contains the pre-trained models for obtaining the evaluation metric Fréchet Inception Distance (FID): *inception_v3_features.pkl* and *vgg16_zhang_perceptual.pkl*.

The 'pretrained' folder contains the pkl StyleGAN pre-trained models from the five-source domains: Paintings, Portraits, Pokemon, Bedrooms, and Cats.

The 'scripts' folder has the python script to generate images from the transferred learning models. Same as *01_generating_imgs.py*.

The 'simulations' folder contains the folders with the transferred models indicating the source and target domains.

### Code instructions

The main script is *00_master_code.R* which using a R-function:
1. Download the StyleGAN official code each simulation
2. Fit the hyper-parameters
3. Transform the .jpg images into .tf-records
4. Perform the training with transfer learning from a source to target domain

```
> # Define working directory
> root <<- '.'
> setwd(root)

> # Move to simulations folder
> setwd('./simulations')

> # Define hyperparameters
> lr     <<- 0.003 # Learning rates for Generator and Discriminator networks: 0.0003
> mb_rep <<- 4     # Minibatch repetitions
> run_stylegan(source_domain    = "paintings",
               target_domain    = "young_faces",
               pretrained_model = "network-snapshot-008040.pkl",
               resolution       = 512,
               last_iteration   = 8040,
               target_iteration = 9000,
               learning_rate    = lr,
               minibatch_rep    = mb_rep)
```

This script has the routine to execute all the experiments. The second step, once the models are transferred learning from source domains is to generate/augment the images for the target domains, this is done throuhg the script *01_generate_images.R* which uses a R-function specifying the name of the source and target domains, desired number of images to generate and the truncation parameter (from StyleGAN official code):

```
> generate_images(source_domain = 'paintings',
                  target_domain = 'young_faces',
                  model         = 'network-final.pkl',
                  number_images = 1000,
                  trunc_psi     = 0.7)
```

Lastly, for evaluating the obtained results using FID and the loss scores the scripts *02_evaluation_fid_metric.R* and *02_evaluation_loss_metric.R* are used.