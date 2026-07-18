{
  lib,
  fetchFromGitHub,
  buildGoModule,
  callPackage,
  nix-update-script,
  nixosTests,
  sqlite,
}:

buildGoModule (finalAttrs: {
  pname = "gotify-server";
  version = "2.9.1";

  src = fetchFromGitHub {
    owner = "gotify";
    repo = "server";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kFBZbfolfTs0aUmfpPcJ2UylmB5NF317mV1X2gSYbjs=";
  };

  buildInputs = [
    sqlite
  ];

  vendorHash = "sha256-oO0wnwBQPJqeJkFoAoEIKRuvbvsbp18F7jwxPCYjsxg=";

  # Use preConfigure instead of preBuild to keep goModules independent from ui
  preConfigure = ''
    cp -r ${finalAttrs.ui} ui/build
  '';

  # No test
  doCheck = false;

  # Based on LD_FLAGS in upstream's .github/workflows/build.yml:
  # https://github.com/gotify/server/blob/v2.6.3/.github/workflows/build.yml#L33
  ldflags = [
    "-s"
    "-X main.Version=${finalAttrs.version}"
    "-X main.Mode=prod"
    "-X main.Commit=refs/tags/v${finalAttrs.version}"
    "-X main.BuildDate=unknown"
  ];

  # Otherwise, all other subpackages are built as well and from some reason,
  # produce binaries which panic when executed and are not interesting at all
  subPackages = [ "." ];
  ui = callPackage ./ui.nix { inherit (finalAttrs) src version; };

  passthru = {
    tests = {
      nixos = nixosTests.gotify-server;
    };

    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage"
        "ui"
      ];
    };
  };

  meta = {
    description = "Simple server for sending and receiving messages in real-time per WebSocket";
    homepage = "https://gotify.net";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
    mainProgram = "server";
  };
})
