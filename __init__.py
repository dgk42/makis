__version__ = "1.0.0"

__author__ = "r00t"

import os
import sys
makis_path = os.path.abspath(os.path.join(__path__[0], "Makis"))
if os.path.isdir(makis_path):
	if makis_path not in __path__:
		__path__.append(makis_path)
	if makis_path not in sys.path:
		sys.path.append(makis_path)
from Makis import *
