{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  glib,
  gtk3,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ayatana-ido";
  version = "0.10.4";

  src = fetchFromGitHub {
    owner = "AyatanaIndicators";
    repo = "ayatana-ido";
    tag = finalAttrs.version;
    sha256 = "sha256-KeErrT2umMaIVfLDr4CcQCmFrMb8/h6pNYbunuC/JtI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    glib # for glib-mkenums
    pkg-config
  ];

  buildInputs = [ gtk3 ];

  meta = {
    description = "Ayatana Display Indicator Objects";
    homepage = "https://github.com/AyatanaIndicators/ayatana-ido";
    changelog = "https://github.com/AyatanaIndicators/ayatana-ido/blob/${finalAttrs.version}/ChangeLog";

    license = [
      lib.licenses.lgpl3Plus
      lib.licenses.lgpl21Plus
    ];

    maintainers = [ lib.maintainers.nickhu ];
    platforms = lib.platforms.linux;
  };
})
