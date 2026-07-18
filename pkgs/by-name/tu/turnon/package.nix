{
  lib,
  stdenv,
  blueprint-compiler,
  cairo,
  fetchFromCodeberg,
  gsettings-desktop-schemas,
  just,
  libadwaita,
  pango,
  pkg-config,
  rustPlatform,
  wrapGAppsHook4,
}:

let
  version = "2.9.3";
in
rustPlatform.buildRustPackage {
  pname = "turnon";
  version = version;

  src = fetchFromCodeberg {
    owner = "swsnr";
    repo = "turnon";
    rev = "v${version}";
    hash = "sha256-2dPvIuD7gVfhr/E5szJ5rqWL5yRJKZoj2lV+W9CyCjI=";
  };

  postPatch = ''
    substituteInPlace justfile \
        --replace-fail "version := \`git describe\`" "version := \"${version}\"" \
        --replace-fail "DESTPREFIX := '/app'" "DESTPREFIX := '$out'" \
        --replace-fail "APPID := 'de.swsnr.turnon.Devel'" "APPID := 'de.swsnr.turnon'" \
        --replace-fail "just --list" "just compile" # Replacing the default recipe with the compile command as just-hook-buildPhase runs the default recipe to compile the package.
    substituteInPlace de.swsnr.turnon.desktop --replace-fail "DBusActivatable=true" "DBusActivatable=false"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cairo
    pango
    pkg-config
    blueprint-compiler
    wrapGAppsHook4
    just
  ];

  buildInputs = [
    libadwaita
    gsettings-desktop-schemas
  ];

  cargoHash = "sha256-e0Hds/y3qh7Th+ZTqHIfVleh3vmDlKKJ5Bwt64g5c60=";

  postBuild = ''
    cargo build --release
  '';

  doCheck = true;

  checkFlags = [
    # Skipped due to "Permission denied (os error 13)"
    "--skip=net::ping::tests::ping_loopback_ipv4"
    "--skip=net::ping::tests::ping_loopback_ipv6"
    "--skip=net::ping::tests::ping_with_timeout_unroutable"
  ];

  meta = {
    description = "Turn on devices in your local network";
    homepage = "https://codeberg.org/swsnr/turnon";
    license = lib.licenses.eupl12;
    maintainers = with lib.maintainers; [ mksafavi ];
    platforms = lib.platforms.linux;
    mainProgram = "de.swsnr.turnon";
  };
}
