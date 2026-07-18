{
  lib,
  stdenv,
  fetchurl,
  htslib,
  perl,
  zlib,
  ncurses ? null,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "samtools";
  version = "1.22.1";

  src = fetchurl {
    url = "https://github.com/samtools/samtools/releases/download/${finalAttrs.version}/samtools-${finalAttrs.version}.tar.bz2";
    hash = "sha256-Aqpc0LpS4GwggAVOBZ19d6iF3+lxfDHNid/npAR+2g4=";
  };

  nativeBuildInputs = [ perl ];

  buildInputs = [
    zlib
    ncurses
    htslib
  ];

  configureFlags = [
    "--with-htslib=${htslib}"
  ]
  ++ lib.optional (ncurses == null) "--without-curses"
  ++ lib.optionals stdenv.hostPlatform.isStatic [ "--without-curses" ];

  makeFlags = lib.optional stdenv.hostPlatform.isStatic "AR=${stdenv.cc.targetPrefix}ar";

  preConfigure = lib.optional stdenv.hostPlatform.isStatic ''
    export LIBS="-lz -lbz2 -llzma"
  '';

  doCheck = true;
  # tests require `bgzip` from the htslib package
  nativeCheckInputs = [ htslib ];

  preCheck = ''
    patchShebangs test/
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Tools for manipulating SAM/BAM/CRAM format";
    homepage = "http://www.htslib.org/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      mimame
      unode
    ];

    platforms = lib.platforms.unix;
  };
})
