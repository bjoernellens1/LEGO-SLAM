##+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
## Created by: Hang Zhang
## ECE Department, Rutgers University
## Email: zhang.hang@rutgers.edu
## Copyright (c) 2017
##
## This source code is licensed under the MIT-style license found in the
## LICENSE file in the root directory of this source tree
##+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

"""Encoding NN Modules"""

import torch.nn as nn

from .customize import *
from .attention import *
from .loss import *
from .splat import SplAtConv2d
from .dropblock import *

try:
    from .syncbn import *
except Exception as exc:
    class SyncBatchNorm(nn.BatchNorm2d):
        def __init__(
            self,
            num_features,
            eps=1e-5,
            momentum=0.1,
            sync=True,
            activation="none",
            slope=0.01,
            inplace=True,
        ):
            super().__init__(num_features, eps=eps, momentum=momentum, affine=True, track_running_stats=True)

    class DistSyncBatchNorm(SyncBatchNorm):
        def __init__(self, num_features, eps=1e-5, momentum=0.1, process_group=None):
            super().__init__(num_features, eps=eps, momentum=momentum)

    class BatchNorm1d(nn.BatchNorm1d):
        pass

    class BatchNorm2d(SyncBatchNorm):
        pass

    class BatchNorm3d(nn.BatchNorm3d):
        pass

try:
    from .encoding import *
except Exception as exc:
    class Encoding(nn.Module):
        def __init__(self, *args, **kwargs):
            super().__init__()
            raise RuntimeError("encoding.Encoding requires the optional torch-encoding native extension")

    class EncodingDrop(Encoding):
        pass

    class Inspiration(Encoding):
        pass

    class UpsampleConv2d(Encoding):
        pass

    class EncodingCosine(Encoding):
        pass

try:
    from .rectify import *
except Exception:
    class RFConv2d(nn.Conv2d):
        def __init__(self, *args, average_mode=False, **kwargs):
            super().__init__(*args, **kwargs)
