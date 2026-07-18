{
  lib,
  fetchCrate,
  libkrb5,
  nix-update-script,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rusthound-ce";
  version = "2.4.91";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-mOmTBj/NqWqsc3JfpD8vmafevWpaHTnwqM3wuKwxlxc=";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libkrb5
  ];

  cargoHash = "sha256-paMTih5b1RxmXUEjglnj4Hy6SRJE78m1FQP4lags6yo=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Active Directory data ingestor for BloodHound Community Edition written in Rust";
    homepage = "https://github.com/g0h4n/RustHound-CE";
    changelog = "https://github.com/g0h4n/RustHound-CE/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.eleonora ];
    mainProgram = "rusthound-ce";
  };
})
