{
  lib,
  stdenv,
  fetchurl,
  docbook_xml_dtd_412,
  docbook_xsl,
  glib,
  gnutls,
  gobject-introspection,
  gsasl,
  gss,
  gtk-doc,
  libdaemon,
  libidn,
  libintl,
  libxml2,
  pkg-config,
  avahi ? null,
  avahiSupport ? false, # build support for Avahi in libinfinity
  gtk3 ? null,
  gtkWidgets ? false, # build GTK widgets for libinfinity
}:

assert avahiSupport -> avahi != null;
assert gtkWidgets -> gtk3 != null;

let
  self = stdenv.mkDerivation rec {
    pname = "libinfinity";
    version = "0.7.2";

    src = fetchurl {
      url = "https://github.com/gobby/libinfinity/releases/download/${version}/libinfinity-${version}.tar.gz";
      sha256 = "17i3g61hxz9pzl3ryd1yr15142r25m06jfzjrpdy7ic1b8vjjw3f";
    };

    outputs = [
      "bin"
      "out"
      "dev"
      "man"
      "devdoc"
    ];

    nativeBuildInputs = [
      pkg-config
      gtk-doc
      docbook_xsl
      docbook_xml_dtd_412
      gobject-introspection
    ];

    buildInputs = [
      glib
      libxml2
      gsasl
      libidn
      gss
      libintl
      libdaemon
    ]
    ++ lib.optional gtkWidgets gtk3
    ++ lib.optional avahiSupport avahi;

    propagatedBuildInputs = [ gnutls ];

    configureFlags = [
      (lib.enableFeature true "gtk-doc")
      (lib.enableFeature true "introspection")
      (lib.withFeature gtkWidgets "inftextgtk")
      (lib.withFeature gtkWidgets "infgtk")
      (lib.withFeature true "infinoted")
      (lib.withFeature true "libdaemon")
      (lib.withFeature avahiSupport "avahi")
    ];

    passthru = {
      infinoted = "${self.bin}/bin/infinoted-${lib.versions.majorMinor version}";
    };

    meta = {
      description = "Implementation of the Infinote protocol written in GObject-based C";
      homepage = "https://gobby.github.io/";
      license = lib.licenses.lgpl2Plus;
      maintainers = [ ];
      platforms = with lib.platforms; linux ++ darwin;
      mainProgram = "infinoted-0.7";
      # The last successful Darwin Hydra build was in 2024
      broken = stdenv.hostPlatform.isDarwin;
    };
  };
in
self
