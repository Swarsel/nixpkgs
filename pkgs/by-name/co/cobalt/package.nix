{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cobalt";
  version = "0.20.4";

  src = fetchFromGitHub {
    owner = "cobalt-org";
    repo = "cobalt.rs";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XS8KZXHmeMPwCXMR68yIHYikV6Zwj46w2Mtz+d0JCTI=";
  };

  cargoHash = "sha256-vd+udalOsHMCWBI23v56N2yHRVlbKC0gjvFHJeCv0qw=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Static site generator written in Rust";
    homepage = "https://cobalt-org.github.io/";
    changelog = "https://github.com/cobalt-org/cobalt.rs/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    platforms = lib.platforms.unix;
    mainProgram = "cobalt";
    downloadPage = "https://github.com/cobalt-org/cobalt.rs/";
  };
})
