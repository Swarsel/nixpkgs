{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGo125Module,
  installShellFiles,
}:

buildGo125Module (finalAttrs: {
  pname = "tpm-trust";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "loicsikidi";
    repo = "tpm-trust";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hhcIO+Od5Hhzm9evRlBHIicj+rivFn1H647mCKMq048=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-MKUZ87Ketw29cyCa/7fVcQmlsJa8shwz4gHT3mhRaco=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd tpm-trust \
      --bash <($out/bin/tpm-trust completion bash) \
      --zsh <($out/bin/tpm-trust completion zsh) \
      --fish <($out/bin/tpm-trust completion fish)
  '';

  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.builtBy=nix"
  ];

  meta = {
    description = "Validate TPM authenticity by checking its Endorsement Key certificate against manufacturer root certificates";
    homepage = "https://github.com/loicsikidi/tpm-trust";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ thillux ];
    platforms = lib.platforms.linux;
    mainProgram = "tpm-trust";
  };
})
