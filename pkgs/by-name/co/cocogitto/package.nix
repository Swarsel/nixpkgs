{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  libgit2,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cocogitto";
  version = "7.0.0";

  src = fetchFromGitHub {
    owner = "cocogitto";
    repo = "cocogitto";
    tag = finalAttrs.version;
    hash = "sha256-Z+SXB6bDxyR+Bt3Pz6uF9+sZLjbiFNYeECVFZbx40h8=";
  };

  nativeBuildInputs = [ installShellFiles ];
  buildInputs = [ libgit2 ];
  cargoHash = "sha256-TGcgiXLgxeOO44eNfd9F0VonTTJhOn1iEJwrO65wcxk=";
  # Test depend on git configuration that would likely exist in a normal user environment
  # and might be failing to create the test repository it works in.
  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd cog \
      --bash <($out/bin/cog generate-completions bash) \
      --fish <($out/bin/cog generate-completions fish) \
      --zsh  <($out/bin/cog generate-completions zsh)
  '';

  meta = {
    description = "Set of cli tools for the conventional commit and semver specifications";
    homepage = "https://docs.cocogitto.io/";
    changelog = "https://github.com/cocogitto/cocogitto/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gs-101 ];
    mainProgram = "cog";
  };
})
