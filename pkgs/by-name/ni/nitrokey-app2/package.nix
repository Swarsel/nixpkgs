{
  lib,
  stdenv,
  fetchFromGitHub,
  python3Packages,
  qt6,
}:

let
  inherit (qt6)
    wrapQtAppsHook
    qtbase
    qtwayland
    qtsvg
    ;
in

python3Packages.buildPythonApplication rec {
  pname = "nitrokey-app2";
  version = "2.5.2";

  src = fetchFromGitHub {
    owner = "Nitrokey";
    repo = "nitrokey-app2";
    tag = "v${version}";
    hash = "sha256-HkGdu8A8xpZheO+2NcKkTPXZGln28CnhRQzdpwRUlRE=";
  };

  nativeBuildInputs = [
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    qtwayland
    qtsvg
  ];

  postInstall = ''
    install -Dm755 meta/com.nitrokey.nitrokey-app2.desktop $out/share/applications/com.nitrokey.nitrokey-app2.desktop
    install -Dm755 meta/nk-app2.png $out/share/icons/hicolor/128x128/apps/com.nitrokey.nitrokey-app2.png
  '';

  # wrapQtApps only wrapps binary files and normally skips python programs.
  # Manually pass the qtWrapperArgs from wrapQtAppsHook to wrap python programs.
  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  build-system = with python3Packages; [
    poetry-core
  ];

  dependencies = with python3Packages; [
    fido2
    nitrokey
    pyside6
    usb-monitor
  ];

  pyproject = true;

  pythonImportsCheck = [
    "nitrokeyapp"
  ];

  pythonRelaxDeps = [ "nitrokey" ];

  meta = {
    description = "This application allows to manage Nitrokey 3 devices";
    homepage = "https://github.com/Nitrokey/nitrokey-app2";
    changelog = "https://github.com/Nitrokey/nitrokey-app2/releases/tag/${src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      _999eagle
      panicgh
    ];

    mainProgram = "nitrokeyapp";
  };
}
