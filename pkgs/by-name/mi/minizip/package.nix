{
  lib,
  stdenv,
  autoreconfHook,
  fetchpatch,
  zlib,
}:

stdenv.mkDerivation {
  inherit (zlib) src version;
  pname = "minizip";

  patches = [
    # install missing header for qtwebengine:
    #   https://github.com/madler/zlib/pull/1178
    (fetchpatch {
      hash = "sha256-eX06nYLRPqpkbBAOso1ynGDYs9dcRAI14cG89qXuUzo=";
      name = "add-int.h.patch";
      url = "https://github.com/madler/zlib/commit/cb14dc9ade3759352417a300e6c2ed73268f1d97.patch";
    })
  ];

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ zlib ];
  patchFlags = [ "-p3" ];
  sourceRoot = "zlib-${zlib.version}/contrib/minizip";

  meta = {
    inherit (zlib.meta) license homepage;
    description = "Compression library implementing the deflate compression method found in gzip and PKZIP";
    platforms = lib.platforms.unix;
  };
}
