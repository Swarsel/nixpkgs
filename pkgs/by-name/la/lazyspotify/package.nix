{
  lib,
  fetchFromGitHub,
  buildGoModule,
  callPackage,
  versionCheckHook,
  go-librespot ? callPackage ./go-librespot.nix { },
}:
buildGoModule (finalAttrs: {
  pname = "lazyspotify";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "dubeyKartikay";
    repo = "lazyspotify";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZL/UPqQ6ClK0JN9LbPtr8nqcdBLdoOYti94BPRXn/Pk=";
  };

  vendorHash = "sha256-Axdt3/3ZOZY9Z5VUI6Wh77oIREOO26ODMyEgtscTmn8=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/dubeyKartikay/lazyspotify/buildinfo.Version=${finalAttrs.version}"
    "-X github.com/dubeyKartikay/lazyspotify/buildinfo.PackagedDaemonPath=${lib.getExe go-librespot}"
  ];

  subPackages = [ "cmd/lazyspotify" ];

  meta = {
    description = "Terminal Spotify client for macOS and Linux";
    homepage = "https://dubeykartikay.github.io/lazyspotify/";
    changelog = "https://github.com/dubeyKartikay/lazyspotify/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      eConnah
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "lazyspotify";
  };
})
