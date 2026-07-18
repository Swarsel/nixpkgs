{
  lib,
  fetchFromGitHub,
  age-plugin-1p,
  age-plugin-fido2-hmac,
  age-plugin-ledger,
  age-plugin-se,
  age-plugin-sss,
  age-plugin-tpm,
  age-plugin-yubikey,
  buildGoModule,
  installShellFiles,
  makeWrapper,
  nix-update-script,
  runCommand,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "age";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "FiloSottile";
    repo = "age";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Qs/q3zQYV0PukABBPf/aU5V1oOhw95NG6K301VYJk8A=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-iVDkYXXR2pXlUVywPgVRNMORxOOEhAmzpSM0xqSQMSQ=";

  # plugin test is flaky, see https://github.com/FiloSottile/age/issues/517
  checkFlags = [
    "-skip"
    "TestScript/plugin"
  ];

  preInstall = ''
    installManPage doc/*.1
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=v${finalAttrs.version}"
  ];

  versionCheckProgramArg = "--version";

  # group age plugins together
  passthru.plugins = {
    inherit
      age-plugin-fido2-hmac
      age-plugin-ledger
      age-plugin-se
      age-plugin-sss
      age-plugin-tpm
      age-plugin-yubikey
      age-plugin-1p
      ;
  };

  passthru.updateScript = nix-update-script { };

  # convenience function for wrapping sops with plugins
  passthru.withPlugins =
    filter:
    runCommand "age-${finalAttrs.version}-with-plugins" { nativeBuildInputs = [ makeWrapper ]; } ''
      makeWrapper ${lib.getBin finalAttrs.finalPackage}/bin/age $out/bin/age \
        --prefix PATH : "${lib.makeBinPath (filter finalAttrs.passthru.plugins)}"
    '';

  meta = {
    description = "Modern encryption tool with small explicit keys";
    homepage = "https://age-encryption.org/";
    changelog = "https://github.com/FiloSottile/age/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ tazjin ];
    mainProgram = "age";
  };
})
