{
  lib,
  stdenv,
  fetchFromGitHub,
  ayatana-ido,
  cmake,
  glib,
  gtk3,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libayatana-indicator";
  version = "0.9.4";

  src = fetchFromGitHub {
    owner = "AyatanaIndicators";
    repo = "libayatana-indicator";
    rev = finalAttrs.version;
    sha256 = "sha256-OsguZ+jl274uPSCTFHq/ZwUE3yHR7MlUPHCpfmn1F7A=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    glib # for glib-mkenums
    pkg-config
  ];

  buildInputs = [ gtk3 ];
  propagatedBuildInputs = [ ayatana-ido ];

  meta = {
    description = "Ayatana Indicators Shared Library";
    homepage = "https://github.com/AyatanaIndicators/libayatana-indicator";
    changelog = "https://github.com/AyatanaIndicators/libayatana-indicator/blob/${finalAttrs.version}/ChangeLog";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.nickhu ];
    platforms = lib.platforms.linux;
  };
})
