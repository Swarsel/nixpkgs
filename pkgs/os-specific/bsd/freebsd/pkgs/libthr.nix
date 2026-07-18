{
  lib,
  stdenv,
  csu,
  fetchpatch,
  include,
  libcMinimal,
  libgcc,
  libsys,
  mkDerivation,
  extraSrc ? [ ],
}:

mkDerivation {
  outputs = [
    "out"
    "man"
    "debug"
  ];

  patches = [
    # https://github.com/freebsd/freebsd-src/pull/1882
    (fetchpatch {
      hash = "sha256-WKN7dfGAs1+XADT4aLUkkKmQQ4n7gsyFUTCeo6mcuMY=";
      includes = [ "lib/libthr/thread/thr_printf.c" ];
      name = "freebsd-libthr-use-nonstring-attribute.patch";
      url = "https://github.com/freebsd/freebsd-src/pull/1882/commits/650800993deb513dc31e99ef5cdecd50ee70bb04.diff";
    })
  ];

  buildInputs = [
    libcMinimal
    include
    libgcc
    libsys
  ];

  env.MK_TESTS = "no";

  preBuild = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -B${csu}/lib"
  '';

  postInstall = lib.optionalString stdenv.hostPlatform.isStatic ''
    rm $out/lib/libpthread.so
  '';

  # Presumably newer Clang has gotten more strict.
  CWARNEXTRA = "-Wno-cast-function-type-mismatch";

  extraPaths = [
    "lib/libthread_db"
    "lib/libc" # needs /include + arch-specific files
    "lib/libsys"
    "libexec/rtld-elf"
  ]
  ++ extraSrc;

  noLibc = true;
  path = "lib/libthr";
}
