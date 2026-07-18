{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  fetchpatch,
  nano,
  texinfo,
}:

let
  version = "1.12.13";
  debianRevision = "real-30";
in

stdenv.mkDerivation {
  pname = "cvs";
  version = "${version}+${debianRevision}";

  src = fetchurl {
    url = "mirror://savannah/cvs/source/feature/${version}/cvs-${version}.tar.bz2";
    sha256 = "0pjir8cwn0087mxszzbsi1gyfc6373vif96cw4q3m1x6p49kd1bq";
  };

  patches = [
    ./getcwd-chroot.patch
    (fetchpatch {
      sha256 = "1ql6aaia7xkfq3vqhlw5bd2z2ywka82zk01njs1b2szn699liymg";
      url = "https://raw.githubusercontent.com/Homebrew/formula-patches/24118ec737c7/cvs/vasnprintf-high-sierra-fix.diff";
    })
    # Debian Patchset,
    # contains patches for CVE-2017-12836 and CVE-2012-0804 among other things
    (fetchurl {
      sha256 = "085124619dfdcd3e53c726e049235791b67dcb9f71619f1e27c5f1cbdef0063e";
      url = "http://deb.debian.org/debian/pool/main/c/cvs/cvs_1.12.13+${debianRevision}.diff.gz";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    texinfo
  ];

  configureFlags = [
    "--with-editor=${nano}/bin/nano"

    # Required for cross-compilation.
    "cvs_cv_func_printf_ptr=yes"
  ]
  ++ lib.optionals (stdenv.hostPlatform.libc == "glibc") [
    # So that fputs_unlocked is defined
    "CFLAGS=-D_GNU_SOURCE"
  ];

  makeFlags = [
    "AR=${stdenv.cc.targetPrefix}ar"
  ]
  ++ lib.optionals (!stdenv.cc.bintools.isGNU) [
    # Don't pass --as-needed to linkers that don't support it
    # (introduced in debian patchset)
    "cvs_LDFLAGS="
  ];

  # Fix build with gcc15
  # https://savannah.nongnu.org/bugs/index.php?66726
  env.NIX_CFLAGS_COMPILE = "-std=gnu17";
  doCheck = false; # fails 1 of 1 tests

  hardeningDisable = [
    "fortify"
    "format"
  ];

  meta = {
    description = "Concurrent Versions System - a source control system";
    homepage = "http://cvs.nongnu.org";
    license = lib.licenses.gpl2Plus; # library is GPLv2, main is GPLv1
    platforms = lib.platforms.all;
  };
}
