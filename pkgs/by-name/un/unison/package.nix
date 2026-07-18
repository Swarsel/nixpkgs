{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  gsettings-desktop-schemas,
  makeDesktopItem,
  ocamlPackages,
  wrapGAppsHook3,
  enableX11 ? !stdenv.hostPlatform.isDarwin,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "unison";
  version = "2.54.0";

  src = fetchFromGitHub {
    owner = "bcpierce00";
    repo = "unison";
    rev = "v${finalAttrs.version}";
    hash = "sha256-48d+HuFuhjztWz0aoi6DNlBPrV9J05/jjBofXY1PVBg=";
  };

  # Allow the build scripts to correctly call ocamlfind & detect dependencies
  patches = [ ./fix-ocamlfind-env.patch ];
  strictDeps = true;

  nativeBuildInputs = [
    ocamlPackages.ocaml
    ocamlPackages.findlib
  ]
  ++ lib.optionals enableX11 [
    copyDesktopItems
    wrapGAppsHook3
  ];

  buildInputs = lib.optionals enableX11 [
    gsettings-desktop-schemas
    ocamlPackages.lablgtk3
  ];

  makeFlags = [
    "PREFIX=$(out)"
  ]
  ++ lib.optionals (!ocamlPackages.ocaml.nativeCompilers) [ "NATIVE=false" ];

  postInstall = lib.optionalString enableX11 ''
    install -D $src/icons/U.svg $out/share/icons/hicolor/scalable/apps/unison.svg
  '';

  desktopItems = lib.optional enableX11 (makeDesktopItem {
    categories = [
      "Utility"
      "FileTools"
      "GTK"
    ];

    comment = "Bidirectional file synchronizer";
    desktopName = "Unison";
    exec = "unison-gui";
    genericName = "File synchronization tool";
    icon = "unison";
    name = finalAttrs.pname;
    startupNotify = true;
    startupWMClass = "Unison";
  });

  dontStrip = !ocamlPackages.ocaml.nativeCompilers;

  meta = {
    description = "Bidirectional file synchronizer";
    homepage = "https://www.cis.upenn.edu/~bcpierce/unison/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ nevivurn ];
    platforms = lib.platforms.unix;
    mainProgram = if enableX11 then "unison-gui" else "unison";
    broken = stdenv.hostPlatform.isDarwin && enableX11; # unison-gui and uimac are broken on darwin
  };
})
