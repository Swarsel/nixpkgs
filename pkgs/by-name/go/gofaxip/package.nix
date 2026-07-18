{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "gofaxip";
  version = "1.4-2";

  src = fetchFromGitHub {
    owner = "gonicus";
    repo = "gofaxip";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Fo/sNXE/GdTImg0Kd3QxWDlpJgN2OJNxX2YjL50kzW0=";
  };

  vendorHash = null;
  env.CI = "1";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  meta = {
    description = "T.38 backend for HylaFAX using FreeSWITCH";
    homepage = "https://github.com/gonicus/gofaxip";
    changelog = "https://github.com/gonicus/gofaxip/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ annaaurora ];
  };
})
