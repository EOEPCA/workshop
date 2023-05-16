import click
import pystac
import rio_stac
import shutil
import os


@click.command(
    short_help="Creates a STAC catalog",
    help="Creates a STAC catalog with the water bodies",
)
@click.option(
    "--input-item",
    "item_urls",
    help="STAC Item URL",
    required=True,
    multiple=True,
)
@click.option(
    "--water-body",
    "water_bodies",
    help="Water body geotiff",
    required=True,
    multiple=True,
)
def to_stac(item_urls, water_bodies):

    cat = pystac.Catalog(id="catalog", description="water-bodies")

    for index, item_url in enumerate(item_urls):

        item = pystac.read_file(item_url)
        water_body = water_bodies[index]

        os.mkdir(item.id)
        shutil.copy(water_body, item.id)

        out_item = rio_stac.stac.create_stac_item(
            source=water_body,
            input_datetime=item.datetime,
            id=item.id,
            asset_roles=["data", "visual"],
            asset_href=os.path.basename(water_body),
            asset_name="data",
            with_proj=True,
            with_raster=False,
        )

        cat.add_items([out_item])

    cat.normalize_and_save(
        root_href="./", catalog_type=pystac.CatalogType.SELF_CONTAINED
    )

    # for index, water_body in enumerate(water_bodies):
    #     item = pystac.read_file(item_urls[index])

    #     shutil.copy(water_body, item.id)


if __name__ == "__main__":
    to_stac()
