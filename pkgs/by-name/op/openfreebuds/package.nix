{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
  qt6,
  qt6Packages,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "openfreebuds";
  version = "0.17.3";

  src = fetchFromGitHub {
    owner = "melianmiko";
    repo = "OpenFreebuds";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3DTSoVnHYB8GjKw0G8O3hlkOdQmDxe6B2O7h6LT1+jg=";
  };

  nativeBuildInputs = [
    qt6Packages.wrapQtAppsHook
    qt6Packages.qttools
  ];

  buildInputs = [ qt6.qtbase ];

  preBuild = ''
    find openfreebuds_qt/designer -name "*.ui" | while read ui_file; do
      py_file="''${ui_file%.ui}.py"
      pyuic6 "$ui_file" -o "$py_file"
    done

    lrelease openfreebuds_qt/assets/i18n/*.ts
  '';

  nativeCheckInputs = with python3Packages; [
    pytest-asyncio
    pytestCheckHook
  ];

  postInstall = ''
    mkdir -p "$out/share/applications"
    mv openfreebuds_qt/assets/pw.mmk.OpenFreebuds.desktop "$out/share/applications"
  '';

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  build-system = with python3Packages; [
    pdm-backend
    pyqt6
  ];

  dependencies = with python3Packages; [
    aiocmd
    aiohttp
    dbus-next
    pillow
    psutil
    pynput
    pyqt6
    qasync
  ];

  enabledTestPaths = [
    "openfreebuds/driver/huawei/test/"
    "openfreebuds/test/test_event_bus.py"
  ];

  pyproject = true;
  pythonRelaxDeps = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Open source app for HUAWEI FreeBuds (Linux + Windows)";
    homepage = "https://github.com/melianmiko/OpenFreebuds";
    changelog = "https://github.com/melianmiko/OpenFreebuds/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.znaniye ];
    platforms = lib.platforms.linux;
  };
})
