{
  lib,
  stdenv,
  fetchurl,
  dbus-glib,
  fetchpatch,
  glib,
  glibcLocales,
  gobject-introspection,
  libxslt,
  pkg-config,
  python3,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "telepathy-glib";
  version = "0.24.2";

  src = fetchurl {
    url = "${finalAttrs.meta.homepage}/releases/telepathy-glib/telepathy-glib-${finalAttrs.version}.tar.gz";
    sha256 = "sKN013HN0IESXzjDq9B5ZXZCMBxxpUPVVeK/IZGSc/A=";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    # Upstream unreleased patch for gcc14 error
    (fetchpatch {
      hash = "sha256-NXQel0eS7zK6FRbJcPsPXCQxos0xT8EN102vX94M5Vo=";
      name = "fix-incompatible-pointer-types.patch";
      url = "https://github.com/TelepathyIM/telepathy-glib/commit/72412c944b771f3214ddc40fa9dea82cea3a5651.patch";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    libxslt
    gobject-introspection
    vala
    python3
  ];

  buildInputs = [
    glibcLocales
  ];

  propagatedBuildInputs = [
    dbus-glib
    glib
  ];

  configureFlags = [
    "--enable-vala-bindings"
  ];

  env.LC_ALL = "en_US.UTF-8";

  preConfigure = ''
    substituteInPlace telepathy-glib/telepathy-glib.pc.in --replace Requires.private Requires
  '';

  enableParallelBuilding = true;

  meta = {
    homepage = "https://telepathy.freedesktop.org";

    license = with lib.licenses; [
      bsd2
      bsd3
      lgpl21Plus
    ];

    platforms = lib.platforms.unix;
  };
})
