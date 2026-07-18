{
  lib,
  stdenv,
  fetchFromGitLab,
  atkmm,
  cmake,
  gettext,
  glib,
  gtkmm4,
  libGL,
  libdrm,
  libgbm,
  pciutils,
  pkg-config,
  pugixml,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "adriconf";
  version = "2.7.3";

  src = fetchFromGitLab {
    owner = "mesa";
    repo = "adriconf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MRZYAinBL4fzj/Nhhn22sJgupVMpoeeyOYYWTr+fK+E=";
    domain = "gitlab.freedesktop.org";
  };

  # fix build with c23
  #    error: 'uint16_t' does not name a type
  postPatch = ''
    sed -i '1i #include <cstdint>' adriconf/ValueObject/GPUInfo.h
  '';

  nativeBuildInputs = [
    cmake
    gettext # msgfmt
    glib # glib-compile-resources
    pkg-config
  ];

  buildInputs = [
    libdrm
    libGL
    atkmm
    gtkmm4
    pugixml
    libgbm
    pciutils
  ];

  # tries to download googletest
  cmakeFlags = [ "-DENABLE_UNIT_TESTS=off" ];

  postInstall = ''
    install -Dm444 ../flatpak/org.freedesktop.adriconf.metainfo.xml \
      -t $out/share/metainfo/
    install -Dm444 ../flatpak/org.freedesktop.adriconf.desktop \
      -t $out/share/applications/
    install -Dm444 ../flatpak/org.freedesktop.adriconf.png \
      -t $out/share/icons/hicolor/256x256/apps/
  '';

  meta = {
    description = "GUI tool used to configure open source graphics drivers";
    homepage = "https://gitlab.freedesktop.org/mesa/adriconf/";
    changelog = "https://gitlab.freedesktop.org/mesa/adriconf/-/releases/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ muscaln ];
    platforms = lib.platforms.linux;
    mainProgram = "adriconf";
  };
})
