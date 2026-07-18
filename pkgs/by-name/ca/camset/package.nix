{
  lib,
  fetchFromGitHub,
  copyDesktopItems,
  gobject-introspection,
  makeDesktopItem,
  python3Packages,
  v4l-utils,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication {
  pname = "camset";
  version = "0-unstable-2023-05-20";

  src = fetchFromGitHub {
    owner = "azeam";
    repo = "camset";
    rev = "b813ba9b1d29f2d46fad268df67bf3615a324f3e";
    hash = "sha256-vTF3MJQi9fZZDlbEj5800H22GGWOte3+KZCpSnsSTaQ=";
  };

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
    copyDesktopItems
  ];

  preFixup = ''
    makeWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
      --prefix PATH : ${lib.makeBinPath [ v4l-utils ]}
    )
  '';

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pygobject3
    opencv-python
  ];

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Utility"
        "Video"
      ];

      comment = "Adjust webcam settings";
      desktopName = "Camset";
      exec = "camset";
      icon = "camera";
      name = "camset";
      type = "Application";
    })
  ];

  dontWrapGApps = true;
  pyproject = true;

  meta = {
    description = "GUI for Video4Linux adjustments of webcams";
    homepage = "https://github.com/azeam/camset";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ averdow ];
  };
}
