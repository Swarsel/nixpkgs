{
  lib,
  stdenv,
  fetchCrate,
  installShellFiles,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "korrect";
  version = "0.3.8";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-iNM8annxL48uDAvrtYw/LhaK2lCirJsmQy/QWbDpczA=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-2MsrqsgvYc+XKgWKIVhoA+Opg8e7ybWFxKQ/SuVUfto=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd ${finalAttrs.meta.mainProgram} \
      --bash <($out/bin/${finalAttrs.meta.mainProgram} completions bash) \
      --fish <($out/bin/${finalAttrs.meta.mainProgram} completions fish) \
      --zsh <($out/bin/${finalAttrs.meta.mainProgram} completions zsh) \
      --nushell <($out/bin/${finalAttrs.meta.mainProgram} completions nushell)
  '';

  # Tests create a local http server to check the download functionality
  __darwinAllowLocalNetworking = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Kubectl version managing shim that invokes the correct kubectl version";
    homepage = "https://gitlab.com/cromulentbanana/korrect";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dwt ];
    mainProgram = "korrect";
  };
})
