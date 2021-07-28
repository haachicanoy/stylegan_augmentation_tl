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