{
  lib,
  alsa-utils,
  fetchPypi,
  gettext,
  gobject-introspection,
  gtk4,
  libnotify,
  nix-update-script,
  python3Packages,
  safeeyes,
  testers,
  versionCheckHook,
  wlrctl,
  wrapGAppsHook3,
  xprintidle,
  xprop,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "safeeyes";
  version = "3.3.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-11nw13AAqupSIZRrhmDaViO3V/yYK8/xsVF8ylS49Rw=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    gtk4
    gettext
    libnotify
  ];

  doCheck = false; # no tests
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  preFixup = ''
    makeWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
      --prefix PATH : ${
        lib.makeBinPath [
          alsa-utils
          wlrctl
          xprintidle
          xprop
        ]
      }
    )
  '';

  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    babel
    psutil
    python-xlib
    pygobject3
    dbus-python
    packaging
  ];

  # Prevent double wrapping, let the Python wrapper use the args in preFixup.
  dontWrapGApps = true;

  optional-dependencies = with python3Packages; {
    healthstats = [ croniter ];
    wayland = [ pywayland ];
  };

  pyproject = true;
  pythonImportsCheck = [ "safeeyes" ];

  passthru = {
    tests.version = testers.testVersion { package = safeeyes; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Break reminder to prevent eye strain";

    longDescription = ''
      Protect your eyes from eye strain using this simple and
      beautiful, yet extensible break reminder.  Free GNU/Linux
      alternative to EyeLeo.
    '';

    homepage = "http://slgobinath.github.io/SafeEyes";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
    mainProgram = "safeeyes";
  };
})
