{
  lib,
  stdenv,
  fetchFromGitHub,
  cargo,
  meson,
  ninja,
  rustPlatform,
  rustc,
  xdg-desktop-portal,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xdg-desktop-portal-shana";
  version = "0.3.16";

  src = fetchFromGitHub {
    owner = "Decodetalkers";
    repo = "xdg-desktop-portal-shana";
    rev = "v${finalAttrs.version}";
    hash = "sha256-NFeXM2ujv9F9vPyRm1mFbLuThwTki5Uu2DEEwPpHK30=";
  };

  nativeBuildInputs = [
    meson
    rustc
    rustPlatform.cargoSetupHook
    cargo
    ninja
  ];

  buildInputs = [
    xdg-desktop-portal
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-2cPUNxZhrqJ9ODAi6MshlJIdLZGssA85ZFmbrqEE1p4=";
  };

  meta = {
    description = "Filechooser portal backend for any desktop environment";
    homepage = "https://github.com/Decodetalkers/xdg-desktop-portal-shana";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      samuelefacenda
      Rishik-Y
      Gliczy
    ];

    platforms = lib.platforms.linux;
  };
})
