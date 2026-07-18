{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  docker,
  installShellFiles,
  nix-update-script,
  oras,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "copacetic";
  version = "0.14.2";

  src = fetchFromGitHub {
    owner = "project-copacetic";
    repo = "copacetic";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MH3HSbJ+/5vjUrjFZQVf4Qv2+qAezOShxfkAoCJMnFU=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-RKqaIwGDZj91lfbEJHcnG8RhIrixtR0VtieCfZD/rns=";
  env.CGO_ENABLED = "0";

  nativeCheckInputs = [
    docker
    oras
  ];

  checkFlags =
    let
      # Skip tests that require network access and container services
      skippedTests = [
        "TestNewClient/custom_buildkit_addr"
        "TestPatch"
        "TestPlugins/docker.io"
        "TestPatchPartialArchitectures"
        "TestPushToRegistry"
        "TestMultiPlatformPluginPatch"
        "TestPodmanLoader_Load_Success"
        "TestMultiArchBulkPatching"
        "TestComprehensiveBulkPatching"
        "TestTrivyParserParseWithNodeJS/OS_and_Node.js_packages"
        "TestLocalImageDescriptor"
        "TestGetImageDescriptor"
        "TestDotNetSDKImagePatching"
        "TestGenerateWithoutReport"
        "TestGenerateToStdout"
        "TestCustomBuildPatching"
        "TestNodeJSPatching"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  postInstall = ''
    mv $out/bin/copacetic $out/bin/copa
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd copa \
      --bash <($out/bin/copa completion bash) \
      --fish <($out/bin/copa completion fish) \
      --zsh <($out/bin/copa completion zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __darwinAllowLocalNetworking = true;

  excludedPackages = [
    "integration/..."
    "test/..."
  ];

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/project-copacetic/copacetic/pkg/version.GitVersion=${finalAttrs.version}"
    "-X=main.version=${finalAttrs.version}"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/${finalAttrs.meta.mainProgram}";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool for directly patching vulnerabilities in container images";
    homepage = "https://project-copacetic.github.io/copacetic/";
    changelog = "https://github.com/project-copacetic/copacetic/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ tbutter ];
    mainProgram = "copa";
  };
})
