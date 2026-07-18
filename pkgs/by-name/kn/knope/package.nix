{
  lib,
  fetchFromGitHub,
  git,
  libgit2,
  nix-update-script,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "knope";
  version = "0.23.0";

  src = fetchFromGitHub {
    owner = "knope-dev";
    repo = "knope";
    tag = "knope/v${finalAttrs.version}";
    hash = "sha256-Brr/MnJwgyGRjBrY6H2uUnVXFYWdUAHzLolFBgszkp0=";
  };

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libgit2 ];
  cargoHash = "sha256-vjjwoBHgmjzMVDyscfde/fRwm7QWFTuD9EX1+OowUm8=";
  env.LIBGIT2_NO_VENDOR = 1;
  nativeCheckInputs = [ git ];
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "knope/v(.*)"
    ];
  };

  meta = {
    description = "Automation for changelogs and releases using conventional commits and/or changesets";
    homepage = "https://knope.tech/";
    changelog = "https://github.com/knope-dev/knope/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mdaniels5757 ];
    mainProgram = "knope";
  };
})
