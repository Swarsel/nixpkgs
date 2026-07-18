{
  lib,
  stdenv,
  fetchurl,
  coreutils,
  gnugrep,
  perl,
  replaceVars,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "likwid";
  version = "5.5.1";

  src = fetchurl {
    url = "https://ftp.fau.de/pub/likwid/likwid-${finalAttrs.version}.tar.gz";
    hash = "sha256-JceDDmOyA5b8/DsWrnnDm0IgqG03bOt81pSbX/mR23g=";
  };

  patches = [
    ./nosetuid.patch
    (replaceVars ./cat-grep-sort-wc.patch {
      coreutils = "${coreutils}/bin/";
      gnugrep = "${gnugrep}/bin/";
    })
  ];

  postPatch = "patchShebangs bench/ perl/";
  nativeBuildInputs = [ perl ];
  makeFlags = [ "PREFIX=$(out)" ];
  hardeningDisable = [ "format" ];

  meta = {
    description = "Performance monitoring and benchmarking suite";
    homepage = "https://hpc.fau.de/research/tools/likwid/";
    changelog = "https://github.com/RRZE-HPC/likwid/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.vbgl ];
    # Might work on ARM by appropriately setting COMPILER in config.mk
    platforms = lib.intersectLists lib.platforms.linux lib.platforms.x86;
    mainProgram = "likwid-perfctr";
  };
})
