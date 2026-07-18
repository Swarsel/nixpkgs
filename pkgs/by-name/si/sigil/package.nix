{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  pkg-config,
  python3Packages,
  qt6,
  xercesc,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sigil";
  version = "2.7.6";

  src = fetchFromGitHub {
    owner = "Sigil-Ebook";
    repo = "Sigil";
    tag = finalAttrs.version;
    hash = "sha256-GbOTXyxj8HxEE833jUADzKbWpkzXHwjyoj9haIWB9Xk=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    boost
    xercesc
    qt6.qtbase
    qt6.qttools
    qt6.qtwebengine
    qt6.qtsvg
    python3Packages.lxml
    python3Packages.dulwich
  ];

  installPhase = lib.optionalString stdenv.hostPlatform.isDarwin ''
    runHook preInstall

    mkdir -p $out/Applications
    mv bin/Sigil.app $out/Applications
    # https://github.com/NixOS/nixpkgs/issues/186653
    chmod -x $out/Applications/Sigil.app/Contents/lib/*.dylib \
      $out/Applications/Sigil.app/Contents/polyfills/*.js \
      $out/Applications/Sigil.app/Contents/python3lib/*.py \
      $out/Applications/Sigil.app/Contents/hunspell_dictionaries/*.{aff,dic}

    runHook postInstall
  '';

  preFixup = ''
    qtWrapperArgs+=(--prefix PYTHONPATH : "$PYTHONPATH")
  '';

  dontWrapQtApps = true;

  fixupPhase =
    let
      sigil =
        if stdenv.hostPlatform.isDarwin then
          "$out/Applications/Sigil.app/Contents/MacOS/Sigil"
        else
          "$out/bin/sigil";
    in
    ''
      runHook preFixup

      wrapQtApp "${sigil}"

      runHook postFixup
    '';

  prePatch = ''
    sed -i '/^QTLIB_DIR=/ d' src/Resource_Files/bash/sigil-sh_install
  '';

  pythonPath = with python3Packages; [
    lxml
    dulwich
  ];

  meta = {
    description = "Free, open source, multi-platform ebook (ePub) editor";
    homepage = "https://github.com/Sigil-Ebook/Sigil/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ prince213 ];
    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "sigil";
  };
})
