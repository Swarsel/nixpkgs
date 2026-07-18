{
  lib,
  stdenv,
  fetchFromGitHub,
  llvmPackages,
  nix-update-script,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "blueutil";
  version = "2.13.0";

  src = fetchFromGitHub {
    owner = "toy";
    repo = "blueutil";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Qw5c9dp7wpuOcQSLsg1pfJ+NbrEtme2o6nKD3Ba3A3M=";
  };

  # TODO: Remove when NixOS/nixpkgs#536365 reaches master.
  nativeBuildInputs = [ llvmPackages.lld ];
  env.NIX_CFLAGS_COMPILE = "-Wall -Wextra -Werror -mmacosx-version-min=10.9 -framework Foundation -framework IOBluetooth";
  # TODO: Remove when NixOS/nixpkgs#536365 reaches master.
  env.NIX_CFLAGS_LINK = "--ld-path=${lib.getExe' llvmPackages.lld "ld64.lld"}";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m 755 blueutil $out/bin/blueutil

    runHook postInstall
  '';

  passthru = {
    tests.version = testers.testVersion { package = finalAttrs.finalPackage; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "CLI for bluetooth on OSX";
    homepage = "https://github.com/toy/blueutil";
    changelog = "https://github.com/toy/blueutil/blob/main/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ azuwis ];
    platforms = lib.platforms.darwin;
    mainProgram = "blueutil";
  };
})
