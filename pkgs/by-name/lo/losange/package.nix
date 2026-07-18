{
  lib,
  fetchFromGitHub,
  glib,
  libadwaita,
  libepoxy,
  # nativeBuildInputs
  makeBinaryWrapper,
  # buildInputs
  mpv,
  nix-update-script,
  # Wrapper
  nodejs,
  openssl,
  pkg-config,
  rustPlatform,
  wrapGAppsHook4,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "losange";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "tymmesyde";
    repo = "losange";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mr54/vnaopLwG9lhFiZJGgxWH/VaGitROVEeV7GSyHM=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    makeBinaryWrapper
    pkg-config
    wrapGAppsHook4
    glib
  ];

  buildInputs = [
    mpv
    libadwaita
    libepoxy
    openssl
  ];

  cargoHash = "sha256-LJ8EpxEIN8wojSmQ+WVshYRxGFAC9sUk5tnh3I2J408=";

  postInstall = ''
    install -Dm444 data/xyz.timtimtim.Losange.gschema.xml -t $out/share/gsettings-schemas/$name/glib-2.0/schemas/
    glib-compile-schemas $out/share/gsettings-schemas/$name/glib-2.0/schemas/

    install -Dm444 data/icons/xyz.timtimtim.Losange.svg -t $out/share/icons/hicolor/scalable/apps/
    install -Dm444 data/xyz.timtimtim.Losange.desktop -t $out/share/applications/
    install -Dm444 data/xyz.timtimtim.Losange.metainfo.xml -t $out/share/metainfo/

    # The application fails if '-o' is passed without an argument (e.g. when opened using a launcher)
    # therefore we match upstream's shell wrapper to handle empty URL cases.
    substituteInPlace $out/share/applications/xyz.timtimtim.Losange.desktop \
      --replace-fail "Exec=sh -c \"/usr/bin/losange -o '%u'\"" "Exec=sh -c \"losange -o '%u'\""
  '';

  # Node.js is required to run `server.js`
  # Losange will automatically download the required version of `server.js` at runtime.
  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : "${lib.makeBinPath [ nodejs ]}"
    )
  '';

  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple Stremio client for GNOME";
    homepage = "https://github.com/tymmesyde/Losange";
    changelog = "https://github.com/tymmesyde/Losange/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ talal ];
    platforms = lib.platforms.linux;
    mainProgram = "losange";
  };
})
