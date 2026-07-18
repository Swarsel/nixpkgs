{
  lib,
  fetchFromGitHub,
  gobject-introspection,
  gtk3,
  libnotify,
  python3,
  wrapGAppsHook3,
}:

python3.pkgs.buildPythonApplication {
  pname = "notifymuch";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "kspi";
    repo = "notifymuch";
    # https://github.com/kspi/notifymuch/issues/11
    rev = "9d4aaf54599282ce80643b38195ff501120807f0";
    sha256 = "1lssr7iv43mp5v6nzrfbqlfzx8jcc7m636wlfyhhnd8ydd39n6k4";
  };

  strictDeps = false;

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  propagatedBuildInputs = [
    libnotify
    gtk3
  ]
  ++ (with python3.pkgs; [
    notmuch
    pygobject3
  ]);

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dontWrapGApps = true;
  format = "setuptools";

  meta = {
    description = "Display desktop notifications for unread mail in a notmuch database";
    homepage = "https://github.com/kspi/notifymuch";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ arjan-s ];
    mainProgram = "notifymuch";
  };
}
