{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  pkg-config,
  rustPlatform,
  udev,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mcumgr-client";
  version = "0.0.9";

  src = fetchFromGitHub {
    owner = "vouch-opensource";
    repo = "mcumgr-client";
    rev = "v${finalAttrs.version}";
    hash = "sha256-IbjWJ4AEUxIvj3gSyz7w4q0DL1q2u0q2JO8O+I5qXnY=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ udev ];
  cargoHash = "sha256-V8o89jGqjxJPVIQIh6IbnahXVMktT2gZg/5H+Sr0ogQ=";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Client for mcumgr commands";
    homepage = "https://github.com/vouch-opensource/mcumgr-client";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ otavio ];
    mainProgram = "mcumgr-client";
  };
})
