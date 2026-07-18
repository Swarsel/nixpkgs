{
  lib,
  fetchFromGitHub,
  crystal_1_17,
  versionCheckHook,
  ...
}:
crystal_1_17.buildCrystalPackage rec {
  pname = "coverage-reporter";
  version = "0.6.17";

  src = fetchFromGitHub {
    owner = "coverallsapp";
    repo = "coverage-reporter";
    tag = "v${version}";
    hash = "sha256-wbxPjNAUubbL9TJnyqR7aYkMmADkIuD2PF00xI2wa84=";
  };

  doCheck = false;

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/coveralls $out/bin/coveralls
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  shardsFile = ./shards.nix;

  meta = {
    description = "Self-contained, universal coverage uploader binary";
    homepage = "https://github.com/coverallsapp/coverage-reporter";
    changelog = "https://github.com/coverallsapp/coverage-reporter/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ quadradical ];
    mainProgram = "coveralls";
  };
}
