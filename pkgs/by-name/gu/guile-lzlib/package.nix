{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  fetchpatch,
  guile,
  lzlib,
  pkg-config,
  texinfo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "guile-lzlib";
  version = "0.3.0";

  src = fetchurl {
    url = "https://notabug.org/guile-lzlib/guile-lzlib/archive/${finalAttrs.version}.tar.gz";
    hash = "sha256-p/mcjSoUPgXqItstyLnObCfK6UIWK0XuMBXtkCevD/I=";
  };

  patches = [
    # fix support for gcc14
    (fetchpatch {
      hash = "sha256-I1SSdygNixjx5LL/UPOgEGLILWWYKKfOGoCvXM5Sp/E=";
      url = "https://notabug.org/guile-lzlib/guile-lzlib/commit/3fd524d1f0e0b9beeca53c514620b970a762e3da.patch";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    guile
    pkg-config
    texinfo
  ];

  propagatedBuildInputs = [
    guile
    lzlib
  ];

  makeFlags = [ "GUILE_AUTO_COMPILE=0" ];
  # tests fail on darwin
  doCheck = !stdenv.hostPlatform.isDarwin;

  meta = {
    description = "GNU Guile library providing bindings to lzlib";
    homepage = "https://notabug.org/guile-lzlib/guile-lzlib";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = guile.meta.platforms;
  };
})
