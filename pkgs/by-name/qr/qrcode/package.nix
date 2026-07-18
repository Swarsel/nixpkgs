{
  lib,
  stdenv,
  fetchFromGitHub,
  testers,
  unstableGitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qrcode";
  version = "0-unstable-2025-04-29";

  src = fetchFromGitHub {
    owner = "qsantos";
    repo = "qrcode";
    rev = "29140c67b69b79e5c8a52911489648853fddf85f";
    hash = "sha256-WQeZB8G9Nm68mYmLr0ksZdFDcQxF54X0yJxigJZWvMo=";
  };

  strictDeps = true;
  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];

  # Upstream Makefile has no install target.
  installPhase = ''
    runHook preInstall
    install -Dm755 qrcode -t "$out/bin"
    install -Dm644 DOCUMENTATION LICENCE -t "$out/share/doc/qrcode"
    runHook postInstall
  '';

  enableParallelBuilding = true;

  passthru = {
    tests.version = testers.testVersion {
      version = "0.1";
      # Upstream exits non-zero even on successful -V.
      command = "{ qrcode -V || true; }";
      package = finalAttrs.finalPackage;
    };

    updateScript = unstableGitUpdater { };
  };

  meta = {
    description = "QR-code encoder and decoder";
    homepage = "https://github.com/qsantos/qrcode";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      raskin
      lucasew
    ];

    platforms = lib.platforms.unix;
    mainProgram = "qrcode";
  };
})
