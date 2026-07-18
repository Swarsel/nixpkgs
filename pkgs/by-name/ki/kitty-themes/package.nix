{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
  unstableGitUpdater,
}:

stdenvNoCC.mkDerivation {
  pname = "kitty-themes";
  version = "0-unstable-2026-06-29";

  src = fetchFromGitHub {
    owner = "kovidgoyal";
    repo = "kitty-themes";
    rev = "f54e894cce7c2232c8af9a82f85dca874e496da1";
    hash = "sha256-XYL/7Sr3Ct1n4lnji06I2EM4EQU3cNJuWbAadSz8PAE=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 -t $out/share/kitty-themes/ themes.json
    mv themes $out/share/kitty-themes

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  passthru.updateScript = unstableGitUpdater {
    hardcodeZeroVersion = true;
  };

  meta = {
    description = "Themes for the kitty terminal emulator";
    homepage = "https://github.com/kovidgoyal/kitty-themes";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ sigmanificient ];
    platforms = lib.platforms.all;
  };
}
