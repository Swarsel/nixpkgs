{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  libsForQt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dotherside";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "filcuc";
    repo = "dotherside";
    tag = "v${finalAttrs.version}";
    hash = "sha256-o6RMjJz9vtfCsm+F9UYIiYPEaQn+6EU5jOTLhNHCwo4=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    (fetchpatch {
      hash = "sha256-xPMfSbTI8HWK6UYYFPATsz29lKbunm43JnaageTBZeY=";
      name = "bump-minimal-cmake-required-version.patch";
      url = "https://github.com/filcuc/dotherside/commit/56cb910b368ad0f8ef1f18ef52d46ab8136ca5d6.patch?full_index=1";
    })
  ];

  nativeBuildInputs = [
    cmake
    libsForQt5.wrapQtAppsHook
  ];

  buildInputs = [
    libsForQt5.qtbase
    libsForQt5.qtquickcontrols2
  ];

  meta = {
    description = "C language library for creating bindings for the Qt QML language";
    homepage = "https://filcuc.github.io/dotherside";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ toastal ];
    platforms = lib.platforms.linux;
  };
})
