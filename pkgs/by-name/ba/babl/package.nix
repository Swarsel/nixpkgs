{
  lib,
  stdenv,
  fetchurl,
  gi-docgen,
  gobject-introspection,
  lcms2,
  meson,
  ninja,
  pkg-config,
  vala,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "babl";
  version = "0.1.126";

  src = fetchurl {
    url = "https://download.gimp.org/pub/babl/${lib.versions.majorMinor finalAttrs.version}/babl-${finalAttrs.version}.tar.xz";
    hash = "sha256-PwkPSyph/s98jcYKWAS7x3zv2Nd4ry3tBZ8ONnpSkw4=";
  };

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];

  patches = [
    # Allow overriding path to dev output that will be hardcoded e.g. in pkg-config file.
    ./dev-prefix.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gi-docgen
    gobject-introspection
    vala
  ];

  buildInputs = [
    lcms2
  ];

  mesonFlags = [
    "-Dprefix-dev=${placeholder "dev"}"
  ]
  ++ lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
    # Docs are opt-out in native but opt-in in cross builds.
    "-Dwith-docs=true"
    "-Denable-gir=true"
  ];

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  __structuredAttrs = true;

  depsBuildBuild = [
    pkg-config
  ];

  meta = {
    description = "Image pixel format conversion library";
    homepage = "https://gegl.org/babl/";

    changelog = "https://gitlab.gnome.org/GNOME/babl/-/blob/BABL_${
      lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version
    }/NEWS";

    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ jtojnar ];
    platforms = lib.platforms.unix;
    mainProgram = "babl";
  };
})
