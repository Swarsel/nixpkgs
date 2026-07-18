{
  lib,
  stdenv,
  fetchurl,
  desktop-file-utils,
  gettext,
  gnome,
  gtk3,
  meson,
  ninja,
  packagekit,
  pkg-config,
  polkit,
  systemd,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-packagekit";
  version = "43.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-packagekit/${lib.versions.major finalAttrs.version}/gnome-packagekit-${finalAttrs.version}.tar.xz";
    hash = "sha256-zaRVplKpI7LqL3Axa9D92Clve2Lu8/r9nOUMjmbF8ZU=";
  };

  postPatch = ''
    patchShebangs meson_post_install.sh
  '';

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
    gettext
    wrapGAppsHook3
    desktop-file-utils
  ];

  buildInputs = [
    gtk3
    packagekit
    systemd
    polkit
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gnome-packagekit";
    };
  };

  meta = {
    description = "Tools for installing software on the GNOME desktop using PackageKit";
    homepage = "https://www.freedesktop.org/software/PackageKit/";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.gnome ];
  };
})
