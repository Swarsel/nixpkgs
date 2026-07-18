{
  lib,
  fetchFromGitHub,
  djvulibre,
  ghostscript,
  # libs
  gobject-introspection,
  goocanvas_2,
  imagemagickBig,
  libtiff,
  poppler-utils,
  python3,
  qpdf,
  tesseract,
  unpaper,
  wrapGAppsHook3,
  # tests
  writableTmpDirAsHomeHook,
  xvfb,
}:

let
  runtimeExecDeps = [
    unpaper
    tesseract
    djvulibre
    libtiff
    qpdf
  ];

in
python3.pkgs.buildPythonApplication rec {
  pname = "scantpaper";
  version = "3.0.11";

  src = fetchFromGitHub {
    owner = "carygravel";
    repo = "scantpaper";
    tag = "v${version}";
    hash = "sha256-6zjIEwDHdOIAIucV4T/zY10F80nQNOgnRkA+i2n7Sng=";
  };

  postPatch = ''
    # disable formatting check, which breaks on Black version change
    substituteInPlace pyproject.toml \
      --replace "--black" ""
  '';

  strictDeps = true;

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
    writableTmpDirAsHomeHook
  ];

  nativeCheckInputs =
    (with python3.pkgs; [
      pytestCheckHook
      pytest-cov # segfault with pytest-cov-stub
      pytest-mock
      pytest-xvfb
      pytest-timeout
    ])
    ++ [
      xvfb
      imagemagickBig # "big" version needed for text rendering in tests
      poppler-utils
      ghostscript
    ]
    ++ runtimeExecDeps;

  postInstall = ''
    install -Dm644 \
      icons/hicolor/scalable/apps/scantpaper.svg \
      $out/share/icons/hicolor/scalable/apps/scantpaper.svg

    install -Dm444 \
      org.scantpaper.desktop \
      $out/share/applications/org.scantpaper.desktop
  '';

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  __structuredAttrs = true;

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies =
    (with python3.pkgs; [
      img2pdf
      ocrmypdf
      pycairo
      pygobject3
      sane
      tesserocr
      python-iso639
    ])
    ++ [
      goocanvas_2
    ];

  dontWrapGApps = true;

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath runtimeExecDeps)
  ];

  pyproject = true;

  meta = with lib; {
    description = "GUI to produce PDFs or DjVus from scanned documents";
    homepage = "https://github.com/carygravel/scantpaper";
    changelog = "https://github.com/carygravel/scantpaper/blob/${src.tag}/changelog.md";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ euxane ];
    platforms = platforms.linux;
    mainProgram = "scantpaper";
  };
}
