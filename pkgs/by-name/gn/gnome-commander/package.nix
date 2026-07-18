{
  lib,
  stdenv,
  fetchFromGitLab,
  desktop-file-utils,
  exiv2,
  flex,
  gtest,
  itstool,
  libgsf,
  meson,
  ninja,
  pkg-config,
  poppler,
  samba,
  taglib,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-commander";
  version = "1.18.5";

  src = fetchFromGitLab {
    owner = "GNOME";
    repo = "gnome-commander";
    tag = finalAttrs.version;
    hash = "sha256-op9EeBj6axgIPvpwoG3aQF3DOQUVGMlBGHhuXsdG+AU=";
    domain = "gitlab.gnome.org";
  };

  # hard-coded schema paths
  postPatch = ''
    substituteInPlace src/gnome-cmd-data.cc plugins/fileroller/file-roller-plugin.cc \
      --replace-fail \
        '/share/glib-2.0/schemas' \
        '/share/gsettings-schemas/${finalAttrs.finalPackage.name}/glib-2.0/schemas'
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    flex
    itstool
    wrapGAppsHook3
    desktop-file-utils
  ];

  buildInputs = [
    exiv2
    libgsf
    taglib
    poppler
    samba
  ];

  mesonFlags = [ (lib.mesonEnable "tests" finalAttrs.finalPackage.doCheck) ];
  doCheck = false; # gtest requires C/C++17 but the project is written in C/C++11
  checkInputs = [ gtest ];

  meta = {
    description = "Fast and powerful twin-panel file manager for the Linux desktop";
    homepage = "https://gcmd.github.io";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ aleksana ];
    platforms = lib.platforms.linux;
    mainProgram = "gnome-commander";
  };
})
