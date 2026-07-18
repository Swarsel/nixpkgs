{
  lib,
  bsdSetupHook,
  byacc,
  csu,
  fetchpatch,
  flex,
  gencat,
  include,
  install,
  lorder,
  makeMinimal,
  mkDerivation,
  openbsdSetupHook,
  rpcgen,
  stdenvNoLibc,
  tsort,
}:

mkDerivation {
  pname = "libcMinimal-openbsd";

  outputs = [
    "out"
    "dev"
    "man"
  ];

  patches = [
    ./netbsd-make-to-lower.patch
    ./disable-librebuild.patch
    # Do not produce ctags, can do that separately.
    (fetchpatch {
      hash = "sha256-2fqabJZLUvXUIWe5WZ4NrTOwgQCXqH49Wo0hAPu5lu0=";
      name = "skip-tags.patch";
      url = "https://marc.info/?l=openbsd-tech&m=171575286706032&q=raw";
    })
  ];

  # -fret-clean requires OpenBSD-specific patches to the compiler.
  postPatch = ''
    find . -type f -exec sed -i 's/-fret-clean//g' {} \;
  '';

  nativeBuildInputs = [
    bsdSetupHook
    openbsdSetupHook
    makeMinimal
    install
    tsort
    lorder
    gencat
  ];

  buildInputs = [
    include
    csu
  ];

  makeFlags = [
    "COMPILER_VERSION=clang"
    "LIBC_TAGS=no"
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-B${csu}/lib"
    "-Wno-error"
    "-fno-builtin"
  ];

  # Suppress lld >= 16 undefined version errors
  # https://github.com/freebsd/freebsd-src/commit/2ba84b4bcdd6012e8cfbf8a0d060a4438623a638
  env.NIX_LDFLAGS = lib.optionalString (
    stdenvNoLibc.hostPlatform.linker == "lld"
  ) "--undefined-version";

  postInstall = ''
    pushd ${include}
    find include -type d -exec mkdir -p "$dev/{}" ';'
    find include '(' -type f -o -type l ')' -exec cp -pr "{}" "$dev/{}" ';'
    popd
    substituteInPlace "$dev/include/sys/time.h" --replace "defined (_LIBC)" "true"

    pushd ${csu}
    find lib -type d -exec mkdir -p "$out/{}" ';'
    find lib '(' -type f -o -type l ')' -exec cp -pr "{}" "$out/{}" ';'
    popd
  '';

  extraPaths = [
    "lib/csu/os-note-elf.h"
    "sys/arch"
  ];

  noLibc = true;
  path = "lib/libc";
  meta.platforms = lib.platforms.openbsd;
}
