{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  gawk,
  gnugrep,
  makeWrapper,
  procps,
  xdotool,
  xprop,
  xwininfo,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tdrop";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "noctuid";
    repo = "tdrop";
    rev = finalAttrs.version;
    sha256 = "sha256-fHvGXaZL7MMvTnkap341B79PDDo2lOVPPcOH4AX/zXo=";
  };

  nativeBuildInputs = [ makeWrapper ];

  postInstall =
    let
      binPath = lib.makeBinPath [
        xwininfo
        xdotool
        xprop
        gawk
        coreutils
        gnugrep
        procps
      ];
    in
    ''
      wrapProgram $out/bin/tdrop --prefix PATH : ${binPath}
    '';

  dontBuild = true;
  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Glorified WM-Independent Dropdown Creator";
    homepage = "https://github.com/noctuid/tdrop";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "tdrop";
  };
})
