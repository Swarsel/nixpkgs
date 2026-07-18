{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  gnuplot,
  libxls,
  libxlsxwriter,
  libxml2,
  libzip,
  makeWrapper,
  ncurses,
  pkg-config,
  which,
  xlsSupport ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sc-im";
  version = "0.8.5";

  src = fetchFromGitHub {
    owner = "andmarti1424";
    repo = "sc-im";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-V2XwzZwn+plMxQuTCYxbeTaqdud69z77oMDDDi+7Jw0=";
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
    which
    bison
  ];

  buildInputs = [
    gnuplot
    libxml2
    libzip
    ncurses
  ]
  ++ lib.optionals xlsSupport [
    libxls
    libxlsxwriter
  ];

  makeFlags = [ "prefix=${placeholder "out"}" ];
  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-error=implicit-function-declaration";

  postInstall = ''
    wrapProgram "$out/bin/sc-im" --prefix PATH : "${lib.makeBinPath [ gnuplot ]}"
  '';

  # https://github.com/andmarti1424/sc-im/issues/884
  hardeningDisable = [ "fortify" ];
  sourceRoot = "${finalAttrs.src.name}/src";

  meta = {
    description = "Ncurses spreadsheet program for terminal";
    homepage = "https://github.com/andmarti1424/sc-im";
    changelog = "https://github.com/andmarti1424/sc-im/blob/${finalAttrs.src.rev}/CHANGES";
    license = lib.licenses.bsdOriginal;
    maintainers = with lib.maintainers; [ dotlambda ];
    platforms = lib.platforms.unix;
  };
})
