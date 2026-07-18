{
  lib,
  stdenv,
  autoreconfHook,
  avahi,
  buildPackages,
  fetchgit,
  gmp,
  guile,
  pkg-config,
  texinfo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "guile-avahi";
  version = "0.4.1";

  src = fetchgit {
    url = "git://git.sv.gnu.org/guile-avahi.git";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Yr+OiqaGv6DgsjxSoc4sAjy4OO/D+Q50vdSTPEeIrV8=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    guile
    pkg-config
    texinfo
  ];

  buildInputs = [ guile ];

  propagatedBuildInputs = [
    avahi
    gmp
  ];

  makeFlags = [ "GUILE_AUTO_COMPILE=0" ];
  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isDarwin "-Wno-unused-function";
  doCheck = true;
  depsBuildBuild = [ buildPackages.stdenv.cc ];

  meta = {
    description = "Bindings to Avahi for GNU Guile";
    homepage = "https://www.nongnu.org/guile-avahi/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = guile.meta.platforms;
  };
})
