{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fetchpatch,
  libpcap,
  mbedtls,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vde2";
  version = "2.3.3";

  src = fetchFromGitHub {
    owner = "virtualsquare";
    repo = "vde-2";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-Yf6QB7j5lYld2XtqhYspK4037lTtimoFc7nCavCP+mU=";
  };

  patches = [
    # See: <https://github.com/virtualsquare/vde-2/issues/69>
    (fetchpatch {
      hash = "sha256-cq3yrA3w/K6J+RtwYX9AcG/nfctlAkc3aYJZpJxJXTQ=";
      name = "vde2-backport-mbedtls-support.patch";
      url = "https://github.com/virtualsquare/vde-2/commit/e3f701978a0a20e56cd9829353d110d4ddcedd90.patch";
    })

    (fetchpatch {
      sha256 = "0b5382v541bkxhqylilcy34bh83ag96g71f39m070jzvi84kx8af";
      url = "https://git.alpinelinux.org/aports/plain/main/vde2/musl-build-fix.patch?id=ddee2f86a48e087867d4a2c12849b2e3baccc238";
    })
  ];

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [
    libpcap
    mbedtls
  ];

  configureFlags = [
    "--with-crypt=mbedtls"
  ];

  # Fix build with gcc15
  # https://github.com/virtualsquare/vde-2/commit/fedcb99c5f44c397f459ed0951a8fba4f4effb73
  env.NIX_CFLAGS_COMPILE = "-std=gnu17";

  meta = {
    description = "Virtual Distributed Ethernet, an Ethernet compliant virtual network";
    homepage = "https://github.com/virtualsquare/vde-2";

    license = [
      # Effectively `lib.licenses.gpl2Only`, but file headers differ.
      lib.licenses.gpl2Plus
      lib.licenses.gpl2Only
      # libvdeplug and code copied from glibc.
      lib.licenses.lgpl21Plus
    ];

    platforms = lib.platforms.unix;
  };
})
