DZT
===

[![Build Status](https://travis-ci.org/dblock/dzt.png)](https://travis-ci.org/dblock/dzt)

Slice deep-zoom tiled images to be used with [OpenSeaDragon](http://openseadragon.github.io/) or [ARTiledImageView](https://github.com/dblock/ARTiledImageView).

![](screenshots/goya.gif)

## Usage

```
gem install dzt
```

#### Get Help

```
dzt help
```

#### Tile an Image

```
dzt slice image.jpg --output tiles
```

Creates a *tiles* folder with deep-zoom tiles. This will use the defaults defined in [https://github.com/dblock/dzt/blob/master/lib/dzt/tiler.rb)(https://github.com/dblock/dzt/blob/master/lib/dzt/tiler.rb#L7-L10)

You can pass in flags to override all these options, such as:

```
dzt slice image.jpg --output=tiles --format=90 --tile-format=png
```

Additionally, you can have generated files uploaded to S3 for you. You can specify that like:

```
dzt slice image.jpg --acl=public-read --bucket=bucket --s3-key=prefix --aws-id=id --aws-secret=secret
```

The files will be uploaded to the bucket specified, and generated files will be prefixed by the s3 key.


## Contributing

See [CONTRIBUTING](CONTRIBUTING.md).

## Copyright and License

Copyright (c) 2014, Daniel Doubrovkine, [Artsy](http://artsy.github.io). Some tiling code inspired from [deep_zoom_slicer](https://github.com/meso-unimpressed/deep_zoom_slicer).

This project is licensed under the [MIT License](LICENSE.md).
