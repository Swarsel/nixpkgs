{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "uutils-findutils";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "uutils";
    repo = "findutils";
    tag = finalAttrs.version;
    hash = "sha256-ILMInyjOMYlgPxrOjvLoBfkcaZ4aj6GeA/jiGPpNjiI=";
  };

  cargoHash = "sha256-/rQTcyRXtluPKPuuZKn/qD/3U0PQLIqyq777/ww3q/0=";

  checkFlags = [
    # assertion failed: deps.get_output_as_string().contains("./test_data/simple/subdir")
    "--skip=find::tests::test_find_newer_xy_before_changed_time"
  ];

  postInstall = ''
    rm $out/bin/testing-commandline
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/find";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Rust implementation of findutils";
    homepage = "https://github.com/uutils/findutils";
    changelog = "https://github.com/uutils/findutils/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ defelo ];
    platforms = lib.platforms.unix;
    mainProgram = "find";
  };
})
