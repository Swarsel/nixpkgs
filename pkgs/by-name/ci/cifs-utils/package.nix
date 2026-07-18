{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  docutils,
  keyutils,
  libcap,
  libkrb5,
  pam,
  pkg-config,
  python3,
  samba,
  talloc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cifs-utils";
  version = "7.5";

  src = fetchurl {
    url = "https://download.samba.org/pub/linux-cifs/cifs-utils/cifs-utils-${finalAttrs.version}.tar.bz2";
    sha256 = "sha256-f6zoXj0tXrXnrb0YGt7mdZCX8TWxDW+zC+jgcK9+cFQ=";
  };

  outputs = [
    "out"
    "bin"
    "man"
    "dev"
  ];

  nativeBuildInputs = [
    autoreconfHook
    docutils
    pkg-config
  ];

  buildInputs = [
    keyutils
    libcap
    libkrb5
    pam
    python3
    samba
    talloc
  ];

  configureFlags = [
    "ROOTSBINDIR=$(bin)/sbin"
  ]
  ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    # AC_FUNC_MALLOC is broken on cross builds.
    "ac_cv_func_malloc_0_nonnull=yes"
    "ac_cv_func_realloc_0_nonnull=yes"
  ];

  meta = {
    description = "Tools for managing Linux CIFS client filesystems";
    homepage = "https://wiki.samba.org/index.php/LinuxCIFS_utils";
    license = lib.licenses.lgpl3;
    platforms = lib.platforms.linux;
  };
})
