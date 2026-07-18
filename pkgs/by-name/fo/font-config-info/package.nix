{
  lib,
  stdenv,
  fetchFromGitHub,
  gtk3,
  pkg-config,
  xsettingsd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "font-config-info";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "derat";
    repo = "font-config-info";
    rev = "v${finalAttrs.version}";
    sha256 = "14z7hg9c7q8wliyqv68kp080mmk2rh6kpww6pn87hy7lwq20l2b7";
  };

  postPatch = ''
    substituteInPlace font-config-info.c --replace "dump_xsettings |" "${xsettingsd}/bin/dump_xsettings |"
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    gtk3
    xsettingsd
  ];

  installPhase = ''
    runHook preInstall
    install -D -t $out/bin font-config-info
    runHook postInstall
  '';

  meta = {
    description = "Prints a Linux system's font configuration";
    homepage = "https://github.com/derat/font-config-info";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ romildo ];
    platforms = lib.platforms.unix;
    mainProgram = "font-config-info";
  };
})
