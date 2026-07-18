{
  lib,
  stdenv,
  fetchurl,
  gnome,
  gtk3,
  meson,
  ninja,
  pkg-config,
  wrapGAppsHook3,
  xdg-user-dirs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xdg-user-dirs-gtk";
  version = "0.16";

  src = fetchurl {
    url = "mirror://gnome/sources/xdg-user-dirs-gtk/${lib.versions.majorMinor finalAttrs.version}/xdg-user-dirs-gtk-${finalAttrs.version}.tar.xz";
    hash = "sha256-voJd5/iRddterQzTdE0nYRCccJQyUahwkiWRYwJVIKk=";
  };

  postPatch = ''
    # Fetch “xdg-user-dirs” translations from correct localedir.
    substituteInPlace update.c --replace-fail \
      'bindtextdomain ("xdg-user-dirs", GLIBLOCALEDIR);' \
      'bindtextdomain ("xdg-user-dirs", "${lib.getLib xdg-user-dirs}/share/locale");'

    patchShebangs meson_custom_install_desktop_file.sh
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    xdg-user-dirs
    wrapGAppsHook3
  ];

  buildInputs = [ gtk3 ];

  preFixup = ''
    gappsWrapperArgs+=(--prefix PATH : "${lib.makeBinPath [ xdg-user-dirs ]}")
  '';

  passthru.updateScript = gnome.updateScript {
    packageName = "xdg-user-dirs-gtk";
  };

  meta = {
    description = "Companion to xdg-user-dirs that integrates it into the GNOME desktop and GTK applications";
    homepage = "https://gitlab.gnome.org/GNOME/xdg-user-dirs-gtk";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    mainProgram = "xdg-user-dirs-gtk-update";
    teams = [ lib.teams.gnome ];
  };
})
