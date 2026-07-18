{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  docbook-xsl-nons,
  docbook_xml_dtd_42,
  docbook_xsl_ns,
  gettext,
  glib,
  gobject-introspection,
  gst_all_1,
  gtk-doc,
  gtk3,
  jansson,
  libxml2,
  libxslt,
  meson,
  ninja,
  nixosTests,
  pkg-config,
  polkit,
  python3,
  sqlite,
  systemd,
  vala,
  bash-completion ? null,
  enableBashCompletion ? false,
  enableCommandNotFound ? false,
  enableSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "packagekit";
  version = "1.3.5";

  src = fetchFromGitHub {
    owner = "PackageKit";
    repo = "PackageKit";
    rev = "v${finalAttrs.version}";
    hash = "sha256-aKucwqwNyZWyHfNu9ntzSwD+eQy8KjCt6RVMjjjZmZg=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  postPatch = ''
    # HACK: we want packagekit to look in /etc for configs but install
    # those files in $out/etc ; we just override the runtime paths here
    # same for /var & $out/var
    substituteInPlace etc/meson.build \
      --replace-fail "install_dir: join_paths(get_option('sysconfdir'), 'PackageKit')" "install_dir: join_paths('$out', 'etc', 'PackageKit')"
    substituteInPlace data/meson.build \
      --replace-fail "install_dir: join_paths(get_option('localstatedir'), 'lib', 'PackageKit')," "install_dir: join_paths('$out', 'var', 'lib', 'PackageKit'),"
    substituteInPlace client/meson.build \
      --replace-fail http://docbook.sourceforge.net/release/xsl-ns/current ${docbook_xsl_ns}/share/xml/docbook-xsl-ns

  '';

  nativeBuildInputs = [
    gobject-introspection
    glib
    vala
    gettext
    pkg-config
    gtk-doc
    meson
    libxslt
    docbook-xsl-nons
    docbook_xml_dtd_42
    libxml2
    ninja
  ];

  buildInputs = [
    glib
    polkit
    python3
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gtk3
    jansson
    sqlite
    boost
  ]
  ++ lib.optional enableSystemd systemd
  ++ lib.optional enableBashCompletion bash-completion;

  mesonFlags = [
    (if enableSystemd then "-Dsystemd=true" else "-Dsystem=false")
    # often fails to build with nix updates
    # and remounts /nix/store as rw
    # https://github.com/NixOS/nixpkgs/issues/177946
    #"-Dpackaging_backend=nix"
    "-Ddbus_sys=${placeholder "out"}/share/dbus-1/system.d"
    "-Ddbus_services=${placeholder "out"}/share/dbus-1/system-services"
    "-Dsystemdsystemunitdir=${placeholder "out"}/lib/systemd/system"
    "-Dcron=false"
    "-Dgtk_doc=true"
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ]
  ++ lib.optional (!enableBashCompletion) "-Dbash_completion=false"
  ++ lib.optional (!enableCommandNotFound) "-Dbash_command_not_found=false";

  passthru.tests = {
    nixos-test = nixosTests.packagekit;
  };

  meta = {
    description = "System to facilitate installing and updating packages";

    longDescription = ''
      PackageKit is a system designed to make installing and updating software
      on your computer easier. The primary design goal is to unify all the
      software graphical tools used in different distributions, and use some of
      the latest technology like PolicyKit. The actual nuts-and-bolts distro
      tool (dnf, apt, etc) is used by PackageKit using compiled and scripted
      helpers. PackageKit isn't meant to replace these tools, instead providing
      a common set of abstractions that can be used by standard GUI and text
      mode package managers.
    '';

    homepage = "https://github.com/PackageKit/PackageKit";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
