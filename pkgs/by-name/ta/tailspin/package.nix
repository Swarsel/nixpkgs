{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tailspin";
  version = "5.5.0";

  src = fetchFromGitHub {
    owner = "bensadeh";
    repo = "tailspin";
    tag = finalAttrs.version;
    hash = "sha256-coatx8Ud6iLnXvr+/X9hUEe3+0j9jnP5N3+aHQ+eWV8=";
  };

  postPatch = ''
    substituteInPlace tests/utils.rs --replace-fail \
      'target/debug' "target/${stdenv.hostPlatform.rust.rustcTargetSpec}/$cargoCheckType"
  '';

  cargoHash = "sha256-7N/vkhytkDF2ef0T6RJv8YzCpjzi+hjg061Uz9dyEM0=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/tspin";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Log file highlighter";
    homepage = "https://github.com/bensadeh/tailspin";
    changelog = "https://github.com/bensadeh/tailspin/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "tspin";
  };
})
