{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gitUpdater,
  libpcap,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "softflowd";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "irino";
    repo = "softflowd";
    tag = "softflowd-v${finalAttrs.version}";
    hash = "sha256-qWHwkXT1Lw8fe9nELaMB6EzAnNxsDvxiLWH3AacVZeA=";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    libpcap
  ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru.updateScript = gitUpdater { rev-prefix = "softflowd-v"; };

  meta = {
    description = "Flow-based network traffic analyser capable of Cisco NetFlow";
    homepage = "https://github.com/irino/softflowd";
    changelog = "https://github.com/irino/softflowd/releases/tag/spftflowd-v${finalAttrs.version}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ fooker ];
    platforms = lib.platforms.unix;
  };
})
