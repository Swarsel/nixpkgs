{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  fetchpatch,
  gdk-pixbuf,
  glib,
  gtk-doc,
  gtk-sharp-2_0,
  intltool,
  libimobiledevice,
  libxml2,
  mono,
  perlPackages,
  pkg-config,
  sg3_utils,
  sqlite,
  taglib,
  udevCheckHook,
  monoSupport ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libgpod";
  version = "0.8.3";

  src = fetchurl {
    url = "mirror://sourceforge/gtkpod/libgpod-${finalAttrs.version}.tar.bz2";
    hash = "sha256-Y4p5WdBOlfHmKrrQK9M3AuTo3++YSFrH2dUDlcN+lV0=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    (fetchpatch {
      hash = "sha256-aVkuYE1N/jdEhVhiXEVhApvOC+8csIMMpP20rAJwEVQ=";
      name = "libplist-2.3.0-compatibility.patch";
      url = "https://sourceforge.net/p/gtkpod/patches/48/attachment/libplist-2.3.0-compatibility.patch";
    })
  ];

  postPatch = ''
    # support libplist 2.2
    substituteInPlace configure.ac --replace 'libplist >= 1.0' 'libplist-2.0 >= 2.2'
  '';

  nativeBuildInputs = [
    autoreconfHook
    gtk-doc
    intltool
    pkg-config
    udevCheckHook
  ]
  ++ (with perlPackages; [
    perl
    XMLParser
  ])
  ++ lib.optional monoSupport mono;

  buildInputs = [
    libxml2
    sg3_utils
    sqlite
    taglib
  ]
  ++ lib.optional monoSupport gtk-sharp-2_0;

  propagatedBuildInputs = [
    gdk-pixbuf
    glib
    libimobiledevice
  ];

  configureFlags = [
    "--without-hal"
    "--enable-udev"
    "--with-udev-dir=${placeholder "out"}/lib/udev"
  ]
  ++ lib.optionals monoSupport [ "--with-mono" ];

  env = lib.optionalAttrs stdenv.cc.isGNU {
    NIX_CFLAGS_COMPILE = toString [
      "-Wno-error=implicit-int"
      "-Wno-error=incompatible-pointer-types"
    ];
  };

  doInstallCheck = true;
  dontStrip = monoSupport;

  preAutoreconf = ''
    gettextize --force --copy
    intltoolize --force --copy
  '';

  meta = {
    description = "Library used by gtkpod to access the contents of an ipod";
    homepage = "https://sourceforge.net/projects/gtkpod/";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "ipod-read-sysinfo-extended";
  };
})
