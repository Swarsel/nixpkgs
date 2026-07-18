{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  makeDesktopItem,
  python3Packages,
  enableModern ? true,
}:

python3Packages.buildPythonApplication rec {
  pname = "ausweiskopie";
  version = "0.1.4";

  src = fetchFromGitHub {
    owner = "Varbin";
    repo = "ausweiskopie";
    tag = "v${version}";
    hash = "sha256-axy/cI5n2uvMKZ2Fkb0seFMRBKv6rpU01kgKSiQ10jE=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    copyDesktopItems
  ];

  postInstall = ''
    install -Dm644 ./src/ausweiskopie/resources/icon_colored.png $out/share/icons/hicolor/256x256/apps/ausweiskopie.png
  '';

  build-system = with python3Packages; [
    setuptools
    setuptools-scm
  ];

  dependencies =
    with python3Packages;
    (
      [
        pillow
        tkinter
        importlib-resources
      ]
      ++ lib.optionals enableModern optional-dependencies.modern
      ++ lib.optionals stdenv.hostPlatform.isLinux [
        dbus-next
        pygobject3
      ]
    );

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Office"
        "Viewer"
      ];

      comment = "Create redacted copies of German identity cards";
      desktopName = "Meine Ausweiskopie";
      exec = "ausweiskopie";
      icon = "ausweiskopie";
      name = "Meine Ausweiskopie";
    })
  ];

  optional-dependencies.modern = [ python3Packages.ttkbootstrap ];
  pyproject = true;

  meta = {
    description = "Create privacy friendly and legal copies of your Ausweisdokument";
    homepage = "https://github.com/Varbin/ausweiskopie";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ e1mo ];
    platforms = lib.platforms.unix;
    mainProgram = "ausweiskopie";
  };
}
