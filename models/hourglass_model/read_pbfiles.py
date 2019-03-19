# -*- coding: utf-8 -*-
# ! /usr/bin/env python
'''
    filename: run_load_cpktmeta_tfsummary.py

    description: this file is for loading the prototype model of
    pose estimation model and collecting a log summary for
    tensorboard use in the dont-be-turtle proj.


    - functions
        - loading model from ckpt and meta files
        - collecting a summary to plotting the model in a tensorboard use.

    - Author : jaewook Kang @ 20180613

'''

from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import sys
import tensorflow as tf

from os import getcwd



