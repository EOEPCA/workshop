"""
Run this on a Terminal:

mamba create -c conda-forge -y -p /srv/conda/envs/env_crop  gdal click pystac 
mamba create -c conda-forge -y -p /srv/conda/envs/env_norm_diff click gdal  
mamba create -c conda-forge -y -p /srv/conda/envs/env_otsu gdal scikit-image click 
mamba create -c conda-forge -y -p /srv/conda/envs/env_stac click pystac python=3.9 pip && \
    /srv/conda/envs/env_stac/bin/pip install rio_stac
mamba clean --all -f -y
"""


from cwltool.main import main
import json
import pystac
from io import StringIO

workflow_id = "water_bodies"

params = [
            "--stac_items", 
            "https://earth-search.aws.element84.com/v0/collections/sentinel-s2-l2a-cogs/items/S2B_10TFK_20210713_0_L2A",
            "--stac_items", 
            "https://earth-search.aws.element84.com/v0/collections/sentinel-s2-l2a-cogs/items/S2A_10TFK_20220524_0_L2A",
            "--aoi=-121.399,39.834,-120.74,40.472",
            "--epsg",
            "EPSG:4326"
        ]

args = []

args.extend(["--no-container"])
args.append(f"water-bodies/app-package.cwl#{workflow_id}")

stream = StringIO()

res = main(
    [ *args, *params],
#     stdout=stream,
)

assert(res == 0)

stdout = json.loads(stream.getvalue())

for entry in stdout["stac_catalog"]["listing"]:
    if "catalog.json" in entry["basename"]:
        catalog = pystac.read_file(entry["path"])
        break

catalog.describe()