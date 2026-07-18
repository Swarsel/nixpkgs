{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  nixosTests,
  writeText,
}:

stdenv.mkDerivation rec {
  pname = "limesurvey";
  version = "6.15.14+250924";

  src = fetchFromGitHub {
    owner = "LimeSurvey";
    repo = "LimeSurvey";
    tag = version;
    hash = "sha256-xxK6JEgeBVIj8CGb0qSzwfO1Se9+jMtGB9V3rsc9bBU=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/limesurvey
    cp -r . $out/share/limesurvey
    cp ${phpConfig} $out/share/limesurvey/application/config/config.php

    runHook postInstall
  '';

  phpConfig = writeText "config.php" ''
    <?php
      return require(getenv('LIMESURVEY_CONFIG'));
    ?>
  '';

  passthru = {
    tests = { inherit (nixosTests) limesurvey; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Open source survey application";
    homepage = "https://www.limesurvey.org";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = with lib.platforms; unix;
  };
}
