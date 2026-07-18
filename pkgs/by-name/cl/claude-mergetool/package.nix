{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:
let
  version = "1.2.0";
in
rustPlatform.buildRustPackage {
  inherit version;
  pname = "claude-mergetool";

  src = fetchFromGitHub {
    owner = "9999years";
    repo = "claude-mergetool";
    tag = "v${version}";
    hash = "sha256-d+tOjybFwWgJyI2YbAn6TF1utb7fNHrTbGp7I4yQ8UQ=";
  };

  cargoHash = "sha256-9YDILRyaWxqAmrAdQ2iDvTsn1VTFfFIpv0HMqi9U0q8=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/claude-mergetool";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Resolve Git/jj merge conflicts automatically with claude-code";
    homepage = "https://github.com/9999years/claude-mergetool";
    changelog = "https://github.com/9999years/claude-mergetool/releases/tag/v${version}";
    license = [ lib.licenses.mit ];
    maintainers = [ lib.maintainers._9999years ];
    mainProgram = "claude-mergetool";
  };
}
