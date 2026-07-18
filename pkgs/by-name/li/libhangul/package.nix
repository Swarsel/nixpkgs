{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libhangul";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "libhangul";
    repo = "libhangul";
    tag = "libhangul-${finalAttrs.version}";
    hash = "sha256-1cTDsRJpT5TLdJN8D2LfOISWeAOlSO6zKZOaCrTxooM=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  configureFlags = [
    # detection doesn't work for cross builds
    "ac_cv_func_realloc_0_nonnull=yes"
  ];

  preAutoreconf = "./autogen.sh";

  meta = {
    description = "Core algorithm library for Korean input routines";
    homepage = "https://github.com/libhangul/libhangul";
    license = lib.licenses.lgpl21Plus;

    maintainers = with lib.maintainers; [
      ianwookim
      honnip
    ];

    platforms = lib.platforms.linux;
    mainProgram = "hangul";
  };
})
