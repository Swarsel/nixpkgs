{
  lib,
  stdenv,
  fetchFromGitHub,
  copyDesktopItems,
  fetchzip,
  makeBinaryWrapper,
  makeDesktopItem,
  nix-update-script,
  python3Packages,
  replaceVars,
  steam,
  todds,
}:
let
  pname = "rimsort";
  version = "1.0.76";

  src = fetchFromGitHub {
    owner = "RimSort";
    repo = "RimSort";
    tag = "v${version}";
    hash = "sha256-EO1j4GPRQSB+QEF4tB87x4nCUKpdWU9aGlDFghwxar0=";
    fetchSubmodules = true;
  };

  steamworksSrc = fetchzip {
    hash = "sha256-yDA92nGj3AKTNI4vnoLaa+7mDqupQv0E4YKRRUWqyZw=";
    url = "https://web.archive.org/web/20250527013243/https://partner.steamgames.com/downloads/steamworks_sdk_162.zip"; # Steam sometimes requires auth to download.
  };

  steamfiles = python3Packages.buildPythonPackage {
    inherit version;
    pname = "steamfiles";
    src = "${src}/submodules/steamfiles";

    dependencies = with python3Packages; [
      protobuf
      protobuf3-to-dict
    ];

    format = "setuptools";
  };

  steam-run =
    (steam.override {
      privateTmp = false;
    }).run;
in

stdenv.mkDerivation (finalAttrs: {
  inherit pname;
  inherit version;
  inherit src;

  patches = [
    (replaceVars ./todds-path.patch { inherit todds; })
    (replaceVars ./steam-run.patch { inherit steam-run; })
  ];

  nativeBuildInputs = [
    makeBinaryWrapper
    copyDesktopItems
  ];

  buildInputs = [
    todds
    steamfiles
  ]
  ++ builtins.attrValues {
    inherit (python3Packages)
      beautifulsoup4
      certifi
      chardet
      imageio
      loguru
      lxml
      msgspec
      natsort
      networkx
      packaging
      platformdirs
      psutil
      pygit2
      pygithub
      pyperclip
      pyside6
      requests
      sqlalchemy
      steam
      toposort
      watchdog
      xmltodict
      zstandard
      steamworkspy
      ;
  };

  doCheck = true;

  nativeCheckInputs = with python3Packages; [
    aiohttp
    pytest-asyncio
    pytestCheckHook
    pytest-cov-stub
    pytest-mock
    pytest-qt
    pytest-xvfb
    rapidfuzz
  ];

  preCheck = ''
    export QT_DEBUG_PLUGINS=1
    export QT_QPA_PLATFORM=offscreen
    export HOME=$(mktemp -d) # Some tests require a writable directory
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/rimsort
    cp -r ./* $out/lib/rimsort/

    mkdir -p $out/bin

    makeBinaryWrapper \
      ${python3Packages.python.interpreter} \
      $out/bin/rimsort \
      --add-flags "-m app" \
      --chdir $out/lib/rimsort \
      --prefix PYTHONPATH : "$PYTHONPATH" \
      --set RIMSORT_DISABLE_UPDATER 1

    install -D ./themes/default-icons/AppIcon_a.png $out/share/icons/hicolor/512x512/apps/rimsort.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      comment = "RimWorld Mod Manager";
      desktopName = "RimSort";
      exec = "rimsort";
      icon = "rimsort";
      name = "RimSort";
    })
  ];

  disabledTestPaths = [
    # requires network (clones GitHub: Community-Rules-Database, Steam-Workshop-Database)
    "tests/models/metadata/test_metadata_factory.py"
  ];

  dontBuild = true;
  pytestFlags = [ "--doctest-modules" ];
  sourceRoot = "source";

  unpackPhase = ''
    runHook preUnpack

    cp -r ${finalAttrs.src} source
    chmod -R 755 source
    cp ${steamworksSrc}/redistributable_bin/linux64/libsteam_api.so source/

    runHook postUnpack
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      # To skip checking the pre-release 'Edge' release as 'vEdge'.
      "--version-regex"
      "v([0-9.]+)"
    ];
  };

  meta = {
    description = "Open source mod manager for the video game RimWorld";
    homepage = "https://github.com/RimSort/RimSort";

    license = with lib.licenses; [
      gpl3Only
      # For libsteam_api.so
      (
        unfreeRedistributable
        // {
          url = "https://partner.steamgames.com/documentation/sdk_access_agreement";
        }
      )
    ];

    maintainers = with lib.maintainers; [ weirdrock ];
    # steamworksSrc is x86_64-linux only
    platforms = [ "x86_64-linux" ];
    mainProgram = "rimsort";
  };
})
