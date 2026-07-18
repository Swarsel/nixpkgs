{
  lib,
  stdenv,
  fetchFromGitLab,
  cargo,
  desktop-file-utils,
  libadwaita,
  libsoup_3,
  libxml2,
  meson,
  ninja,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  rustc,
  sqlite,
  webkitgtk_6_0,
  wrapGAppsHook4,
}:

stdenv.mkDerivation rec {
  pname = "read-it-later";
  version = "0.6.2";

  src = fetchFromGitLab {
    owner = "World";
    repo = "read-it-later";
    tag = version;
    hash = "sha256-dXDpZ5CXR/+lJUpQ1EpGgzYC6WKE4Y6CKytvCPrsMNk=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    rustPlatform.cargoSetupHook
    rustc
    cargo
    wrapGAppsHook4
    desktop-file-utils
    libxml2.bin # xmllint
  ];

  buildInputs = [
    libadwaita
    openssl
    libsoup_3
    webkitgtk_6_0
    sqlite
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-zC9rb+yUWKozTTc3aBOnpTkhqykhQYemnzPtjjKnOdQ=";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple Wallabag client with basic features to manage articles";
    homepage = "https://gitlab.gnome.org/World/read-it-later";
    changelog = "https://gitlab.gnome.org/World/read-it-later/-/releases/${src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.unix;
    mainProgram = "read-it-later";
  };
}
