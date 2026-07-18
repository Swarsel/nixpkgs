{
  lib,
  fetchFromGitHub,
  fetchzip,
  johnny-reborn-engine,
  makeWrapper,
  stdenvNoCC,
}:

let
  sounds = fetchFromGitHub {
    hash = "sha256-rtZVCn4KbEBVwaSQ4HZhMoDEI5Q9IPj9SZywgAx0MPY=";
    owner = "nivs1978";
    repo = "Johnny-Castaway-Open-Source";
    rev = "be6afefd43a3334acc66fc9d777c162c8bfb9558";
  };

  resources = fetchzip {
    hash = "sha256-Q9chCYReOQEmkTyIkYo+D+OXYUqxPNOOEEmiFh8yaw4=";
    name = "scrantic-source";
    stripRoot = false;
    url = "https://archive.org/download/johnny-castaway-screensaver/scrantic-run.zip";
  };
in

stdenvNoCC.mkDerivation {
  inherit (johnny-reborn-engine) version;
  pname = "johnny-reborn";
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/jc_reborn/data
    cp -t $out/share/jc_reborn/data/ \
      ../scrantic-source/RESOURCE.* \
      JCOS/Resources/sound*.wav

    makeWrapper \
      ${johnny-reborn-engine}/bin/jc_reborn \
      $out/bin/jc_reborn \
      --chdir $out/share/jc_reborn

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;
  sourceRoot = sounds.name;

  srcs = [
    sounds
    resources
  ];

  meta = {
    inherit (johnny-reborn-engine.meta) homepage platforms mainProgram;
    description = "Open-source engine for the classic \"Johnny Castaway\" screensaver (ready to use, with resources)";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ pedrohlc ];
  };
}
