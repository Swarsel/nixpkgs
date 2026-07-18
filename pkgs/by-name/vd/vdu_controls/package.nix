{
  lib,
  fetchFromGitHub,
  copyDesktopItems,
  fetchpatch,
  installShellFiles,
  python3,
  qt6,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "vdu_controls";
  version = "2.4.3";

  src = fetchFromGitHub {
    owner = "digitaltrails";
    repo = "vdu_controls";
    rev = "v${finalAttrs.version}";
    hash = "sha256-aapODSWPB98I/ieUTXIO7nrd11VY9SmFpsVR1ketsZU=";
  };

  patches = [
    # Standardize installation with pypa/build. See:
    # https://github.com/digitaltrails/vdu_controls/pull/120
    (fetchpatch {
      hash = "sha256-W0Iv3RXQFnHAzaXHh6ZvGARN4ShsNgOhg9FTpbvnfLo=";
      url = "https://github.com/digitaltrails/vdu_controls/commit/ef2ed07398fc88ccc18a11da3cf5ea1500a03cb6.patch";
    })
  ];

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
    copyDesktopItems
    installShellFiles
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwayland
  ];

  # Replace FHS paths with out paths. Unfortunately it will be pretty hard to
  # change this behavior upstream, as they barely use any packaging system
  # whatsoever.
  preBuild = ''
    substituteInPlace vdu_controls.py \
        --replace-fail /usr/share/vdu_controls $out/share/vdu_controls
  '';

  postInstall = ''
    install -Dm066 vdu_controls.png $out/share/icons/hicolor/256x256/apps/vdu_controls.png
    make -C docs man
    installManPage docs/_build/man/vdu_controls.1
    mkdir -p $out/share/vdu_controls
    cp -r icons $out/share/vdu_controls
    cp -r sample-scripts $out/share/vdu_controls
    cp -r translations $out/share/vdu_controls
  '';

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
  '';

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.sphinx
  ];

  dependencies = [
    python3.pkgs.pyqt6
  ];

  desktopItems = "vdu_controls.desktop";
  pyproject = true;

  meta = {
    description = "VDU controls - a control panel for monitor brightness/contrast";
    homepage = "https://github.com/digitaltrails/vdu_controls";
    license = lib.licenses.gpl3Only;
    mainProgram = "vdu_controls";
  };
})
