{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  glib,
  gnutls,
  keyutils,
  libnl,
  nix-update-script,
  nixosTests,
  pkg-config,
  systemd,
  withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ktls-utils";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "oracle";
    repo = "ktls-utils";
    rev = "ktls-utils-${finalAttrs.version}";
    hash = "sha256-xBh9iSmTf8YCfahWnJvDx/nvz91NFZ3AiJ2JYs+pMfY=";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    gnutls
    keyutils
    glib
    libnl
  ];

  configureFlags = lib.optional withSystemd [ "--with-systemd" ];
  makeFlags = lib.optional withSystemd [ "unitdir=$(out)/lib/systemd/system" ];
  doCheck = true;

  passthru = {
    services.default = {
      imports = [ (lib.modules.importApply ./service.nix { }) ];
      tlshd.package = finalAttrs.finalPackage;
    };

    tests.nixos = nixosTests.tlshd;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "TLS handshake utilities for in-kernel TLS consumers";
    homepage = "https://github.com/oracle/ktls-utils";
    changelog = "https://github.com/oracle/ktls-utils/blob/${finalAttrs.src.rev}/NEWS";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "tlshd";
  };
})
