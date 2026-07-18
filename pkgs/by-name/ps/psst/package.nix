{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  atk,
  cairo,
  dbus,
  gdk-pixbuf,
  glib,
  gtk3,
  libclang,
  makeDesktopItem,
  nix-update-script,
  pango,
  pkg-config,
  rustPlatform,
}:

let
  desktopItem = makeDesktopItem {
    categories = [
      "Audio"
      "AudioVideo"
    ];

    comment = "Spotify client with native GUI written in Rust, without Electron";
    desktopName = "Psst";
    exec = "psst-gui %U";
    icon = "psst";
    name = "Psst";
    startupWMClass = "psst-gui";
  };
in
rustPlatform.buildRustPackage {
  pname = "psst";
  version = "0-unstable-2025-11-16";

  src = fetchFromGitHub {
    owner = "jpochyla";
    repo = "psst";
    rev = "cae05c43f4aee2c5936375225c4586ea35594835";
    hash = "sha256-iCm5lvZq64Dmbe/stkZO0XvX0mWfmzFgl3MeCTI6/hM=";
  };

  patches = [
    # Use a fixed build time, hard-code upstream URL instead of trying to read `.git`
    ./make-build-reproducible.patch
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    atk
    cairo
    gdk-pixbuf
    glib
    gtk3
    pango
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    dbus
  ];

  cargoHash = "sha256-Q4xMsX6lJK3Or+oKuPOTCec2pe+oBWC33peCE1x7QRg=";

  env = {
    LIBCLANG_PATH = "${lib.getLib libclang}/lib";
  };

  postInstall = ''
    install -Dm644 psst-gui/assets/logo_512.png -t $out/share/icons/hicolor/512x512/apps/psst.png
    install -Dm644 ${desktopItem}/share/applications/* -t $out/share/applications
  '';

  # specify the subdirectory of the binary crate to build from the workspace
  buildAndTestSubdir = "psst-gui";
  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Spotify client with native GUI written in Rust, without Electron";
    homepage = "https://github.com/jpochyla/psst";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      vbrandl
      peterhoeg
    ];

    platforms = lib.platforms.unix;
    mainProgram = "psst-gui";
  };
}
