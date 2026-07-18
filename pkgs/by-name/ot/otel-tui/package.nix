{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "otel-tui";
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "ymtdzzz";
    repo = "otel-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RYGSMdJQ2qj6930PX/UWFrN2orQzRpufHiKDv6lmAw4=";
  };

  vendorHash = "sha256-dItC0l6BawbW2OCjg1KoDo8jHGX7Dbo2gSiVi1lynwI=";
  env.GOWORK = "off";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-X main.version=${finalAttrs.version}"
  ];

  subPackages = [ "." ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Terminal OpenTelemetry viewer inspired by otel-desktop-viewer";
    homepage = "https://github.com/ymtdzzz/otel-tui";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ kpbaks ];
    mainProgram = "otel-tui";
  };
})
