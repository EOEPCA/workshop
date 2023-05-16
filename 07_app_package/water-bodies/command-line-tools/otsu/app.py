from skimage.filters import threshold_otsu
import click
from osgeo import gdal
import numpy as np


def threshold(data):

    return data > threshold_otsu(data[np.isfinite(data)])


@click.command(
    short_help="Otsu threshoold",
    help="Applies the Otsu threshold",
)
@click.argument("raster", nargs=1)
def otsu(raster):

    ds = gdal.Open(raster)

    driver = gdal.GetDriverByName("GTiff")

    dst_ds = driver.Create(
        "otsu.tif",
        ds.RasterXSize,
        ds.RasterYSize,
        1,
        gdal.GDT_Byte,
        options=["TILED=YES", "COMPRESS=DEFLATE", "INTERLEAVE=BAND"],
    )

    dst_ds.SetGeoTransform(ds.GetGeoTransform())
    dst_ds.SetProjection(ds.GetProjectionRef())

    array = ds.GetRasterBand(1).ReadAsArray().astype(float)

    dst_ds.GetRasterBand(1).WriteArray(threshold(array))
    dst_ds.GetRasterBand(1).SetNoDataValue(0)

    dst_ds = None
    ds = None


if __name__ == "__main__":
    otsu()
