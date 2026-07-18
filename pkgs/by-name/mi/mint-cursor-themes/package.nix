{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "mint-cursor-themes";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "mint-cursor-themes";
    # They don't really do tags, this is just a named commit.
    rev = "d2c1428b499a347c291dafb13c89699fdbdd4be7";
    hash = "sha256-i2Wf+OKwal9G5hkcAdmGSgX6txu1AHajqqPJdhpJoA0=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    mv usr/share $out

    runHook postInstall
  '';

  meta = {
    description = "Linux Mint cursor themes";
    homepage = "https://github.com/linuxmint/mint-cursor-themes/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.cinnamon ];
  };
}
