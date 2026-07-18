{
  lib,
  fetchFromGitHub,
  python3Packages,
  qt6,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "zapzap";
  version = "6.5.2.5";

  src = fetchFromGitHub {
    owner = "rafatosta";
    repo = "zapzap";
    tag = finalAttrs.version;
    hash = "sha256-VybcZNB0k1DwAmluQpEMuM7cHKI8sGyG284g9E3YcP8=";
  };

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtwayland
    qt6.qtsvg
  ];

  preBuild = ''
    export HOME=$(mktemp -d)
  '';

  # has no tests
  doCheck = false;

  postInstall = ''
    install -Dm555 share/applications/com.rtosta.zapzap.desktop -t $out/share/applications/
    install -Dm555 share/icons/com.rtosta.zapzap.svg -t $out/share/icons/hicolor/scalable/apps/
  '';

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    dbus-python
    pyqt6
    pyqt6-webengine
    pyqt6-sip
  ];

  dontWrapQtApps = true;
  pyproject = true;
  pythonImportsCheck = [ "zapzap" ];

  meta = {
    description = "WhatsApp desktop application written in Pyqt6 + PyQt6-WebEngine";
    homepage = "https://rtosta.com/zapzap/";
    changelog = "https://github.com/rafatosta/zapzap/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.eymeric ];
    mainProgram = "zapzap";
  };
})
