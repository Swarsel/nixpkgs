{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  ffmpeg,
  makeDesktopItem,
  miniupnpc,
  python3Packages,
  qt6,
  swftools,
  writableTmpDirAsHomeHook,
  enableSwftools ? false,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "hydrus";
  version = "675";

  src = fetchFromGitHub {
    owner = "hydrusnetwork";
    repo = "hydrus";
    tag = "v${finalAttrs.version}";
    hash = "sha256-c/jt7CnGCbyTEtR/OW0IkRp9OeUnypfuS+yUZR6Nshs=";
  };

  outputs = [
    "out"
    "doc"
  ];

  nativeBuildInputs = [
    qt6.wrapQtAppsHook
    python3Packages.mkdocs-material
    copyDesktopItems
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtcharts
  ];

  # Tests crash even with __darwinAllowLocalNetworking enabled
  # hydrus.core.HydrusExceptions.DataMissing: That service was not found!
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs =
    (with python3Packages; [
      mock
      httmock
    ])
    ++ [
      writableTmpDirAsHomeHook
    ];

  checkPhase = ''
    runHook preCheck

    export QT_QPA_PLATFORM=offscreen
    $out/bin/hydrus-test

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    # Move the hydrus module and related directories
    mkdir -p $out/${python3Packages.python.sitePackages}
    mv hydrus static $out/${python3Packages.python.sitePackages}
    # Fix random files being marked with execute permissions
    chmod -x $out/${python3Packages.python.sitePackages}/static/*.{png,svg,ico}
    # Build docs
    mkdocs build -d help
    mkdir -p $doc/share/doc
    mv help $doc/share/doc/hydrus

    # install the hydrus binaries
    mkdir -p $out/bin
    install -m0755 hydrus_server.py $out/bin/hydrus-server
    install -m0755 hydrus_client.py $out/bin/hydrus-client
    install -m0755 hydrus_test.py $out/bin/hydrus-test

    # desktop item
    mkdir -p "$out/share/icons/hicolor/scalable/apps"
    ln -s "$doc/share/doc/hydrus/assets/hydrus-white.svg" "$out/share/icons/hicolor/scalable/apps/hydrus-client.svg"
  ''
  + lib.optionalString enableSwftools ''
    mkdir -p $out/${python3Packages.python.sitePackages}/bin
    # swfrender seems to have to be called sfwrender_linux
    # not sure if it can be loaded through PATH, but this is simpler
    # $out/python3Packages.python.sitePackages/bin is correct NOT .../hydrus/bin
    ln -s ${swftools}/bin/swfrender $out/${python3Packages.python.sitePackages}/bin/swfrender_linux
  ''
  + ''
    runHook postInstall
  '';

  preFixup = ''
    makeWrapperArgs+=("''${qtWrapperArgs[@]}")
    makeWrapperArgs+=(--prefix PATH : ${
      lib.makeBinPath [
        ffmpeg
        miniupnpc
      ]
    })
  '';

  dependencies = with python3Packages; [
    beautifulsoup4
    cbor2
    chardet
    cloudscraper
    dateparser
    html5lib
    lxml
    lz4
    numpy
    opencv4
    olefile
    pillow
    pillow-heif
    psutil
    psd-tools
    pympler
    pyopenssl
    pyqt6
    pyqt6-charts
    pysocks
    python-dateutil
    python3Packages.mpv
    pyyaml
    qtpy
    requests
    show-in-file-manager
    send2trash
    service-identity
    twisted
  ];

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "FileTools"
        "Utility"
      ];

      comment = finalAttrs.meta.description;
      desktopName = "Hydrus Client";
      exec = "hydrus-client";
      icon = "hydrus-client";
      name = "hydrus-client";
      terminal = false;
      type = "Application";
    })
  ];

  dontWrapQtApps = true;
  pyproject = false;

  meta = {
    description = "Danbooru-like image tagging and searching system for the desktop";
    homepage = "https://hydrusnetwork.github.io/hydrus/";
    changelog = "https://github.com/hydrusnetwork/hydrus/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.wtfpl;

    maintainers = with lib.maintainers; [
      dandellion
      evanjs
      KunyaKud
    ];
  };
})
