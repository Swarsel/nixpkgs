{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  copyDesktopItems,
  darwin,
  firefox-esr-140-unwrapped,
  gawk,
  libGL,
  makeBinaryWrapper,
  makeDesktopItem,
  nix-update-script,
  nodejs_22,
  pciutils,
  perl,
  python3,
  rsync,
  speechd-minimal,
  unzip,
  wrapGAppsHook3,
  xvfb-run,
  xz,
  zip,
  zotero,
  doCheck ? false,
}:
let
  # note-editor needs nodejs 22. Any newer version fails to build zotero's fork of @benrbray/prosemirror-math during npm install.
  nodejs = nodejs_22;

  pname = "zotero";
  version = "9.0.6";

  src = fetchFromGitHub {
    owner = "zotero";
    repo = "zotero";
    tag = version;
    hash = "sha256-9Rku6iF7Sczqekw8ms8hluIc+B/5BE9zHlBqp7vGlY4=";
    fetchSubmodules = true;
  };

  pdf-js = buildNpmPackage {
    inherit version nodejs;
    pname = "zotero-pdf-js";
    src = "${src}/pdf-worker/pdf.js";
    npmDepsHash = "sha256-KeYAY6EWBZVd3QucDEDtI6lwtTahCEFBFf2Ebib9HKg=";

    buildPhase = ''
      runHook preBuild

      npm exec gulp lib-legacy
      npm exec gulp generic-legacy
      npm exec gulp minified-legacy

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r . $out

      runHook postInstall
    '';
  };

  epub-js = buildNpmPackage {
    inherit version nodejs;
    pname = "zotero-epub-js";
    src = "${src}/reader/epubjs/epub.js";
    npmDepsHash = "sha256-6XY6uczPOpMpRHDQbkQRHKBDDRQ/MXIVepGBx1V+h5Q=";

    buildPhase = ''
      runHook preBuild

      npm run compile
      npm run build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r . $out

      runHook postInstall
    '';
  };

  pdf-reader = buildNpmPackage {
    inherit version nodejs;
    pname = "zotero-pdf-reader";
    src = "${src}/reader";

    patches = [
      ./pdf-reader-locales.patch
      ./pdf-reader-build-fix.patch
    ];

    postPatch = ''
      rm -rf pdfjs/pdf.js
      cp -r ${pdf-js} pdfjs/pdf.js
      chmod -R u+w pdfjs/pdf.js

      rm -rf epubjs/epub.js
      cp -r ${epub-js} epubjs/epub.js
      chmod -R u+w epubjs/epub.js

      mkdir -p locales/en-US/
      cp -r ${src}/chrome/locale/en-US/zotero/* locales/en-US/
    '';

    npmDepsHash = "sha256-8marAeBAW5cKDaJT3xbVsXyVfGa5ehZYUYijDzFng38=";

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r . $out

      runHook postInstall
    '';

    npmBuildScript = "build:zotero";
  };

  pdf-worker = buildNpmPackage {
    inherit version nodejs;
    pname = "zotero-pdf-worker";
    src = "${src}/pdf-worker";

    postPatch = ''
      rm -rf pdf.js
      cp -r ${pdf-js} pdf.js
    '';

    nativeBuildInputs = [
      rsync
    ];

    npmDepsHash = "sha256-TGuN1fZOClzm6xD2rmn5BAemN4mbyOVaLbSRyMeDIm8=";

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r . $out

      runHook postInstall
    '';
  };

  note-editor = buildNpmPackage {
    inherit version nodejs;
    pname = "zotero-note-editor";
    src = "${src}/note-editor";
    patches = [ ./pdf-reader-locales.patch ];

    postPatch = ''
      mkdir -p locales/en-US/
      cp -r ${src}/chrome/locale/en-US/zotero/* locales/en-US/
    '';

    npmDepsHash = "sha256-3KSSm8oCNOIDN/ZHhDbx7+cF20qtjtZwpnCOOWe3WQc=";

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r . $out

      runHook postInstall
    '';

    makeCacheWritable = true;
  };

in
buildNpmPackage (finalAttrs: {
  inherit
    pname
    version
    src
    nodejs
    ;

  inherit doCheck;

  patches = [
    ./avoid-git.patch
    ./js-build-fixes.patch
    ./avoid-xulrunner-fetch.patch
    ./build-fixes.patch
    ./fix-x86_64-darwin.patch
  ];

  postPatch = ''
    rm -rf reader
    cp -r ${pdf-reader} reader
    chmod -R u+w reader

    rm -rf pdf-worker
    cp -r ${pdf-worker} pdf-worker
    chmod -R u+w pdf-worker

    rm -rf note-editor
    cp -r ${note-editor} note-editor
    chmod -R u+w note-editor

    patchShebangs --build app/ test/

    # Skip some flaky/failing tests
    rm test/tests/retractionsTest.js
    for test in \
      "should use BrowserRequest for 403 when enforcing file type" \
      "should use BrowserRequest for a JS redirect page" \
      "should throw error on broken symlink" \
      "should switch dialog from add note to add/edit citation" \
      "should vacuum the database with force option" \
    ; do
      sed -i "s|it(\"$test|it.skip(\"$test|" test/tests/*.js
    done
  '';

  nativeBuildInputs = [
    perl
    python3
    zip
    unzip
    xz
    gawk
    rsync
    copyDesktopItems
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    makeBinaryWrapper
    darwin.autoSignDarwinBinariesHook
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    wrapGAppsHook3
  ];

  npmDepsHash = "sha256-dtbA1V38u26gqWoN+kW/tnccl6HFX7p8fPAneq+mw6U=";
  # Build with test support if `doCheck` is enabled.
  env.ZOTERO_TEST = doCheck;

  buildPhase =
    let
      zoteroArch =
        platform:
        if platform.isAarch64 then
          "arm64"
        else if platform.isx86_64 then
          "x64"
        else if platform.isx86_32 then
          "i686"
        else
          platform.parsed.cpu.name;
    in
    ''
      runHook preBuild

      npm run build

      # Place firefox files at the right place.
      # The correct firefox version can be found in zotero/app/config.sh at `GECKO_VERSION_LINUX`.
      mkdir -p app/xulrunner/
    ''
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      cp -r "${firefox-esr-140-unwrapped}/Applications/Firefox ESR.app" app/xulrunner/Firefox.app
    ''
    + lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
      cp -r "${firefox-esr-140-unwrapped}/lib/firefox" "app/xulrunner/firefox-${stdenv.hostPlatform.parsed.kernel.name}-${
        lib.replaceString "aarch64" "arm64" stdenv.hostPlatform.parsed.cpu.name
      }"
    ''
    + ''
      chmod -R u+w app/xulrunner/

      build_dir=$(mktemp -d)
      ./app/scripts/prepare_build -s ./build -o "$build_dir" -c release
      ./app/build.sh -d "$build_dir" -c release -s \
        ${if stdenv.hostPlatform.isDarwin then "-p m" else "-p l -a ${zoteroArch stdenv.hostPlatform}"}

      runHook postBuild
    '';

  nativeCheckInputs = [
    xvfb-run
  ];

  checkPhase = ''
    runHook preCheck

    CI=true xvfb-run test/runtests.sh

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
  ''
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    # Copy package contents
    mkdir -p $out/Applications
    cp -r app/staging/Zotero.app $out/Applications/
  ''
  + lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    # Copy package contents
    mkdir -p $out/lib/
    cp -r app/staging/*/. $out/lib/

    # Add binary to bin/
    mkdir -p $out/bin/
    ln -s ../lib/zotero $out/bin/zotero

    # Install icons
    for size in 32 64 128; do
      install -Dm444 "app/linux/icons/icon''${size}.png" "$out/share/icons/hicolor/''${size}x''${size}/apps/zotero.png"
    done
    install -Dm444 "app/linux/icons/symbolic.svg" "$out/share/icons/hicolor/scalable/apps/zotero-symbolic.svg"
  ''
  + ''
    runHook postInstall
  '';

  preFixup = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    gappsWrapperArgs+=(--suffix LD_LIBRARY_PATH : ${
      lib.makeLibraryPath [
        libGL
        pciutils
        speechd-minimal
      ]
    })
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/bin
    makeWrapper $out/Applications/Zotero.app/Contents/MacOS/zotero $out/bin/zotero
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Office"
        "Database"
      ];

      comment = finalAttrs.meta.description;
      desktopName = "Zotero";
      exec = "zotero -url %U";
      genericName = "Reference Management";
      icon = "zotero";

      mimeTypes = [
        "x-scheme-handler/zotero"
        "text/plain"
      ];

      name = "zotero";
      startupNotify = true;
    })
  ];

  passthru = {
    tests.build-with-checks = zotero.override {
      doCheck = true;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Collect, organize, cite, and share your research sources";
    homepage = "https://www.zotero.org";
    changelog = "https://www.zotero.org/support/changelog";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      mynacol
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "zotero";
  };
})
