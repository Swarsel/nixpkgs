{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  buildGoModule,
  flac,
  nix-update-script,
  pkg-config,
}:

buildGoModule (finalAttrs: {
  pname = "go-musicfox";
  version = "4.8.1";

  src = fetchFromGitHub {
    owner = "go-musicfox";
    repo = "go-musicfox";
    rev = "v${finalAttrs.version}";
    hash = "sha256-EwN8tWoyghG9L++Tl5iz2ZyNsI5IroZXM0Dd5N182dU=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    flac
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
  ];

  vendorHash = "sha256-MEcdWJts7hzt8fuhVsxHl1mQ57R8vNd3H3Tmpx4A9a4=";
  deleteVendor = true;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/go-musicfox/go-musicfox/internal/types.AppVersion=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/musicfox.go" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Terminal netease cloud music client written in Go";
    homepage = "https://github.com/anhoder/go-musicfox";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      zendo
      Ruixi-rebirth
      aleksana
    ];

    mainProgram = "musicfox";
  };
})
