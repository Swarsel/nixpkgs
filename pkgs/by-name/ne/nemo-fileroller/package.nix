{
  lib,
  stdenv,
  fetchFromGitHub,
  cinnamon-translations,
  file-roller,
  glib,
  gtk3,
  meson,
  nemo,
  ninja,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nemo-fileroller";
  version = "6.6.0";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "nemo-extensions";
    rev = finalAttrs.version;
    hash = "sha256-tXeMkaCYnWzg+6ng8Tyg4Ms1aUeE3xiEkQ3tKEX6Vv8=";
  };

  postPatch = ''
    substituteInPlace src/nemo-fileroller.c \
      --replace "file-roller" "${lib.getExe file-roller}" \
      --replace "GNOMELOCALEDIR" "${cinnamon-translations}/share/locale"
  '';

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
  ];

  buildInputs = [
    glib
    gtk3
    nemo
  ];

  env.PKG_CONFIG_LIBNEMO_EXTENSION_EXTENSIONDIR = "${placeholder "out"}/${nemo.extensiondir}";
  sourceRoot = "${finalAttrs.src.name}/nemo-fileroller";

  meta = {
    description = "Nemo file roller extension";
    homepage = "https://github.com/linuxmint/nemo-extensions/tree/master/nemo-fileroller";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.cinnamon ];
  };
})
