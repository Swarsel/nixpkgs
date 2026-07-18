{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  flam3,
  libjpeg,
  libpng,
  libsForQt5,
  libxml2,
  lua,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qosmic";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "bitsed";
    repo = "qosmic";
    rev = "v${finalAttrs.version}";
    sha256 = "13nw1mkdib14430r21mj352v62vi546vf184vyhxm7yjjygyra1w";
  };

  patches = [
    # Allow overriding PREFIX (to install to $out,
    # written while creating this derivation)
    # https://github.com/bitsed/qosmic/pull/39
    (fetchpatch {
      name = "allow-overriding-PREFIX.patch";
      sha256 = "0v9hj9s78cb6bg8ca0wjkbr3c7ml1n51n8h4a70zpzzgzz7rli5b";
      url = "https://github.com/bitsed/qosmic/commit/77fb3a577b0710efae2a1d9ed97c26ae16f3a5ba.patch";
    })
    # Fix QButtonGroup include errors with Qt 5.11:
    # Will be part of the next post-1.6.0 release
    (fetchpatch {
      name = "fix-class-QButtonGroup-include-errors-with-Qt-5.11.patch";
      sha256 = "0bp6b759plkqs32nvfpkfvf3qqzc9716k3ycwnjvwabbvpg1xwbl";
      url = "https://github.com/bitsed/qosmic/commit/3f6e1ea8d384a124dbc2d568171a4da798480752.patch";
    })
  ];

  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace qosmic.pro \
      --replace "/share" "/Applications/qosmic.app/Contents/Resources" \
      --replace "/qosmic/scripts" "/scripts" \
      --replace "install_icons install_desktop" ""
  '';

  nativeBuildInputs = [
    libsForQt5.qmake
    libsForQt5.wrapQtAppsHook
    pkg-config
  ];

  buildInputs = [
    libsForQt5.qtbase
    lua
    flam3
    libxml2
    libpng
    libjpeg
  ];

  preInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p $out/Applications
    mv qosmic.app $out/Applications
  '';

  qmakeFlags = [
    # Use pkg-config to correctly locate library paths
    "CONFIG+=link_pkgconfig"
  ];

  meta = {
    description = "Cosmic recursive flame fractal editor";
    homepage = "https://github.com/bitsed/qosmic";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.raboof ];
    platforms = lib.platforms.unix;
    mainProgram = "qosmic";
  };
})
