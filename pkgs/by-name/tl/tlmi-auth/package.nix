{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  openssl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tlmi-auth";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "lenovo";
    repo = "tlmi-auth";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/juXQrb3MsQ6FxmrAa7E1f0vIMu1397tZ1pzLfr56M4=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  meta = {
    description = "Utility for creating signature strings needed for thinklmi certificate based authentication";
    homepage = "https://github.com/lenovo/tlmi-auth";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ snpschaaf ];
    platforms = lib.platforms.linux;
    mainProgram = "tlmi-auth";
  };
})
