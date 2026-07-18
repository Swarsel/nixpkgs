{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  testers,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "yajl";
  version = "2.1.0-unstable-2024-02-01";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "yajl";
    rev = "6bc5219389fd2752631682b0a8368e6d8218a8c5";
    hash = "sha256-vY0tqCkz6PN00Qbip5ViO64L3C06fJ4JjFuIk0TWgCo=";
  };

  outputs = [
    "out"
    "bin"
    "dev"
  ];

  patches = [
    ./yajl-cmake4-compat.patch
  ];

  nativeBuildInputs = [ cmake ];
  doCheck = true;
  nativeCheckInputs = [ which ];

  postFixup = ''
    moveToOutput bin "''${!outputBin}"
  '';

  passthru = {
    tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;
  };

  meta = {
    description = "Yet Another JSON Library";

    longDescription = ''
      YAJL is a small event-driven (SAX-style) JSON parser written in ANSI
      C, and a small validating JSON generator.
    '';

    homepage = "http://lloyd.github.com/yajl/";
    license = lib.licenses.isc;
    platforms = with lib.platforms; linux ++ darwin;
    pkgConfigModules = [ "yajl" ];
  };
})
