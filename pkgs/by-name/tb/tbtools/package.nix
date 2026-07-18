{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  pkg-config,
  rustPlatform,
  systemd,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tbtools";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "intel";
    repo = "tbtools";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tDAaWFMZeJcU2wzrOD/4DLHerm/Iy56HTe5Qz98I23M=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    systemd
  ];

  cargoHash = "sha256-94O+ma6twGfXr/QM7nZRmNVV4s4Z2YnsYNsNELjnhiQ=";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Thunderbolt/USB4 debugging tools";
    homepage = "https://github.com/intel/tbtools";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      felixsinger
    ];

    platforms = lib.platforms.linux;
    mainProgram = "tblist";
  };
})
