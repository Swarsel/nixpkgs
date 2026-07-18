{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wasmer-pack";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "wasmerio";
    repo = "wasmer-pack";
    rev = "v${finalAttrs.version}";
    hash = "sha256-9dIdwDKQyut2n1hgq4QzNZuGmGb1wUSmTJf9no6XI5A=";
  };

  cargoHash = "sha256-Hz+cvi82K9NJrn2yEkrVa29yhDUiE1gXZOwHFPljqqw=";
  # requires internet access
  doCheck = false;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  cargoBuildFlags = [ "-p=wasmer-pack-cli" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Import your WebAssembly code just like any other dependency";
    homepage = "https://github.com/wasmerio/wasmer-pack";
    changelog = "https://github.com/wasmerio/wasmer-pack/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.progrm_jarvis ];
    mainProgram = "wasmer-pack";
  };
})
