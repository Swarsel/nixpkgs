{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  expat,
  fetchDebianPatch,
  glib,
  libjack2,
  libpng,
  libpthread-stubs,
  libsmf,
  libsndfile,
  libx11,
  libxext,
  lv2,
  pkg-config,
  zita-resampler,
}:

stdenv.mkDerivation rec {
  pname = "drumgizmo";
  version = "0.9.20";

  src = fetchurl {
    url = "https://www.drumgizmo.org/releases/${pname}-${version}/${pname}-${version}.tar.gz";
    sha256 = "sha256-AF8gQLiB29j963uI84TyNHIC0qwEWOCqmZIUWGq8V2o=";
  };

  patches = [
    (fetchDebianPatch {
      pname = "drumgizmo";
      version = "0.9.20";
      debianRevision = "3";
      hash = "sha256-y5NDZ+3t6GkBeF/5UY8dwtH8k0cuM+5SGBGPSV7AX7M=";
      patch = "0005-fix_ftbfs_with_gcc13.patch";
    })
    ./fix-non-ascii.patch
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    alsa-lib
    expat
    glib
    libjack2
    libxext
    libx11
    libpng
    libpthread-stubs
    libsmf
    libsndfile
    lv2
    zita-resampler
  ];

  configureFlags = [ "--enable-lv2" ];

  meta = {
    description = "LV2 sample based drum plugin";
    homepage = "https://www.drumgizmo.org";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ lib.maintainers.nico202 ];
    platforms = lib.platforms.linux;
  };
}
