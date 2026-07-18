{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  libx11,
  lv2,
  pkg-config,
  xorgproto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "GxPlugins.lv2";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "brummer10";
    repo = "GxPlugins.lv2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NvmFoOAQtAnKrZgzG1Shy1HuJEWgjJloQEx6jw59hag=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    xorgproto
    cairo
    lv2
  ];

  configurePhase = ''
    runHook preConfigure

    for i in GxBoobTube GxValveCaster; do
      substituteInPlace $i.lv2/Makefile --replace "\$(shell which echo) -e" "echo -e"
    done

    runHook postConfigure
  '';

  installFlags = [ "INSTALL_DIR=$(out)/lib/lv2" ];

  meta = {
    description = "Set of extra lv2 plugins from the guitarix project";
    homepage = "https://github.com/brummer10/GxPlugins.lv2";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.magnetophon ];
    platforms = lib.platforms.linux;
  };
})
