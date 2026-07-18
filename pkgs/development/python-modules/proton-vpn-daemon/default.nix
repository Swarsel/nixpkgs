{
  lib,
  fetchFromGitHub,
  bcc,
  buildPythonPackage,
  dbus-fast,
  packaging,
  proton-core,
  proton-vpn-api-core,
  psutil,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
  systemd-python,
}:

buildPythonPackage rec {
  pname = "proton-vpn-daemon";
  version = "0.13.6";

  src = fetchFromGitHub {
    owner = "ProtonVPN";
    repo = "proton-vpn-daemon";
    tag = "v${version}";
    hash = "sha256-HlRxTBLiuboKvMTL3NgX7i/fMBvJqIB4O12tJX1Lv9U=";
  };

  # Needed for `pythonImportsCheck`, `postBuild` happens between `pythonImportsCheckPhase` and `pytestCheckPhase`.
  postBuild = ''
    # Needed for Permission denied: '/homeless-shelter'
    export HOME=$(mktemp -d)
    export XDG_RUNTIME_DIR=$(mktemp -d)
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
    pytest-cov-stub
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    bcc
    dbus-fast
    packaging
    proton-core
    proton-vpn-api-core
    psutil
    systemd-python
  ];

  pyproject = true;

  pythonImportsCheck = [
    "proton.vpn.daemon"
    "proton.vpn.daemon.split_tunneling"
  ];

  meta = {
    description = "Daemons for Proton VPN Linux client";
    homepage = "https://github.com/ProtonVPN/proton-vpn-daemon";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ anthonyroussel ];
    platforms = lib.platforms.linux;
  };
}
