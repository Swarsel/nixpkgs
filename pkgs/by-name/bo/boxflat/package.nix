{
  lib,
  fetchFromGitHub,
  copyDesktopItems,
  gobject-introspection,
  gtk4,
  libadwaita,
  makeDesktopItem,
  nix-update-script,
  python3Packages,
  udevCheckHook,
  wrapGAppsHook4,
}:

python3Packages.buildPythonPackage (finalAttrs: {
  pname = "boxflat";
  version = "1.35.5";

  src = fetchFromGitHub {
    owner = "Lawstorant";
    repo = "boxflat";
    tag = "v${finalAttrs.version}";
    hash = "sha256-R03mQIsa6T1ApV8SMWvilBfiCGcAWvyZ5hDDgAuGd6s=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    wrapGAppsHook4
    gobject-introspection
    udevCheckHook
  ];

  propagatedBuildInputs = [
    gtk4
    libadwaita

    python3Packages.pyyaml
    python3Packages.psutil
    python3Packages.pyserial
    python3Packages.pycairo
    python3Packages.pygobject3
    python3Packages.evdev
  ];

  preBuild = ''
    cat > setup.py << EOF
    import shutil
    from setuptools import setup

    with open('requirements.txt') as f:
        install_requires = f.read().splitlines()

    shutil.copyfile('entrypoint.py', 'boxflat/entrypoint.py')

    setup(
      name='boxflat',
      packages=['boxflat', 'boxflat.panels', 'boxflat.widgets'],
      version='${finalAttrs.version}',
      install_requires=install_requires,
      entry_points={
        'console_scripts': ['boxflat=boxflat.entrypoint:main']
      },
    )
    EOF
  '';

  preInstall = ''
    mkdir -p $out/{usr/share/boxflat,lib/udev/rules.d,share/icons}
    cp -r data "$out/usr/share/boxflat/"
    cp -r icons "$out/share/icons/hicolor"
    cp -r udev "$out/usr/share/boxflat"
    cp udev/99-boxflat.rules "$out/lib/udev/rules.d/"
  '';

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
    makeWrapperArgs+=(--add-flags "--data-path $out/usr/share/boxflat/data")
  '';

  build-system = [ python3Packages.setuptools ];

  desktopItems = [
    (makeDesktopItem rec {
      categories = [
        "Game"
        "Utility"
      ];

      comment = "Moza Racing settings app";
      desktopName = name;
      exec = "boxflat";
      genericName = "settings";
      icon = "io.github.lawstorant.boxflat";

      keywords = [
        "game"
        "racing"
        "cars"
        "wheels"
        "moza"
      ];

      name = "Boxflat";
      startupNotify = true;
      startupWMClass = icon;
    })
  ];

  dontWrapGApps = true;
  pyproject = true;

  pythonRelaxDeps = [
    "psutil"
    "evdev"
    "pycairo"
    "pygobject"
    "PyYAML"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Control your Moza gear settings";
    homepage = "https://github.com/Lawstorant/boxflat";
    changelog = "https://github.com/Lawstorant/boxflat/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ racci ];
    platforms = lib.platforms.linux;
    mainProgram = "boxflat";
  };
})
