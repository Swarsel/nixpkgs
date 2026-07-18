{
  lib,
  fetchFromGitHub,
  crystal_1_15,
  versionCheckHook,
}:

let
  # Use the same Crystal minor version as specified in upstream
  crystal = crystal_1_15;
in
crystal.buildCrystalPackage rec {
  pname = "ameba-ls";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "crystal-ameba";
    repo = "ameba-ls";
    tag = "v${version}";
    hash = "sha256-TEHjR+34wrq24XJNLhWZCEzcDEMDlmUHv0iiF4Z6JlI=";
  };

  # There are no actual tests
  doCheck = false;

  installPhase = ''
    runHook preInstall

    install -Dm555 bin/ameba-ls -t "$out/bin/"

    runHook postInstall
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  buildTargets = [
    "ameba-ls"
  ];

  crystalBinaries.ameba-ls.src = "src/ameba-ls.cr";
  shardsFile = ./shards.nix;
  versionCheckProgram = "${placeholder "out"}/bin/ameba-ls";

  meta = {
    description = "Crystal language server powered by Ameba linter";
    homepage = "https://github.com/crystal-ameba/ameba-ls";
    changelog = "https://github.com/crystal-ameba/ameba-ls/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      kachick
    ];

    platforms = lib.platforms.unix;
    mainProgram = "ameba-ls";
  };
}
