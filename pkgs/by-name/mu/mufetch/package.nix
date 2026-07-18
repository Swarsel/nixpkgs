{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "mufetch";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "ashish0kumar";
    repo = "mufetch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-iYqLfxJDh0k4tCYfEP40sf3oFLtkvThsJ7ub9KThDNE=";
  };

  nativeBuildInputs = [
    writableTmpDirAsHomeHook
  ];

  vendorHash = "sha256-aXSNM6z/U+2t0aGtr5MIjTb7huAQY/yRf6Oc1udLJYI=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/ashish0kumar/mufetch/cmd.version=${finalAttrs.version}"
  ];

  versionCheckKeepEnvironment = [ "HOME" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Neofetch-style CLI for music metadata with album art display";
    homepage = "https://github.com/ashish0kumar/mufetch";
    changelog = "https://github.com/ashish0kumar/mufetch/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ashish0kumar ];
    platforms = lib.platforms.unix;
    mainProgram = "mufetch";
  };
})
