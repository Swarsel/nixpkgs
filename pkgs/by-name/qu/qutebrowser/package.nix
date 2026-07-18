{
  lib,
  stdenv,
  fetchurl,
  asciidoc,
  desktopToDarwinBundle,
  docbook_xml_dtd_45,
  docbook_xsl,
  fetchzip,
  glib-networking,
  libxml2,
  libxslt,
  pipewire,
  python3,
  qt6Packages,
  vulkan-loader,
  wayland,
  widevine-cdm,
  # can cause issues on some graphics chips
  enableVulkan ? false,
  enableWideVine ? false,
  pipewireSupport ? stdenv.hostPlatform.isLinux,
  withPdfReader ? true,
}:

let
  pdfjs =
    let
      version = "5.6.205";
    in
    fetchzip {
      hash = "sha256-JMmxoT68PNJ/MmlMwVNYcHerorklLv5YY6C55xjn73w=";
      stripRoot = false;
      url = "https://github.com/mozilla/pdf.js/releases/download/v${version}/pdfjs-${version}-dist.zip";
    };

  version = "3.7.0";
in

python3.pkgs.buildPythonApplication {
  inherit version;
  pname = "qutebrowser";

  src = fetchurl {
    url = "https://github.com/qutebrowser/qutebrowser/releases/download/v${version}/qutebrowser-${version}.tar.gz";
    hash = "sha256-x/lYhOpeZnXlhAJb6lXP+VDEfXSa/39BX2jaA/zOD5I=";
  };

  patches = [
    ./fix-restart.patch
  ];

  postPatch = ''
    substituteInPlace qutebrowser/misc/quitter.py --subst-var-by qutebrowser "$out/bin/qutebrowser"

    sed -i "s,/usr,$out,g" qutebrowser/utils/standarddir.py
  ''
  + lib.optionalString withPdfReader ''
    sed -i "s,/usr/share/pdf.js,${pdfjs},g" qutebrowser/browser/pdfjs.py
  ''
  + lib.optionalString (lib.meta.availableOn stdenv.hostPlatform wayland) ''
    substituteInPlace qutebrowser/misc/wmname.py \
      --replace-fail '_load_library("wayland-client")' \
                     'ctypes.CDLL("${lib.getLib wayland}/lib/libwayland-client${stdenv.hostPlatform.extensions.sharedLibrary}")'
  '';

  nativeBuildInputs = [
    qt6Packages.wrapQtAppsHook
    asciidoc
    docbook_xml_dtd_45
    docbook_xsl
    libxml2
    libxslt
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin desktopToDarwinBundle;

  buildInputs = [
    qt6Packages.qtbase
    glib-networking
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    qt6Packages.qtwayland
  ];

  # Needs tox
  doCheck = false;

  installPhase = ''
    runHook preInstall

    make -f misc/Makefile \
      PYTHON=${(python3.pythonOnBuildForHost.withPackages (ps: with ps; [ setuptools ])).interpreter} \
      PREFIX=. \
      DESTDIR="$out" \
      DATAROOTDIR=/share \
      install

    runHook postInstall
  '';

  postInstall = ''
    # Patch python scripts
    buildPythonPath "$out $propagatedBuildInputs"
    scripts=$(grep -rl python "$out"/share/qutebrowser/{user,}scripts/)
    for i in $scripts; do
      patchPythonScript "$i"
    done
  '';

  preFixup =
    let
      libPath = lib.makeLibraryPath [ pipewire ];
      resourcesPath =
        if stdenv.hostPlatform.isDarwin then
          "${qt6Packages.qtwebengine}/lib/QtWebEngineCore.framework/Resources"
        else
          "${qt6Packages.qtwebengine}/resources";
    in
    ''
      makeWrapperArgs+=(
        # Force the app to use QT_PLUGIN_PATH values from wrapper
        --unset QT_PLUGIN_PATH
        "''${qtWrapperArgs[@]}"
        # avoid persistant warning on starup
        --set QT_STYLE_OVERRIDE Fusion
        ${lib.optionalString pipewireSupport "--prefix LD_LIBRARY_PATH : ${libPath}"}
        ${lib.optionalString enableVulkan ''
          --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ vulkan-loader ]}
          --set-default QSG_RHI_BACKEND vulkan
        ''}
        ${lib.optionalString enableWideVine ''--add-flags "--qt-flag widevine-path=${widevine-cdm}/share/google/chrome/WidevineCdm/_platform_specific/linux_x64/libwidevinecdm.so"''}
        --set QTWEBENGINE_RESOURCES_PATH "${resourcesPath}"
      )
    '';

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    colorama
    pyyaml
    pyqt6-webengine
    jinja2
    pygments
    # scripts and userscripts libs
    tldextract
    beautifulsoup4
    readability-lxml
    pykeepass
    stem
    pynacl
    # extensive ad blocking
    adblock
    # for the qute-bitwarden user script to be able to copy the TOTP token to clipboard
    pyperclip
  ];

  dontWrapQtApps = true;
  pyproject = true;

  meta = {
    description = "Keyboard-focused browser with a minimal GUI";
    homepage = "https://github.com/qutebrowser/qutebrowser";
    changelog = "https://github.com/qutebrowser/qutebrowser/blob/v${version}/doc/changelog.asciidoc";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      rnhmjoj
      dotlambda
    ];

    platforms = if enableWideVine then [ "x86_64-linux" ] else qt6Packages.qtwebengine.meta.platforms;
    mainProgram = "qutebrowser";
  };
}
