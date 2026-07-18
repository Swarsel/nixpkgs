{
  lib,
  stdenv,
  fetchFromGitHub,
  gtk4,
  meson,
  ninja,
  pkg-config,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ryokucha";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "ryonakano";
    repo = "ryokucha";
    rev = finalAttrs.version;
    hash = "sha256-imKZSbNZHKIbLtD9E0D+AaKTvGSz8u2/2dJR0cpn/fo=";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    vala
  ];

  buildInputs = [ gtk4 ];

  meta = {
    description = "GTK4 library that includes customized widgets";
    homepage = "https://github.com/ryonakano/ryokucha";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.unix;
  };
})
