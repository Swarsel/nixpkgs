{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "threatest";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "DataDog";
    repo = "threatest";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MmCAP1UUqNDCoG1xxuDkjzx8Exh421yT//bB2L75yac=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = "sha256-KfIs4LJHOaUKwc3ML/dMwSEkfRT3QW9Nlfla0KqkEyM=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd threatest \
      --bash <($out/bin/threatest completion bash) \
      --fish <($out/bin/threatest completion fish) \
      --zsh <($out/bin/threatest completion zsh)
  '';

  proxyVendor = true;

  meta = {
    description = "Framework for end-to-end testing threat detection rules";
    homepage = "https://github.com/DataDog/threatest";
    changelog = "https://github.com/DataDog/threatest/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "threatest";
  };
})
