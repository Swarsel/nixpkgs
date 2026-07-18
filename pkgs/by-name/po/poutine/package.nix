{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "poutine";
  version = "1.1.6";

  src = fetchFromGitHub {
    owner = "boostsecurityio";
    repo = "poutine";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jiIjim17x9Q6e5+XSR6xHYg/VOJILfCeLRXdEopQwKE=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-Ktsk01YqBHVZDOu+Xp1p3sVDwqozl35iLYbVavpiWq0=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd ${finalAttrs.meta.mainProgram} \
      --bash <($out/bin/${finalAttrs.meta.mainProgram} completion bash) \
      --fish <($out/bin/${finalAttrs.meta.mainProgram} completion fish) \
      --zsh <($out/bin/${finalAttrs.meta.mainProgram} completion zsh)
  '';

  # "dagger" directory contains its own go module, which should be excluded from the build
  excludedPackages = [ "dagger" ];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Security scanner that detects misconfigurations and vulnerabilities in build pipelines of repositories";
    homepage = "https://github.com/boostsecurityio/poutine";
    changelog = "https://github.com/boostsecurityio/poutine/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "poutine";
  };
})
