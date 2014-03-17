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

Creates a *tiles* folder with deep-zoom tiles.


## Contributing

See [CONTRIBUTING](CONTRIBUTING.md).

## Copyright and License

Copyright (c) 2014, Daniel Doubrovkine, [Artsy](http://artsy.github.io). Some tiling code inspired from [deep_zoom_slicer](https://github.com/meso-unimpressed/deep_zoom_slicer).

This project is licensed under the [MIT License](LICENSE.md).
