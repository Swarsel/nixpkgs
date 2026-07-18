{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  gnome,
  gobject-introspection,
  gtk-doc,
  gtk3,
  intltool,
  isocodes,
  itstool,
  json-glib,
  libgee,
  libxml2,
  meson,
  ninja,
  openssl,
  pkg-config,
  python3,
  sqlite,
  vala,
  yelp-tools,
  libmysqlclient ? null,
  libpq ? null,
  mysqlSupport ? false,
  postgresSupport ? false,
}:

assert mysqlSupport -> libmysqlclient != null;
assert postgresSupport -> libpq != null;

stdenv.mkDerivation (finalAttrs: {
  pname = "libgda";
  version = "6.0.0";

  src = fetchurl {
    url = "mirror://gnome/sources/libgda/${lib.versions.majorMinor finalAttrs.version}/libgda-${finalAttrs.version}.tar.xz";
    sha256 = "0w564z7krgjk19r39mi5qn4kggpdg9ggbyn9pb4aavb61r14npwr";
  };

  patches = [
    # Fix undefined behavior
    (fetchpatch {
      sha256 = "Qx4S9KQsTAr4M0QJi0Xr5kKuHSp4NwZJHoRPYyxIyTk=";
      url = "https://gitlab.gnome.org/GNOME/libgda/-/commit/657b2f8497da907559a6769c5b1d2d7b5bd40688.patch";
    })

    # Fix building vapi
    (fetchpatch {
      sha256 = "pyfymUd61m1kHaGyMbUQMma+szB8mlqGWwcFBBQawf8=";
      url = "https://gitlab.gnome.org/GNOME/libgda/-/commit/57f618a3b2a3758ee3dcbf9bbdc566122dd8566d.patch";
    })

    (fetchpatch {
      name = "CVE-2021-39359.patch";
      sha256 = "sha256-UjHP1nhb5n6TOdaMdQeE2s828T4wv/0ycG3FAk+I1QA=";
      url = "https://gitlab.gnome.org/GNOME/libgda/-/commit/bebdffb4de586fb43fd07ac549121f4b22f6812d.patch";
    })
  ];

  postPatch = ''
    patchShebangs \
      providers/raw_spec.py \
      providers/mysql/gen_bin.py
  '';

  nativeBuildInputs = [
    pkg-config
    intltool
    meson
    ninja
    itstool
    libxml2
    python3
    gobject-introspection
    vala
    gtk-doc
    yelp-tools
  ];

  buildInputs = [
    gtk3
    json-glib
    isocodes
    openssl
    libgee
    sqlite
  ]
  ++ lib.optionals mysqlSupport [
    libmysqlclient
  ]
  ++ lib.optionals postgresSupport [
    libpq
  ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-error=incompatible-function-pointer-types";

  passthru = {
    updateScript = gnome.updateScript {
      attrPath = "libgda6";
      packageName = "libgda";
      versionPolicy = "odd-unstable";
    };
  };

  meta = {
    description = "Database access library";
    homepage = "https://www.gnome-db.org/";

    license = with lib.licenses; [
      # library
      lgpl2Plus
      # CLI tools
      gpl2Plus
    ];

    platforms = lib.platforms.unix;
    teams = [ lib.teams.gnome ];
  };
})
