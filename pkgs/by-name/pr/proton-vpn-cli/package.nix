{
  lib,
  fetchFromGitHub,
  gobject-introspection,
  libnotify,
  python3Packages,
  wrapGAppsNoGuiHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "proton-vpn-cli";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "ProtonVPN";
    repo = "proton-vpn-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CkkytFC3Zr/l2EV5W70kssN1v11F23oZpDvf7JWqmvQ=";
  };

  nativeBuildInputs = [
    # Needed for the NM namespace
    gobject-introspection
    wrapGAppsNoGuiHook
  ];

  buildInputs = [
    libnotify # gir typelib is used
  ];

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    pytest-asyncio
    pytest-cov-stub
  ];

  preCheck = ''
    # Needed for Permission denied: '/homeless-shelter'
    export HOME=$(mktemp -d)
    export XDG_RUNTIME_DIR=$(mktemp -d)
  '';

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    click
    dbus-fast
    packaging
    proton-core
    proton-keyring-linux
    proton-vpn-api-core
    proton-vpn-local-agent
    tabulate
  ];

  dontWrapGApps = true;
  pyproject = true;

  meta = {
    description = "Official ProtonVPN CLI Linux app";
    homepage = "https://github.com/ProtonVPN/proton-vpn-cli";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ anthonyroussel ];
    mainProgram = "protonvpn";
  };
})
