{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "udpspeeder";
  version = "20230206.0";

  src = fetchFromGitHub {
    owner = "wangyu-";
    repo = "UDPspeeder";
    tag = finalAttrs.version;
    hash = "sha256-hrwkPSxY1DTEXt9vxDECDEJaoTDzBUS7rVI609uZwdU=";
  };

  postPatch = ''
    substituteInPlace makefile \
      --replace-fail " -static " " " \
      --replace-fail "\$(shell git rev-parse HEAD)" ${finalAttrs.version}
  '';

  nativeCheckInputs = [
    versionCheckHook
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 ./speederv2 $out/bin/speederv2

    runHook postInstall
  '';

  doInstallCheck = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Tunnel which Improves your Network Quality on a High-latency Lossy Link by using Forward Error Correction, possible for All Traffics(TCP/UDP/ICMP)";
    homepage = "https://github.com/wangyu-/UDPspeeder";
    changelog = "https://github.com/wangyu-/UDPspeeder/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.linux;
    mainProgram = "speederv2";
  };
})
