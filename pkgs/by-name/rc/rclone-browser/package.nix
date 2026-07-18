{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  qt5,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rclone-browser";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "kapitainsky";
    repo = "RcloneBrowser";
    tag = finalAttrs.version;
    hash = "sha256-Y0QFzpvAV01k9fYN5iMpxd8A+ThLePDtxdG7eX2bk5E=";
  };

  patches = [
    # patch for Qt 5.15, https://github.com/kapitainsky/RcloneBrowser/pull/126
    (fetchpatch {
      hash = "sha256-iAEeYDqW//CvSsu7j0B+aLMeIgr3NiKT2vVgVakTpFo=";
      url = "https://github.com/kapitainsky/RcloneBrowser/commit/ce9cf52e9c584a2cc85a5fa814b0fd7fa9cf0152.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    qt5.wrapQtAppsHook
  ];

  buildInputs = [ qt5.qtbase ];
  cmakeFlags = [ "-DCMAKE_POLICY_VERSION_MINIMUM=3.10" ];

  meta = {
    description = "Graphical Frontend to Rclone written in Qt";
    homepage = "https://github.com/kapitainsky/RcloneBrowser";
    changelog = "https://github.com/kapitainsky/RcloneBrowser/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ dotlambda ];
    platforms = lib.platforms.linux;
    mainProgram = "rclone-browser";
  };
})
