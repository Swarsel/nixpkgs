{
  lib,
  stdenv,
  fetchFromGitHub,
  desktop-file-utils,
  geoip,
  geolite-legacy,
  gtk4,
  imagemagick,
  libadwaita,
  libgee,
  lua5_4,
  meson,
  ninja,
  nix-update-script,
  pkg-config,
  vala,
  versionCheckHook,
  wrapGAppsHook4,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "gswatcher";
  version = "1.7.5";

  src = fetchFromGitHub {
    owner = "lxndr";
    repo = "gswatcher";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RnyvKAnEF1tzVS+/GEwaGQNPIXKx7KU790ZElj6hJtw=";
  };

  nativeBuildInputs = [
    meson
    ninja
    vala
    wrapGAppsHook4
    desktop-file-utils
    # Not packaged yet, optional
    # appstream-util
    pkg-config
    imagemagick
  ];

  buildInputs = [
    gtk4
    libadwaita
    libgee
    lua5_4
    geoip
  ];

  postInstall = ''
    ln -s ${geolite-legacy}/share/GeoIP $out/share/GeoIP
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple game server monitor and administrative tool";
    homepage = "https://github.com/lxndr/gswatcher";
    license = with lib.licenses; [ agpl3Plus ];
    maintainers = with lib.maintainers; [ pluiedev ];
    platforms = lib.platforms.linux;
  };
})
