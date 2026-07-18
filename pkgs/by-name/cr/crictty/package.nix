{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "crictty";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "ashish0kumar";
    repo = "crictty";
    tag = "v${finalAttrs.version}";
    hash = "sha256-J8I5HsG0fJyp+PEkUPvyrZm587qZ3Yz2jofCmEKGmps=";
  };

  vendorHash = "sha256-B5+F9WXRkJhiafC+jhzZRvHlDH9XBkHQL5kBnrPRUTk=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Terminal-based cricket scorecard viewer";
    homepage = "https://github.com/ashish0kumar/crictty";
    changelog = "https://github.com/ashish0kumar/crictty/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ashish0kumar ];
    platforms = lib.platforms.unix;
    mainProgram = "crictty";
  };
})
