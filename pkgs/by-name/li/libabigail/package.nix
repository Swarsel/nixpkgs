{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  elfutils,
  libxml2,
  pkg-config,
  python3,
  strace,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libabigail";
  version = "2.5";

  src = fetchurl {
    url = "https://mirrors.kernel.org/sourceware/libabigail/libabigail-${finalAttrs.version}.tar.xz";
    hash = "sha256-fPxOmwCuONh/sMY76rsyucv5zkEOUs7rWtWzxb6xEfM=";
  };

  outputs = [
    "bin"
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    strace
  ];

  buildInputs = [
    elfutils
    libxml2
  ];

  configureFlags = [
    "--enable-bash-completion=yes"
    "--enable-cxx11=yes"
  ];

  doCheck = true;

  nativeCheckInputs = [
    python3
  ];

  preCheck = ''
    # runtestdiffpkg needs cache directory
    export XDG_CACHE_HOME="$TEMPDIR"
    patchShebangs tests/
  '';

  enableParallelBuilding = true;

  meta = {
    description = "ABI Generic Analysis and Instrumentation Library";
    homepage = "https://sourceware.org/libabigail/";

    license = with lib.licenses; [
      asl20
      llvm-exception
    ];

    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
