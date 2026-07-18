{
  lib,
  fetchFromGitHub,
  autoreconfHook,
  sbcl,
  stdenvNoCC,
  texinfo,
}:

let
  sbclWithPkgs = sbcl.withPackages (
    ps: with ps; [
      alexandria
      cl-ppcre
      clx
      fiasco
    ]
  );
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "stumpwm";
  version = "24.11";

  src = fetchFromGitHub {
    owner = "stumpwm";
    repo = "stumpwm";
    tag = "${finalAttrs.version}";
    hash = "sha256-Ba2HcAmNcZvnqU0jpLTxsBe8L+4aHbO/oM4Bp/IYEC0=";
  };

  nativeBuildInputs = [
    autoreconfHook
    sbclWithPkgs
    texinfo
  ];

  postConfigure = ''
    export ASDF_OUTPUT_TRANSLATIONS=$(pwd):$(pwd)
  '';

  doCheck = true;

  meta = {
    description = "Tiling, keyboard driven window manager";
    homepage = "https://stumpwm.github.io/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "stumpwm";
    teams = [ lib.teams.lisp ];
  };
})
