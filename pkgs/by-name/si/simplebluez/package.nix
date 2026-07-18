{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  dbus,
  fmt_9,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "simplebluez";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "OpenBluetoothToolbox";
    repo = "SimpleBLE";
    rev = "v${finalAttrs.version}";
    hash = "sha256-SWZdVWBC8udwkn195FdvsXSniMtzd8+WfnMsARLYSQ4=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    dbus
  ];

  cmakeFlags = [ "-DLIBFMT_LOCAL_PATH=${fmt_9.src}" ];
  sourceRoot = "${finalAttrs.src.name}/simplebluez";

  meta = {
    description = "C++ abstraction layer for BlueZ over DBus";
    homepage = "https://github.com/OpenBluetoothToolbox/SimpleBLE";
    # SimpleBLE (which SimpleBluez is part of) is under the Business Source License 1.1 (BUSL-1.1)
    # since version 0.9.0
    license = lib.licenses.bsl11;
    maintainers = with lib.maintainers; [ aciceri ];
    platforms = lib.platforms.linux;
  };
})
