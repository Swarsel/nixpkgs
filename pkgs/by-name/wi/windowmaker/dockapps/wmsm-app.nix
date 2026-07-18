{
  lib,
  stdenv,
  dockapps-sources,
  libdockapp,
  libx11,
  libxext,
  libxpm,
}:

stdenv.mkDerivation (finalAttrs: {
  inherit (dockapps-sources) version src;
  pname = "wmsm.app";

  postPatch = ''
    substituteInPlace Makefile \
      --replace "PREFIX	= /usr/X11R6/bin" "" \
      --replace "/usr/bin/install" "install"
  '';

  buildInputs = [
    libx11
    libxext
    libxpm
    libdockapp
  ];

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  env.NIX_CFLAGS_COMPILE = "-std=gnu89";

  installPhase = ''
    runHook preInstall
    install -d ${placeholder "out"}/bin
    runHook postInstall
  '';

  installFlags = [
    "PREFIX=${placeholder "out"}/bin"
  ];

  sourceRoot = "${finalAttrs.src.name}/wmsm.app/wmsm";

  meta = {
    description = "System monitor for Windowmaker";
    homepage = "https://www.dockapps.net/wmsmapp";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
  };
})
