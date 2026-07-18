{
  lib,
  stdenv,
  fetchurl,
  brotli,
  buildPackages,
  gi-docgen,
  glib,
  gnome,
  gobject-introspection,
  libnghttp2,
  libpsl,
  libsysprof-capture,
  meson,
  ninja,
  pkg-config,
  python3,
  sqlite,
  vala,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:

stdenv.mkDerivation rec {
  pname = "libsoup";
  version = "3.6.6";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    hash = "sha256-Ue0K4G+dWkD0Af9Fni5fZS+aUQt3MOE1nuZtFNSHJ0A=";
  };

  outputs = [
    "out"
    "dev"
  ]
  ++ lib.optional withIntrospection "devdoc";

  postPatch = ''
    patchShebangs libsoup/
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    glib
    python3
  ]
  ++ lib.optionals withIntrospection [
    gi-docgen
    gobject-introspection
    vala
  ];

  buildInputs = [
    sqlite
    libpsl
    glib.out
    brotli
    libnghttp2
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libsysprof-capture
  ];

  propagatedBuildInputs = [
    glib
  ];

  mesonFlags = [
    "-Dtls_check=false" # glib-networking is a runtime dependency, not a compile-time dependency
    "-Dgssapi=disabled"
    "-Dntlm=disabled"
    # Requires wstest from autobahn-testsuite.
    "-Dautobahn=disabled"
    # Requires gnutls, not added for closure size.
    "-Dpkcs11_tests=disabled"

    (lib.mesonEnable "docs" withIntrospection)
    (lib.mesonEnable "introspection" withIntrospection)
    (lib.mesonEnable "sysprof" stdenv.hostPlatform.isLinux)
    (lib.mesonEnable "vapi" withIntrospection)
  ];

  # TODO: For some reason the pkg-config setup hook does not pick this up.
  env.PKG_CONFIG_PATH = "${libnghttp2.dev}/lib/pkgconfig";
  # HSTS tests fail.
  doCheck = false;

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  depsBuildBuild = [
    pkg-config
  ];

  separateDebugInfo = true;

  passthru = {
    updateScript = gnome.updateScript {
      attrPath = "libsoup_3";
      packageName = "libsoup";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    inherit (glib.meta) maintainers platforms teams;
    description = "HTTP client/server library for GNOME";
    homepage = "https://gitlab.gnome.org/GNOME/libsoup";
    changelog = "https://gitlab.gnome.org/GNOME/libsoup/-/blob/${version}/NEWS";
    license = lib.licenses.lgpl2Plus;
  };
}
