{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch2,
  hunspell,
  pkg-config,
  qt6,
  qt6Packages,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "texstudio";
  version = "4.9.5";

  src = fetchFromGitHub {
    owner = "texstudio-org";
    repo = "texstudio";
    rev = finalAttrs.version;
    hash = "sha256-//UhDSyCFIy/xhOKrTVoZFA0nh6q9xShAI5GxJrNz4w=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-w4/u8ObJSQqHisZmxMSpJeveE+DJSgLqnfpEnizHsBg=";
      name = "disable-auto-update.patch";
      url = "https://sources.debian.org/data/main/t/texstudio/4.9.1%2Bds-1/debian/patches/0004-disable-auto-update.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
    pkg-config
  ];

  buildInputs = [
    hunspell
    qt6.qt5compat
    qt6.qtbase
    qt6.qtsvg
    qt6.qttools
    qt6Packages.poppler
    qt6Packages.quazip
    zlib
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    qt6.qtwayland
  ];

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p "$out/Applications"
    mv "$out/bin/texstudio.app" "$out/Applications"
    rm -d "$out/bin"
  '';

  meta = {
    description = "TeX and LaTeX editor";

    longDescription = ''
      Fork of TeXMaker, this editor is a full fledged IDE for
      LaTeX editing with completion, structure viewer, preview,
      spell checking and support of any compilation chain.
    '';

    homepage = "https://texstudio.org";
    changelog = "https://github.com/texstudio-org/texstudio/blob/${finalAttrs.version}/utilities/manual/source/CHANGELOG.md";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      ajs124
      cfouche
    ];

    platforms = lib.platforms.unix;
    mainProgram = "texstudio";
  };
})
