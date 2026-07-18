{
  lib,
  buildPecl,
  fetchpatch,
  pkg-config,
  rrdtool,
}:

buildPecl {
  pname = "rrd";
  version = "2.0.3";

  patches = [
    # PHP 8.5 compatibility patch
    (fetchpatch {
      hash = "sha256-ES+cMhMBUubFB5TpTZzzKKfEK2cY737z7zCuNy4XF8Y=";
      url = "https://github.com/php/pecl-processing-rrd/pull/4/commits/dd4856dc89499a0141b1710e791f0e1096c7b244.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    rrdtool
  ];

  # Fix GCC 14 build.
  # from incompatible pointer type [-Wincompatible-pointer-types
  env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";
  hash = "sha256-pCFh5YzcioU7cs/ymJidy96CsPdkVt1ZzgKFTJK3MPc=";

  meta = {
    description = "PHP bindings to RRD tool system";
    homepage = "https://github.com/php/pecl-processing-rrd";
    license = lib.licenses.bsd0;
  };
}
