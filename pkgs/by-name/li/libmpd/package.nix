{
  lib,
  stdenv,
  fetchurl,
  doxygen,
  glib,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libmpd";
  version = "11.8.17";

  src = fetchurl {
    url = "https://www.musicpd.org/download/libmpd/${finalAttrs.version}/libmpd-${finalAttrs.version}.tar.gz";
    hash = "sha256-/iAyaw0QZB9xxGc/rmN7+SIqluFxL3HxcPyi/DS/eoM=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  nativeBuildInputs = [
    pkg-config
    doxygen
  ];

  buildInputs = [
    glib
  ];

  # Fix GCC 14 build
  # https://hydra.nixos.org/build/281958201/nixlog/3
  env.NIX_CFLAGS_COMPILE = "-Wno-error=int-conversion";

  postInstall = ''
    make doc
    mkdir -p $devdoc/share/devhelp/libmpd
    cp -r doc/html $devdoc/share/devhelp/libmpd/doxygen
  '';

  meta = {
    description = "Higher level access to MPD functions";
    homepage = "https://www.musicpd.org/download/libmpd/";
    changelog = "https://www.musicpd.org/download/libmpd/${finalAttrs.version}/README";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ doronbehar ];
    platforms = lib.platforms.all;
    # Getting DARWIN_NULL related errors
    broken = stdenv.hostPlatform.isDarwin;
  };
})
