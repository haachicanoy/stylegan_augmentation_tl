# Copyright (c) 2021. All rights reserved.
#
# This work is licensed under the Creative Commons Attribution-NonCommercial
# 4.0 International License. To view a copy of this license, visit
# http://creativecommons.org/licenses/by-nc/4.0/ or send a letter to
# Creative Commons, PO Box 1866, Mountain View, CA 94042, USA.

import os
import pickle
import numpy as np
import PIL.Image
import dnnlib
import dnnlib.tflib as tflib
import config

tflib.init_tf()

model_path = "in"
with open(model_path,"rb") as f:
        _G, _D, Gs = pickle.load(f)

fmt            = dict(func = tflib.convert_images_to_uint8, nchw_to_nhwc = True)
rnd            = np.random.RandomState(123)
latent_vector1 = rnd.randn(1, Gs.input_shape[1])
images         = Gs.run(latent_vector1, None, truncation_psi=1, randomize_noise=False, output_transform=fmt)
img            = PIL.Image.fromarray(images[0])
img.save("out")