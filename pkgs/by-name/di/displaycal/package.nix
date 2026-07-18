{
  lib,
  argyllcms,
  fetchPypi,
  gtk3,
  librsvg,
  libx11,
  libxext,
  libxinerama,
  libxrandr,
  libxxf86vm,
  python3,
  wrapGAppsHook3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "displaycal";
  version = "3.9.18";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-mHUtO3vVIREzcIv6IFmPlo4nwuPPGDd9+UbIoXfvLYo=";
    pname = "displaycal";
  };

  postPatch = ''
    # 2 conflicting copies of bin/displaycal end up from the installation
    # process (one from pyproject.toml’s gui-scripts, one from setup.py). Keep
    # only the setup.py version. Replace key with an invalide name to be
    # skipped.
    substituteInPlace pyproject.toml \
      --replace-fail "[project.gui-scripts]" "[_project.gui-scripts]" \
  '';

  nativeBuildInputs = [
    wrapGAppsHook3
    gtk3
  ];

  buildInputs = [
    gtk3
    librsvg
    libx11
    libxxf86vm
    libxext
    libxinerama
    libxrandr
  ];

  doCheck = false; # Tests try to access an X11 session and dbus in weird locations.

  preFixup = ''
    makeWrapperArgs+=(
      ''${gappsWrapperArgs[@]}
      --prefix PATH : ${lib.makeBinPath [ argyllcms ]}
      --prefix PYTHONPATH : $PYTHONPATH
    )
  '';

  build-system = with python3.pkgs; [ setuptools_80 ];

  dependencies = with python3.pkgs; [
    build
    certifi
    defusedxml
    wxpython
    dbus-python
    distro
    numpy
    pillow
    psutil
    pychromecast
    pyglet
    pyyaml
    send2trash
    zeroconf
  ];

  dontWrapGApps = true;
  pyproject = true;
  pythonImportsCheck = [ "DisplayCAL" ];
  # Workaround for eoyilmaz/displaycal-py3#261
  setupPyGlobalFlags = [ "appdata" ];

  meta = {
    description = "Display calibration and characterization powered by Argyll CMS (Migrated to Python 3)";
    homepage = "https://github.com/eoyilmaz/displaycal-py3";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ toastal ];
    platforms = lib.platforms.linux;
  };
})
