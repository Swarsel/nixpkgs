{
  lib,
  fetchCrate,
  nix-update-script,
  python3,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pipe-rename";
  version = "1.6.7";

  src = fetchCrate {
    inherit (finalAttrs) version;
    hash = "sha256-9Pub+OCN+PiKHfCxflwkHp6JNSB8AqAtKsNTlAsANbA=";
    pname = "pipe-rename";
  };

  cargoHash = "sha256-oYJNiUIi/uYxzd9DfgBgEaEy3g32r44seI56ur9UMcc=";
  nativeCheckInputs = [ python3 ];

  checkFlags = [
    # tests are failing upstream
    "--skip=test_dot"
    "--skip=test_dotdot"
  ];

  preCheck = ''
    patchShebangs tests/editors/env-editor.py
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Rename your files using your favorite text editor";
    homepage = "https://github.com/marcusbuffett/pipe-rename";
    changelog = "https://github.com/marcusbuffett/pipe-rename/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.progrm_jarvis ];
    mainProgram = "renamer";
  };
})
