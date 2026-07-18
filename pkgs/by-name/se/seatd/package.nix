{
  lib,
  stdenv,
  fetchFromSourcehut,
  meson,
  ninja,
  nixosTests,
  pkg-config,
  scdoc,
  systemdLibs,
  systemdSupport ? lib.meta.availableOn stdenv.hostPlatform systemdLibs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "seatd";
  version = "0.9.3";

  src = fetchFromSourcehut {
    owner = "~kennylevinsen";
    repo = "seatd";
    rev = finalAttrs.version;
    hash = "sha256-a3L/iFDeFnMGNzC46wXREmSPE+ZX1zUEPnjKPL0bT/A=";
  };

  outputs = [
    "bin"
    "out"
    "dev"
    "man"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
  ];

  buildInputs = lib.optionals systemdSupport [ systemdLibs ];

  mesonFlags = [
    "-Dlibseat-logind=${if systemdSupport then "systemd" else "disabled"}"
    "-Dlibseat-builtin=enabled"
    "-Dserver=enabled"
  ];

  depsBuildBuild = [
    pkg-config
  ];

  passthru.tests.basic = nixosTests.seatd;

  meta = {
    description = "Minimal seat management daemon, and a universal seat management library";
    homepage = "https://sr.ht/~kennylevinsen/seatd/";
    changelog = "https://git.sr.ht/~kennylevinsen/seatd/refs/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ emantor ];
    platforms = with lib.platforms; freebsd ++ linux ++ netbsd;
    mainProgram = "seatd";
  };
})
