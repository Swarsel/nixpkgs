{
  lib,
  fetchFromGitHub,
  alsa-lib,
  ffmpeg,
  glib,
  glib-networking,
  gtk4,
  libadwaita,
  libpulseaudio,
  libsoup_3,
  nix-update-script,
  pipewire,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  wrapGAppsHook4,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "songrec";
  version = "0.7.4";

  src = fetchFromGitHub {
    owner = "marin-m";
    repo = "songrec";
    tag = finalAttrs.version;
    hash = "sha256-U7THM8fagZREkleH6DWiusP3KcAtu/OrAg9USdCGRec=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    alsa-lib
    glib
    glib-networking
    gtk4
    libadwaita
    libpulseaudio
    libsoup_3
    pipewire
  ];

  cargoHash = "sha256-O0YjeZCOe+cXjxUAgMT1l621rid4pexMZ3MbLDGxQsM=";

  postInstall = ''
    mv packaging/rootfs/usr/share $out/share
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : "${lib.makeBinPath [ ffmpeg ]}"
    )
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Open-source Shazam client for Linux, written in Rust";
    homepage = "https://github.com/marin-m/SongRec";
    changelog = "https://github.com/marin-m/SongRec/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ tomasrivera ];
    platforms = lib.platforms.linux;
    mainProgram = "songrec";
  };
})
