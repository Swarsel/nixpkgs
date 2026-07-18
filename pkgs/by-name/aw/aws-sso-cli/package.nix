{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  getent,
  installShellFiles,
  makeWrapper,
  writableTmpDirAsHomeHook,
  xdg-utils,
}:
buildGoModule (finalAttrs: {
  pname = "aws-sso-cli";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "synfinatic";
    repo = "aws-sso-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-JFaCTgvH6qzQ8gMt5QgqAPBal2m8FZEemTgbqyECFck=";
  };

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];

  vendorHash = "sha256-f9qSnEOUw8QWbc0rgStyzuL6lWtfy3UFhjqDAnJkKJA=";

  nativeCheckInputs = [
    getent
    writableTmpDirAsHomeHook
  ];

  checkFlags =
    let
      skippedTests = [
        "TestAWSFederatedUrl"
        "TestAWSConsoleUrlChina"
        "TestAWSConsoleUrlEU"
        "TestAWSConsoleUrlUSEast"
        "TestAWSConsoleUrlUSGov"
        "TestGetScriptsAutoDetect"
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [ "TestDetectShellBash" ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  preCheck = ''
    mkdir -p "$HOME/.config/aws-sso"
  '';

  postInstall = ''
    wrapProgram $out/bin/aws-sso \
      --suffix PATH : ${lib.makeBinPath [ xdg-utils ]}
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd aws-sso \
      --bash <($out/bin/aws-sso setup completions --source --shell=bash) \
      --fish <($out/bin/aws-sso setup completions --source --shell=fish) \
      --zsh <($out/bin/aws-sso setup completions --source --shell=zsh)
  '';

  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-X main.Version=${finalAttrs.version}"
    "-X main.Tag=nixpkgs"
  ];

  meta = {
    description = "AWS SSO CLI is a secure replacement for using the aws configure sso wizard";
    homepage = "https://github.com/synfinatic/aws-sso-cli";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ devusb ];
    mainProgram = "aws-sso";
  };
})
