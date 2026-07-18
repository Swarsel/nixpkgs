{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "changelogger";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "MarkusFreitag";
    repo = "changelogger";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-Glup2Y3sGO2hNKFeZXOrffHct2F4Ebn9+f6yOy3pekY=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-f6ojMri3m3pwLXbLnNbS/Xl2lqo0eEHLGbbT5KR1Clc=";

  preCheck = ''
    # Test needs gitconfig
    substituteInPlace pkg/gitconfig/gitconfig_test.go \
      --replace-fail "TestGetGitAuthor" "SkipGetGitAuthor"
  '';

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd changelogger \
      --bash <($out/bin/changelogger completion bash) \
      --fish <($out/bin/changelogger completion fish) \
      --zsh <($out/bin/changelogger completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/MarkusFreitag/changelogger/cmd.BuildVersion=${finalAttrs.version}"
    "-X github.com/MarkusFreitag/changelogger/cmd.BuildDate=1970-01-01T00:00:00"
  ];

  meta = {
    description = "Tool to manage your changelog file in Markdown";
    homepage = "https://github.com/MarkusFreitag/changelogger";
    changelog = "https://github.com/MarkusFreitag/changelogger/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hythera ];
    mainProgram = "changelogger";
  };
})
