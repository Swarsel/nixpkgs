{
  lib,
  stdenv,
  fetchFromGitLab,
  coreutils-full,
  gnugrep,
  gnused,
  libuv,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dps8m";
  version = "3.1.0";

  src = fetchFromGitLab {
    owner = "dps8m";
    repo = "dps8m";
    rev = "R${finalAttrs.version}";
    hash = "sha256-2PTL9C1sV+UTZibjyxBkQh9Y1xqwawNPwWL4eX0ilvU=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    coreutils-full
    pkg-config
  ];

  buildInputs = [
    libuv
  ];

  env = {
    ENV = "${coreutils-full}/bin/env";
    GREP = "${gnugrep}/bin/grep";
    PREFIX = placeholder "out";
    SED = "${gnused}/bin/sed";
  };

  meta = {
    description = "GE / Honeywell / Bull DPS-8/M mainframe simulator";
    homepage = "https://gitlab.com/dps8m/dps8m";
    changelog = "https://gitlab.com/dps8m/dps8m/-/wikis/DPS8M-${finalAttrs.src.rev}-Release-Notes";
    license = lib.licenses.icu;

    maintainers = with lib.maintainers; [
      matthewcroughan
      sarcasticadmin
    ];

    platforms = lib.platforms.all;
    mainProgram = "dps8m";
  };
})
