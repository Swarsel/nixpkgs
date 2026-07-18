{
  lib,
  stdenv,
  jasper,
  libmng,
  libwebp,
  pkg-config,
  qtModule,
  qtbase,
  zlib,
}:

qtModule {
  pname = "qtsvg";
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libwebp
  ]
  ++ lib.optionals (stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    jasper
  ]
  ++ [
    libmng
    zlib
  ];

  propagatedBuildInputs = [ qtbase ];
}
