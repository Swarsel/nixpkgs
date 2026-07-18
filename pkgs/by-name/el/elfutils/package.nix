{
  lib,
  stdenv,
  fetchurl,
  argp-standalone,
  bison,
  bzip2,
  curl,
  fetchpatch,
  flex,
  gettext,
  gitUpdater,
  json_c,
  libarchive,
  libmicrohttpd,
  m4,
  musl-fts,
  musl-obstack,
  pkg-config,
  setupDebugInfoDirs,
  sqlite,
  xz,
  zlib,
  zstd,
  enableDebuginfod ? lib.meta.availableOn stdenv.hostPlatform libarchive,
}:

# TODO: Look at the hardcoded paths to kernel, modules etc.
stdenv.mkDerivation (finalAttrs: {
  pname = "elfutils";
  version = "0.195";

  src = fetchurl {
    url = "https://sourceware.org/elfutils/ftp/${finalAttrs.version}/elfutils-${finalAttrs.version}.tar.bz2";
    hash = "sha256-N2Kf338fPcKBjhOPyiuAlBd9bC0PcB07tlClYSGNwCY=";
  };

  outputs = [
    "bin"
    "dev"
    "out"
    "man"
  ];

  patches = [
    ./debug-info-from-env.patch
    (fetchpatch {
      name = "fix-aarch64_fregs.patch";
      sha256 = "zvncoRkQx3AwPx52ehjA2vcFroF+yDC2MQR5uS6DATs=";
      url = "https://git.alpinelinux.org/aports/plain/main/elfutils/fix-aarch64_fregs.patch?id=2e3d4976eeffb4704cf83e2cc3306293b7c7b2e9";
    })
    (fetchpatch {
      name = "musl-asm-ptrace-h.patch";
      sha256 = "8D1wPcdgAkE/TNBOgsHaeTZYhd9l+9TrZg8d5C7kG6k=";
      url = "https://git.alpinelinux.org/aports/plain/main/elfutils/musl-asm-ptrace-h.patch?id=2e3d4976eeffb4704cf83e2cc3306293b7c7b2e9";
    })
    (fetchpatch {
      name = "musl-macros.patch";
      sha256 = "tp6O1TRsTAMsFe8vw3LMENT/vAu6OmyA8+pzgThHeA8=";
      url = "https://git.alpinelinux.org/aports/plain/main/elfutils/musl-macros.patch?id=2e3d4976eeffb4704cf83e2cc3306293b7c7b2e9";
    })
    (fetchpatch {
      name = "musl-strndupa.patch";
      sha256 = "sha256-7daehJj1t0wPtQzTv+/Rpuqqs5Ng/EYnZzrcf2o/Lb0=";
      url = "https://git.alpinelinux.org/aports/plain/main/elfutils/musl-strndupa.patch?id=2e3d4976eeffb4704cf83e2cc3306293b7c7b2e9";
    })
    (fetchpatch {
      hash = "sha256-N7DL2FG1AWLc+hcnxGMbUl5TuieoAc9OD6gc0sbsiGI=";
      name = "fix-i386_tlsdesc_relocation.patch";
      url = "https://sourceware.org/git/?p=elfutils.git;a=patch;h=bfd519cc58e190544a6785d3f0a27fcfaf7d8da3";
    })
  ]
  ++ lib.optionals stdenv.hostPlatform.isMusl [ ./musl-error_h.patch ];

  postPatch = ''
    patchShebangs tests/*.sh
  ''
  + lib.optionalString stdenv.hostPlatform.isRiscV ''
    # disable failing test:
    #
    # > dwfl_thread_getframes: No DWARF information found
    sed -i s/run-backtrace-dwarf.sh//g tests/Makefile.in
  '';

  # We need bzip2 in NativeInputs because otherwise we can't unpack the src,
  # as the host-bzip2 will be in the path.
  nativeBuildInputs = [
    m4
    bison
    flex
    gettext
    bzip2
    pkg-config
  ];

  buildInputs = [
    zlib
    zstd
    bzip2
    xz
  ]
  ++ lib.optionals stdenv.hostPlatform.isMusl [
    argp-standalone
    musl-fts
    musl-obstack
  ]
  ++ lib.optionals enableDebuginfod [
    sqlite
    curl
    json_c
    libmicrohttpd
    libarchive
  ];

  configureFlags = [
    "--program-prefix=eu-" # prevent collisions with binutils
    "--enable-deterministic-archives"
    (lib.enableFeature enableDebuginfod "libdebuginfod")
    (lib.enableFeature enableDebuginfod "debuginfod")

    # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=101766
    # Versioned symbols are nice to have, but we can do without.
    (lib.enableFeature (!stdenv.hostPlatform.isMicroBlaze) "symbol-versioning")
  ]
  ++ lib.optional (stdenv.targetPlatform.useLLVM or false) "--disable-demangler";

  doCheck =
    # Backtrace unwinding tests rely on glibc-internal symbol names.
    # Musl provides slightly different forms and fails.
    # Let's disable tests there until musl support is fully upstreamed.
    !stdenv.hostPlatform.isMusl
    # Test suite tries using `uname` to determine whether certain tests
    # can be executed, so we need to match build and host platform exactly.
    && (stdenv.hostPlatform == stdenv.buildPlatform);

  doInstallCheck = !stdenv.hostPlatform.isMusl && (stdenv.hostPlatform == stdenv.buildPlatform);
  enableParallelBuilding = true;
  hardeningDisable = [ "strictflexarrays3" ];
  propagatedNativeBuildInputs = [ setupDebugInfoDirs ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "elfutils-";
    url = "https://sourceware.org/git/elfutils.git";
  };

  meta = {
    description = "Set of utilities to handle ELF objects";
    homepage = "https://sourceware.org/elfutils/";

    # licenses are GPL2 or LGPL3+ for libraries, GPL3+ for bins,
    # but since this package isn't split that way, all three are listed.
    license = with lib.licenses; [
      gpl2Only
      lgpl3Plus
      gpl3Plus
    ];

    maintainers = with lib.maintainers; [ r-burns ];
    platforms = lib.platforms.linux;
    # https://lists.fedorahosted.org/pipermail/elfutils-devel/2014-November/004223.html
    badPlatforms = [ lib.systems.inspect.platformPatterns.isStatic ];
    identifiers.cpeParts = lib.meta.cpeFullVersionWithVendor "elfutils_project" finalAttrs.version;
  };
})
