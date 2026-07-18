{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  kustomize,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "kustomize";
  version = "5.8.1";

  src = fetchFromGitHub {
    owner = "kubernetes-sigs";
    repo = "kustomize";
    rev = "kustomize/v${finalAttrs.version}";
    hash = "sha256-IFof+h6GBlI19ygufNvQ6HgwGbmS0xR5CmrFafknHf0=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-0nlI8QmZCzSZXlQKs5ZkAwrRMKaQUoFpDuj60gURlf8=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd kustomize \
      --bash <($out/bin/kustomize completion bash) \
      --fish <($out/bin/kustomize completion fish) \
      --zsh <($out/bin/kustomize completion zsh)
  '';

  ldflags =
    let
      t = "sigs.k8s.io/kustomize/api/provenance";
    in
    [
      "-s"
      "-X ${t}.version=v${finalAttrs.version}" # add 'v' prefix to match official releases
      "-X ${t}.gitCommit=${finalAttrs.src.rev}"
    ];

  # avoid finding test and development commands
  modRoot = "kustomize";
  proxyVendor = true;

  passthru.tests = {
    versionCheck = testers.testVersion {
      version = "v${finalAttrs.version}";
      command = "${finalAttrs.meta.mainProgram} version";
      package = kustomize;
    };
  };

  meta = {
    description = "Customization of kubernetes YAML configurations";

    longDescription = ''
      kustomize lets you customize raw, template-free YAML files for
      multiple purposes, leaving the original YAML untouched and usable
      as is.
    '';

    homepage = "https://github.com/kubernetes-sigs/kustomize";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      carlosdagos
      vdemeester
      zaninime
      Chili-Man
      saschagrunert
    ];

    mainProgram = "kustomize";
  };
})
