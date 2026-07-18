{
  lib,
  stdenv,
  fetchurl,
  gtk2,
  iconnamingutils,
  intltool,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnome-icon-theme";
  version = "3.12.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-icon-theme/${lib.versions.majorMinor finalAttrs.version}/gnome-icon-theme-${finalAttrs.version}.tar.xz";
    sha256 = "0fjh9qmmgj34zlgxb09231ld7khys562qxbpsjlaplq2j85p57im";
  };

  nativeBuildInputs = [
    intltool
    iconnamingutils
    gtk2
  ];

  postInstall = lib.optionalString (!stdenv.hostPlatform.isMusl) ''
    # remove a tree of dirs with no files within
    rm -r "$out/share/locale"
  '';

  allowedReferences = [ ];

  depsBuildBuild = [
    pkg-config
  ];

  dontDropIconThemeCache = true;

  meta = {
    description = "Collection of icons for the GNOME 2 desktop";
    homepage = "https://download.gnome.org/sources/gnome-icon-theme/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin; # never built on Hydra https://hydra.nixos.org/job/nixpkgs/trunk/gnome-icon-theme.x86_64-darwin
  };
})
