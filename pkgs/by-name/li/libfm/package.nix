{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fetchpatch,
  glib,
  gtk-doc,
  gtk2,
  gtk3,
  intltool,
  menu-cache,
  pango,
  pkg-config,
  vala,
  extraOnly ? false,
  withGtk3 ? false,
}:

let
  gtk = if withGtk3 then gtk3 else gtk2;
  inherit (lib) optional optionalString;
in
stdenv.mkDerivation (finalAttrs: {
  pname = if extraOnly then "libfm-extra" else "libfm";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "lxde";
    repo = "libfm";
    tag = finalAttrs.version;
    hash = "sha256-HOx3L5IYPD/3Ez5Sb3nshfisIt1cIZJmdfGE6+q5gWE=";
  };

  nativeBuildInputs = [
    autoreconfHook
    vala
    pkg-config
    intltool
    gtk-doc
  ];

  buildInputs = [
    glib
    gtk
    pango
  ]
  ++ optional (!extraOnly) menu-cache;

  configureFlags = [
    "--sysconfdir=/etc"
  ]
  ++ optional extraOnly "--with-extra-only"
  ++ optional withGtk3 "--with-gtk=3";

  # libfm-extra is pulled in by menu-cache and thus leads to a collision for libfm
  postInstall = optionalString (!extraOnly) ''
    rm $out/lib/libfm-extra.so $out/lib/libfm-extra.so.* $out/lib/libfm-extra.la $out/lib/pkgconfig/libfm-extra.pc
  '';

  enableParallelBuilding = true;
  installFlags = [ "sysconfdir=${placeholder "out"}/etc" ];

  meta = {
    description = "Glib-based library for file management";
    homepage = "https://blog.lxde.org/category/pcmanfm/";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    broken = stdenv.hostPlatform.isDarwin;
  };
})
