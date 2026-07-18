{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libtool,
  pkg-config,
  re2,
  texinfo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cre2";
  version = "0.3.6";

  src = fetchFromGitHub {
    owner = "marcomaggi";
    repo = "cre2";
    rev = "v${finalAttrs.version}";
    sha256 = "1h9jwn6z8kjf4agla85b5xf7gfkdwncp0mfd8zwk98jkm8y2qx9q";
  };

  patches = [
    ./missing-header-include-pr-34.patch
  ];

  nativeBuildInputs = [
    autoreconfHook
    libtool
    pkg-config
  ];

  buildInputs = [
    re2
    texinfo
  ];

  configureFlags = [
    "--enable-maintainer-mode"
  ];

  env.NIX_LDFLAGS = toString [
    "-lre2"
    "-lpthread"
  ];

  meta = {
    description = "C Wrapper for RE2";
    homepage = "http://marcomaggi.github.io/docs/cre2.html";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.all;
  };
})
