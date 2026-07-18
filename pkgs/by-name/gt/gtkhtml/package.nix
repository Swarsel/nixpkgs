{
  lib,
  stdenv,
  fetchurl,
  adwaita-icon-theme,
  autoreconfHook,
  enchant,
  fetchpatch,
  gnome,
  gsettings-desktop-schemas,
  gtk3,
  intltool,
  isocodes,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gtkhtml";
  version = "4.10.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gtkhtml/${lib.versions.majorMinor finalAttrs.version}/gtkhtml-${finalAttrs.version}.tar.xz";
    hash = "sha256-yjtkJPssesXZy4/a+2kxj6LoJcnPbtF9HjjZsp5WBsM=";
  };

  patches = [
    # Enables enchant2 support.
    # Upstream is dead, no further releases are coming.
    (fetchpatch {
      extraPrefix = "";
      hash = "sha256-f0OToWGHZwxvqf+0qosfA9FfwJ/IXfjIPP5/WrcvArI=";
      name = "enchant-2.patch";
      url = "https://aur.archlinux.org/cgit/aur.git/plain/enchant-2.patch?h=gtkhtml4&id=0218303a63d64c04d6483a6fe9bb55063fcfaa43";
    })
    # Resolves a GCC14 missing typecast error
    ./typecast.diff
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    intltool
  ];

  buildInputs = [
    gtk3
    adwaita-icon-theme
    gsettings-desktop-schemas
  ];

  propagatedBuildInputs = [
    enchant
    isocodes
  ];

  passthru = {
    updateScript = gnome.updateScript { packageName = "gtkhtml"; };
  };

  meta = {
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
