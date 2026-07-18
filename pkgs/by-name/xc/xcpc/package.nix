{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf-archive,
  autoreconfHook,
  libepoxy,
  nix-update-script,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xcpc";
  version = "0.52.1";

  src = fetchFromGitHub {
    owner = "ponceto";
    repo = "xcpc-emulator";
    rev = "xcpc-${finalAttrs.version}";
    hash = "sha256-N4UfnCbebaAhx0490niMov/JqlrXt5goblWbW0ajkcc=";
  };

  nativeBuildInputs = [
    autoreconfHook
    autoconf-archive
    wrapGAppsHook3
    pkg-config
  ];

  buildInputs = [ libepoxy ];

  postInstall = ''
    install -D $out/share/pixmaps/xcpc.png -t $out/share/icons/hicolor/64x64/apps
    rm -r $out/share/pixmaps
    substituteInPlace $out/share/applications/xcpc.desktop --replace-fail \
      "$out/bin/" ""
    substituteInPlace $out/share/applications/xcpc.desktop --replace-fail \
      "$out/share/pixmaps/" ""
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Portable Amstrad CPC 464/664/6128 emulator written in C";
    homepage = "https://www.xcpc-emulator.net";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "xcpc";
  };
})
