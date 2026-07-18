{
  lib,
  stdenv,
  fetchurl,
  dbus-glib,
  file,
  glib,
  gobject-introspection,
  gtk2,
  gtk3,
  intltool,
  json-glib,
  pkg-config,
  testers,
  vala,
  gtkVersion ? null,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libdbusmenu-${if gtkVersion == null then "glib" else "gtk${gtkVersion}"}";
  version = "16.04.0";

  src =
    let
      inherit (finalAttrs) version;
    in
    fetchurl {
      url = "https://launchpad.net/dbusmenu/${lib.versions.majorMinor version}/${version}/+download/libdbusmenu-${version}.tar.gz";
      sha256 = "12l7z8dhl917iy9h02sxmpclnhkdjryn08r8i4sr8l3lrlm4mk5r";
    };

  patches = [
    ./requires-glib.patch
  ];

  postPatch = ''
    for f in {configure,ltmain.sh,m4/libtool.m4}; do
      substituteInPlace $f \
        --replace /usr/bin/file ${file}/bin/file
    done
  '';

  nativeBuildInputs = [
    vala
    pkg-config
    intltool
    gobject-introspection
  ];

  buildInputs = [
    glib
    dbus-glib
    json-glib
  ]
  ++
    lib.optional (gtkVersion != null)
      {
        "2" = gtk2;
        "3" = gtk3;
      }
      .${gtkVersion} or (throw "unknown GTK version ${gtkVersion}");

  configureFlags = [
    "CFLAGS=-Wno-error"
    "--sysconfdir=/etc"
    "--localstatedir=/var"
    # TODO use `lib.withFeatureAs`
    (if gtkVersion == null then "--disable-gtk" else "--with-gtk=${gtkVersion}")
    "--disable-scrollkeeper"
  ]
  ++ lib.optional (gtkVersion != "2") "--disable-dumper";

  # https://projects.archlinux.org/svntogit/community.git/tree/trunk/PKGBUILD?h=packages/libdbusmenu
  preConfigure = ''
    export HAVE_VALGRIND_TRUE="#"
    export HAVE_VALGRIND_FALSE=""
  '';

  doCheck = false; # generates shebangs in check phase, too lazy to fix

  installFlags = [
    "sysconfdir=${placeholder "out"}/etc"
    "localstatedir=\${TMPDIR}"
    "typelibdir=${placeholder "out"}/lib/girepository-1.0"
  ];

  passthru.tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

  meta = {
    description = "Library for passing menu structures across DBus";
    homepage = "https://launchpad.net/dbusmenu";

    license = with lib.licenses; [
      gpl3
      lgpl21
      lgpl3
    ];

    maintainers = [ lib.maintainers.msteen ];
    platforms = lib.platforms.unix;

    pkgConfigModules = [
      "dbusmenu-glib-0.4"
      "dbusmenu-jsonloader-0.4"
    ]
    ++ lib.optional (gtkVersion == "3") "dbusmenu-gtk${gtkVersion}-0.4";
  };
})
