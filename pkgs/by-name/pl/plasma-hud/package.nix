{
  lib,
  fetchFromGitHub,
  gobject-introspection,
  python3Packages,
  rofi,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "plasma-hud";
  version = "22.01.0";

  src = fetchFromGitHub {
    owner = "Zren";
    repo = "plasma-hud";
    rev = finalAttrs.version;
    hash = "sha256-HEAvwQSROQtJAZdiDObu9qbpgJlkJdks2v95Xjh5520=";
  };

  postPatch = ''
    sed -i "s:/usr/lib/plasma-hud:$out/bin:" etc/xdg/autostart/plasma-hud.desktop
  '';

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  propagatedBuildInputs =
    (with python3Packages; [
      dbus-python
      pygobject3
      setproctitle
      python-xlib
    ])
    ++ [ rofi ];

  installPhase = ''
    runHook preInstall

    install -Dm555 usr/lib/plasma-hud/plasma-hud -t $out/bin
    cp -r etc -t $out

    runHook postInstall
  '';

  pyproject = false;

  meta = {
    description = "Run menubar commands, much like the Unity 7 Heads-Up Display (HUD)";
    homepage = "https://github.com/Zren/plasma-hud";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ pasqui23 ];
    platforms = lib.platforms.unix;
    mainProgram = "plasma-hud";
  };
})
