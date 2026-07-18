{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  fetchpatch,
  gobject-introspection,
  gst_all_1,
  gupnp-igd,
  libnice,
  pkg-config,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "farstream";
  version = "0.2.9";

  src = fetchurl {
    url = "https://www.freedesktop.org/software/farstream/releases/farstream/farstream-${finalAttrs.version}.tar.gz";
    sha256 = "0yzlh9jf47a3ir40447s7hlwp98f9yr8z4gcm0vjwz6g6cj12zfb";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # Fix build with newer gnumake.
    (fetchpatch {
      sha256 = "02pka68p2j1wg7768rq7afa5wl9xv82wp86q7izrmwwnxdmz4zyg";
      url = "https://gitlab.freedesktop.org/farstream/farstream/-/commit/54987d44.diff";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    buildPackages.autoreconfHook269
    gobject-introspection
    python3
  ];

  buildInputs = [
    libnice
    gupnp-igd
    libnice
  ];

  propagatedBuildInputs = with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-libav
  ];

  meta = {
    description = "Audio/Video Communications Framework formely known as farsight";
    homepage = "https://www.freedesktop.org/wiki/Software/Farstream";
    license = lib.licenses.lgpl21;
    platforms = lib.platforms.unix;
  };
})
