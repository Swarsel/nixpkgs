{
  lib,
  jasper,
  libmng,
  libtiff,
  libwebp,
  qtModule,
  qtbase,
}:

qtModule {
  pname = "qtimageformats";

  propagatedBuildInputs = [
    qtbase
    libwebp
  ]
  ++ lib.optionals (!jasper.meta.broken) [
    jasper
  ]
  ++ [
    libmng
    libtiff
  ];
}
