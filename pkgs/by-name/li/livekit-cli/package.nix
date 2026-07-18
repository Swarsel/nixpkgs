{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  pkg-config,
  portaudio,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "livekit-cli";
  version = "2.17.0";

  src = fetchFromGitHub {
    owner = "livekit";
    repo = "livekit-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-l8RXYwLRrnekNeIocRQPBLCqMscMwKlWrVmts7Ce2EI=";
  };

  # Use nixpkgs portaudio package + pkg-config rather than relying on a vendored
  # git submodule, similar to the homebrew solution
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ portaudio ];
  vendorHash = "sha256-gfiWS6hWqe4eqmKGiYYGeSaygCGhhgSzgp0eicTwSa8=";
  subPackages = [ "cmd/lk" ];
  tags = [ "portaudio_system" ];
  passthru.tests.version = testers.testVersion { package = finalAttrs.finalPackage; };
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command line interface to LiveKit";
    homepage = "https://livekit.io/";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      mgdelacroix
      faukah
      carschandler
    ];

    mainProgram = "lk";
  };
})
