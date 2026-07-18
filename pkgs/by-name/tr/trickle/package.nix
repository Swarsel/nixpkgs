{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libevent,
  libtirpc,
}:

stdenv.mkDerivation {
  pname = "trickle";
  version = "1.07-unstable-2019-10-03";

  src = fetchFromGitHub {
    owner = "mariusae";
    repo = "trickle";
    rev = "09a1d955c6554eb7e625c99bf96b2d99ec7db3dc";
    sha256 = "sha256-cqkNPeTo+noqMCXsxh6s4vKoYwsWusafm/QYX8RvCek=";
  };

  patches = [
    ./trickle-gcc14.patch
    ./atomicio.patch
    ./remove-libtrickle.patch
  ];

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    libevent
    libtirpc
  ];

  configureFlags = [ "--with-libevent" ];

  env = {
    NIX_CFLAGS_COMPILE = toString [
      "-I${libtirpc.dev}/include/tirpc"
      "-Wno-error=incompatible-pointer-types"
    ];

    NIX_LDFLAGS = toString [
      "-levent"
      "-ltirpc"
    ];
  };

  preBuild = ''
    sed -i '/#define in_addr_t/ s:^://:' config.h
    sed -i 's|^_select(int|select(int|' trickle-overload.c
  '';

  hardeningDisable = [ "format" ];

  preAutoreconf = ''
    sed -i -e 's|\s*LIBCGUESS=.*|LIBCGUESS=${stdenv.cc.libc}/lib/libc.so.*|' configure.in
    grep LIBCGUESS configure.in
    sed -i 's|libevent.a|libevent.so|' configure.in
  '';

  meta = {
    description = "Lightweight userspace bandwidth shaper";
    homepage = "https://monkey.org/~marius/pages/?page=trickle";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    mainProgram = "trickle";
  };
}
