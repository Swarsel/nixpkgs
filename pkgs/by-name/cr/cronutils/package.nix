{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cronutils";
  version = "1.10";

  src = fetchFromGitHub {
    owner = "google";
    repo = "cronutils";
    tag = "version/${finalAttrs.version}";
    hash = "sha256-XJksfX4jqE32l4HipvO26iv9W4c0Iss6DenlEatdL1k=";
  };

  outputs = [
    "out"
    "man"
  ];

  patches = [
    # Add missing libgen.h include. Backported from https://github.com/google/cronutils/pull/11.
    (fetchpatch {
      hash = "sha256-o1ylZ+fKL1fQYSKSOkujDsh4CUQya0wJ47uGNNC6mVQ=";
      url = "https://github.com/google/cronutils/commit/5d742fc154fc1adcfebc646dca0c45b0f0060844.patch";
    })
    # Fix function declaration without a prototype. Backported from https://github.com/google/cronutils/pull/11.
    (fetchpatch {
      hash = "sha256-og/xEWn0M7+mkbLGY14nkYpV3ckr7eYrb0X22Zxmq8w=";
      url = "https://github.com/google/cronutils/commit/c39df37c6c280e3f73ea57cfa598b8447e5a58fe.patch";
    })
    # Remove `LDLIBS+=-lrt` from Makefile. Backported from https://github.com/google/cronutils/pull/11.
    (fetchpatch {
      hash = "sha256-njftI3RbrjRtXpXKFHNE9HroIZr5tqVnEK77lu4+/sI=";
      url = "https://github.com/google/cronutils/commit/de72c648d12d102b79d4e3bb57830f2d79f5702a.patch";
    })
  ];

  makeFlags = [ "prefix=$(out)" ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isDarwin (toString [
    "-D_DARWIN_C_SOURCE"
    # runstat.c:81:81: error: format string is not a string literal
    "-Wno-format-nonliteral"
  ]);

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "version/(.*)"
    ];
  };

  meta = {
    description = "Utilities to assist running periodic batch processing jobs";
    homepage = "https://github.com/google/cronutils";
    changelog = "https://github.com/google/cronutils/releases/tag/version%2F${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ katexochen ];
    platforms = lib.platforms.all;
  };
})
