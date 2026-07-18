{
  lib,
  fetchFromGitHub,
  pkg-config,
  rustPlatform,
  wayland,
}:

let
  version = "0.1.0";
in
rustPlatform.buildRustPackage {
  inherit version;
  pname = "redland-wayland";

  src = fetchFromGitHub {
    owner = "domenkozar";
    repo = "redland";
    tag = "v${version}";
    hash = "sha256-iZtRpxloZzneAQ6+5cW0x1E7Qbx/8i9PqkpOHbCZ4Qk=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    wayland
  ];

  cargoHash = "sha256-eE+0wvh2g7t3VhqLxQiQ4tu8oSv8w4HIIzRFAf2kxlc=";

  meta = {
    description = "Wayland screen color temperature adjuster with automatic day/night cycle support";
    homepage = "https://github.com/domenkozar/redland";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ domenkozar ];
    platforms = lib.platforms.linux;
    mainProgram = "redland";
  };
}
