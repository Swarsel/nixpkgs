{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  ncurses,
  openssl,
  popt,
  python3,
  readline,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "OpenIPMI";
  version = "2.0.37";

  src = fetchurl {
    url = "mirror://sourceforge/openipmi/OpenIPMI-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-xi049dp99Cmaw6ZSUI6VlTd1JEAYHjTHayrs69fzAbk=";
  };

  outputs = [
    "out"
    "lib"
    "dev"
    "man"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    python3
  ];

  buildInputs = [
    ncurses
    popt
    python3
    readline
    openssl
  ];

  makeFlags = [
    "BUILD_CC=${stdenv.cc.targetPrefix}cc"
  ];

  postConfigure = lib.optionalString (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    substituteInPlace lanserv/Makefile \
      --replace-fail "sdrcomp/sdrcomp_build -o" "${buildPackages.openipmi}/bin/sdrcomp -o"
  '';

  meta = {
    description = "User-level library that provides a higher-level abstraction of IPMI and generic services";
    homepage = "https://openipmi.sourceforge.io/";

    license = with lib.licenses; [
      gpl2Only
      lgpl2Only
    ];

    maintainers = with lib.maintainers; [ arezvov ];
    platforms = lib.platforms.linux;
  };
})
