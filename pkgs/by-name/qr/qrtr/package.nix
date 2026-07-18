{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  meson,
  ninja,
  pkg-config,
  systemd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qrtr";
  version = "0-unstable-2025-03-01";

  src = fetchFromGitHub {
    owner = "linux-msm";
    repo = "qrtr";
    rev = "5923eea97377f4a3ed9121b358fd919e3659db7b";
    hash = "sha256-iHjF/2SQsvB/qC/UykNITH/apcYSVD+n4xA0S/rIfnM=";
  };

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
  ];

  buildInputs = [ systemd ];
  installFlags = [ "prefix=$(out)" ];

  meta = {
    description = "QMI IDL compiler";
    homepage = "https://github.com/linux-msm/qrtr";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ matthewcroughan ];
    platforms = lib.platforms.aarch64;
  };
})
