{
  lib,
  fetchFromGitHub,
  copyDesktopItems,
  makeDesktopItem,
  nix-update-script,
  p7zip,
  python3,
  qt6,
  versionCheckHook,
  archiveSupport ? true,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "kcc";
  version = "9.6.2";

  src = fetchFromGitHub {
    owner = "ciromattia";
    repo = "kcc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Yix0uqSHeWcNw9r0SOhYqTw8A/fTUh3HAOnbgNaQndY=";
  };

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
    copyDesktopItems
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwayland
  ];

  postInstall = ''
    install -Dm644 \
      icons/comic2ebook.png \
      "$out/share/icons/hicolor/256x256/apps/kcc.png"
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  build-system = with python3.pkgs; [ setuptools ];

  dependencies = with python3.pkgs; [
    packaging # undeclared dependency
    pymupdf
    pyside6
    pillow
    psutil
    python-slugify
    raven
    requests
    mozjpeg_lossless_optimization
    natsort
    distro
    numpy
  ];

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Graphics" ];
      comment = "A comic and manga converter for ebook readers";
      desktopName = "Kindle Comic Converter";
      exec = "kcc";
      icon = "kcc";
      name = "kcc";
    })
  ];

  # Note: python scripts wouldn't get wrapped anyway, but let's be explicit about it
  dontWrapQtApps = true;

  makeWrapperArgs = [
    "\${qtWrapperArgs[@]}"
  ]
  ++ lib.optionals archiveSupport [
    "--prefix PATH : ${lib.makeBinPath [ p7zip ]}"
  ];

  pyproject = true;
  versionCheckProgram = "${placeholder "out"}/bin/kcc-c2e";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Python app to convert comic/manga files or folders to EPUB, Panel View MOBI or E-Ink optimized CBZ";
    homepage = "https://kcc.iosphe.re";
    changelog = "https://github.com/ciromattia/kcc/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.isc;

    maintainers = with lib.maintainers; [
      dawidsowa
      adfaure
    ];

    mainProgram = "kcc";
  };
})
