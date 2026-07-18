{
  lib,
  fetchFromGitHub,
  cmake,
  nix-update-script,
  pcre2,
  pkg-config,
  pkgs,
  protobuf,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "holo-daemon";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "holo-routing";
    repo = "holo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zZrse46NJb8gD4BtM20FfdtRdxVNLZ+/51dy2nuiOd8=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    protobuf
  ];

  buildInputs = [
    pcre2
  ];

  cargoHash = "sha256-cHJzwI7FDVA1iwqg+x9sMlao22SGQoOuq+MB0XtYsEc=";
  # Use rust nightly features
  env.RUSTC_BOOTSTRAP = 1;

  passthru = {
    services.default = {
      holo-daemon.package = lib.mkDefault finalAttrs.finalPackage;

      imports = [
        (lib.modules.importApply ./service.nix {
          inherit pkgs;
        })
      ];
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "`holo` daemon that provides the routing protocols, tools and policies";
    homepage = "https://github.com/holo-routing/holo";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ themadbit ];
    platforms = lib.platforms.linux;
    mainProgram = "holod";
    teams = with lib.teams; [ ngi ];
  };
})
