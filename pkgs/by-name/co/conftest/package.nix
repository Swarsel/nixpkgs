{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  buildPackages,
  installShellFiles,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "conftest";
  version = "0.63.0";

  src = fetchFromGitHub {
    owner = "open-policy-agent";
    repo = "conftest";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gmfzMup4fdsbdyUufxjcJRPF2faj3RUlvIn2ciyalaQ=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = "sha256-pBUWM6st5FhhOki3n9NIN4/U8JB7Kq3Aph3AtQs+Ogg=";

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
  ];

  postInstall =
    let
      conftest =
        if stdenv.buildPlatform.canExecute stdenv.hostPlatform then
          placeholder "out"
        else
          buildPackages.conftest;
    in
    ''
      installShellCompletion --cmd conftest \
        --bash <(${conftest}/bin/conftest completion bash) \
        --fish <(${conftest}/bin/conftest completion fish) \
        --zsh <(${conftest}/bin/conftest completion zsh)
    '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __darwinAllowLocalNetworking = true; # required for tests

  ldflags = [
    "-s"
    "-w"
    "-X github.com/open-policy-agent/conftest/internal/commands.version=${finalAttrs.version}"
  ];

  meta = {
    description = "Write tests against structured configuration data";

    longDescription = ''
      Conftest helps you write tests against structured configuration data.
      Using Conftest you can write tests for your Kubernetes configuration,
      Tekton pipeline definitions, Terraform code, Serverless configs or any
      other config files.

      Conftest uses the Rego language from Open Policy Agent for writing the
      assertions. You can read more about Rego in 'How do I write policies' in
      the Open Policy Agent documentation.
    '';

    homepage = "https://www.conftest.dev";
    changelog = "https://github.com/open-policy-agent/conftest/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      jk
      yurrriq
    ];

    mainProgram = "conftest";
    downloadPage = "https://github.com/open-policy-agent/conftest";
  };
})
