{
  lib,
  fetchFromGitHub,
  python3,
  python3Packages,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "mint-l-theme";
  version = "2.0.7";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "mint-l-theme";
    tag = finalAttrs.version;
    hash = "sha256-Wk480v9AHUfcaZP9sm/boIFWcbuhmJ5cH14qV4BRtuw=";
  };

  postPatch = ''
    patchShebangs .
  '';

  nativeBuildInputs = [
    python3
    python3Packages.libsass
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    mv usr/share $out

    runHook postInstall
  '';

  meta = {
    description = "Mint-L theme for the Cinnamon desktop";
    homepage = "https://github.com/linuxmint/mint-l-theme";
    license = lib.licenses.gpl3Plus; # from debian/copyright
    platforms = lib.platforms.linux;
    teams = [ lib.teams.cinnamon ];
  };
})
