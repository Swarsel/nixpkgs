{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  python3Packages,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "printrun";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "kliment";
    repo = "Printrun";
    tag = "printrun-${finalAttrs.version}";
    hash = "sha256-INJNGAmghoPIiivQp6AV1XmhyIu8SjfKqL8PTpi/tkY=";
  };

  nativeBuildInputs = [
    glib
    wrapGAppsHook3
  ];

  # pyglet.canvas.xlib.NoSuchDisplayException: Cannot connect to "None"
  doCheck = false;

  postInstall = ''
    substituteInPlace $out/share/applications/*.desktop \
      --replace-fail /usr/bin/ ""
    substituteInPlace $out/share/applications/pronterface.desktop \
      --replace-fail "Path=/usr/share/pronterface/" ""
  '';

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  build-system = with python3Packages; [
    setuptools
    cython
  ];

  dependencies =
    with python3Packages;
    [
      pyserial
      wxpython
      numpy
      pyglet
      psutil
      lxml
      platformdirs
      puremagic
    ]
    ++ lib.optional stdenv.hostPlatform.isLinux dbus-python
    ++ lib.optional stdenv.hostPlatform.isDarwin pyobjc-framework-Cocoa;

  dontWrapGApps = true;
  pyproject = true;
  pythonRelaxDeps = [ "pyglet" ];

  meta = {
    description = "Pronterface, Pronsole, and Printcore - Pure Python 3d printing host software";
    homepage = "https://github.com/kliment/Printrun";
    changelog = "https://github.com/kliment/Printrun/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;
  };
})
