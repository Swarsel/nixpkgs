{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libunibreak";
  version = "7.0";

  src =
    let
      rev_version = lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version;
    in
    fetchFromGitHub {
      owner = "adah1972";
      repo = "libunibreak";
      tag = "libunibreak_${rev_version}";
      hash = "sha256-J+/L5pFudppf0l0Gk/6/Rwz5I59p9Aw11cUEPRPGP/8=";
    };

  nativeBuildInputs = [ autoreconfHook ];

  meta = {
    description = "Implementation of line breaking and word breaking algorithms as in the Unicode standard";
    homepage = "https://github.com/adah1972/libunibreak";
    changelog = "https://github.com/adah1972/libunibreak/blob/${finalAttrs.src.tag}/NEWS";
    license = lib.licenses.zlib;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
