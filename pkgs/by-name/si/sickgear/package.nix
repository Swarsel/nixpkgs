{
  lib,
  stdenv,
  fetchFromGitHub,
  libarchive,
  makeWrapper,
  python3,
}:

let
  pythonEnv = python3.withPackages (
    ps: with ps; [
      cheetah3
      lxml
    ]
  );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sickgear";
  version = "3.34.13";

  src = fetchFromGitHub {
    owner = "SickGear";
    repo = "SickGear";
    tag = "release_${finalAttrs.version}";
    hash = "sha256-jOQktr7KG/C/ap/cLGMCwWnceirGo3TuwxXNewE5I78=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    pythonEnv
    libarchive
  ];

  doCheck = false;

  installPhase = ''
    mkdir -p $out/bin $out/opt/sickgear
    cp -R {autoProcessTV,gui,lib,sickgear,sickgear.py} $out/opt/sickgear/

    makeWrapper $out/opt/sickgear/sickgear.py $out/bin/sickgear \
      --suffix PATH : ${lib.makeBinPath [ libarchive ]}
  '';

  dontBuild = true;

  meta = {
    description = "Most reliable stable TV fork of the great Sick-Beard to fully automate TV enjoyment with innovation";
    homepage = "https://github.com/SickGear/SickGear";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ rembo10 ];
    mainProgram = "sickgear";
  };
})
