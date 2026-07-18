{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "gh-dash";
  version = "4.25.2";

  src = fetchFromGitHub {
    owner = "dlvhdr";
    repo = "gh-dash";
    rev = "v${finalAttrs.version}";
    hash = "sha256-3iUBuMvA2Xh7UjTiFNEs3tuZMCnSt/bIhTSEDD92yCU=";
  };

  vendorHash = "sha256-Teu+8jiZE2gZ+0ErKsunhotY9W4Hjg6PAeFkFLgESIk=";
  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  checkFlags = [
    # requires network
    "-skip=TestFullOutput"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/dlvhdr/gh-dash/v4/cmd.Version=${finalAttrs.version}"
  ];

  meta = {
    description = "Github Cli extension to display a dashboard with pull requests and issues";
    homepage = "https://www.gh-dash.dev";
    changelog = "https://github.com/dlvhdr/gh-dash/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ matthiasbeyer ];
    mainProgram = "gh-dash";
  };
})
