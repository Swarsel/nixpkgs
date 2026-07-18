{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  flytectl,
  installShellFiles,
  testers,
}:
buildGoModule (finalAttrs: {
  pname = "flytectl";
  version = "0.9.8";

  src = fetchFromGitHub {
    owner = "flyteorg";
    repo = "flyte";
    tag = "flytectl/v${finalAttrs.version}";
    hash = "sha256-p6fU+BLvhwK+4zDNBy4jwtvIll+s4jXmpYIF1mfeoB4=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-h4L8BFzRiph4SBffVRH9TU5j7k+CZGshOV160mENAL0=";
  # Tests require network and file system access
  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd flytectl \
      --bash <($out/bin/flytectl completion bash) \
      --fish <($out/bin/flytectl completion fish) \
      --zsh <($out/bin/flytectl completion zsh)
  '';

  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/flyteorg/flyte/flytestdlib/version.Version=v${finalAttrs.version}"
    "-X github.com/flyteorg/flyte/flytestdlib/version.Build=${finalAttrs.src.tag}"
    "-X github.com/flyteorg/flyte/flytestdlib/version.BuildTime=1970-01-01"
  ];

  sourceRoot = "${finalAttrs.src.name}/flytectl";
  subPackages = [ "." ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    command = "flytectl version";
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Command-line interface for Flyte, a cloud-native workflow orchestration platform";
    homepage = "https://flyte.org/";
    changelog = "https://github.com/flyteorg/flyte/releases/tag/flytectl%2Fv${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.mcuste ];
    platforms = lib.platforms.unix;
    mainProgram = "flytectl";
    downloadPage = "https://github.com/flyteorg/flyte";
  };
})
