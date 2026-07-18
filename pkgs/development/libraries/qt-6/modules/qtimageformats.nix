{
  jasper,
  libmng,
  libtiff,
  libwebp,
  qtModule,
  qtbase,
}:

qtModule {
  pname = "qtimageformats";

  buildInputs = [
    libwebp
    jasper
    libmng
    libtiff
  ];

  propagatedBuildInputs = [ qtbase ];
}
