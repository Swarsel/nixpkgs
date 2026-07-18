{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libjpeg,
  libtiff,
  pkg-config,
  proj,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libgeotiff";
  version = "1.7.4";

  src = fetchFromGitHub {
    owner = "OSGeo";
    repo = "libgeotiff";
    rev = finalAttrs.version;
    hash = "sha256-oiuooLejCRI1DFTjhgYoePtKS+OAGnW6OBzgITcY500=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libtiff
    proj
    zlib
  ];

  configureFlags = [
    "--with-jpeg=${libjpeg.dev}"
    "--with-zlib=${zlib.dev}"
  ];

  sourceRoot = "${finalAttrs.src.name}/libgeotiff";

  #hardeningDisable = [ "format" ];
  meta = {
    description = "Library implementing attempt to create a tiff based interchange format for georeferenced raster imagery";
    homepage = "https://github.com/OSGeo/libgeotiff";
    changelog = "https://github.com/OSGeo/libgeotiff/blob/${finalAttrs.src.rev}/libgeotiff/NEWS";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = with lib.platforms; linux ++ darwin;
    teams = [ lib.teams.geospatial ];
  };
})
