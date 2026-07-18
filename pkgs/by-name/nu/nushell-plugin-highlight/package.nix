{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "nu_plugin_highlight";
  version = "1.4.12+0.110.0";

  src = fetchFromGitHub {
    owner = "cptpiepmatz";
    repo = "nu-plugin-highlight";
    tag = "v${finalAttrs.version}";
    hash = "sha256-20b+EiB95BzDVWibWQuG8ozPRV8LbxG7fHEbyTk3xTE=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config ] ++ lib.optionals stdenv.cc.isClang [ rustPlatform.bindgenHook ];
  cargoHash = "sha256-pkLcTjZYLERMhK18zPdfldHrECHXQpcg5i6rsyxw7nQ=";
  # there are no tests
  doCheck = false;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "`nushell` plugin for syntax highlighting";
    homepage = "https://github.com/cptpiepmatz/nu-plugin-highlight";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mgttlinger ];
    mainProgram = "nu_plugin_highlight";
  };
})
