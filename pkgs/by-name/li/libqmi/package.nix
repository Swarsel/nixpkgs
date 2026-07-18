{
  lib,
  stdenv,
  fetchFromGitLab,
  bash-completion,
  bashNonInteractive,
  buildPackages,
  docbook-xsl-nons,
  docbook_xml_dtd_43,
  gi-docgen,
  glib,
  gobject-introspection,
  help2man,
  libgudev,
  libmbim,
  libqrtr-glib,
  meson,
  mesonEmulatorHook,
  ninja,
  pkg-config,
  python3,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
  withMan ? stdenv.buildPlatform.canExecute stdenv.hostPlatform,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libqmi";
  version = "1.38.0";

  src = fetchFromGitLab {
    owner = "mobile-broadband";
    repo = "libqmi";
    rev = finalAttrs.version;
    hash = "sha256-bJbNfnKVJuhy/6EJgu5b7t6vxNTex/5heTzMzTzVREw=";
    domain = "gitlab.freedesktop.org";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    patchShebangs \
      build-aux/qmi-codegen/qmi-codegen
  '';

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    python3
  ]
  ++ lib.optionals withMan [
    help2man
  ]
  ++ lib.optionals withIntrospection [
    gi-docgen
    gobject-introspection
    docbook-xsl-nons
    docbook_xml_dtd_43
  ]
  ++ lib.optionals (withIntrospection && !stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    mesonEmulatorHook
  ];

  buildInputs = [
    bash-completion
    bashNonInteractive # otherwise $out/bin/qmi-network has impure #!/bin/sh shebang.
    libmbim
  ]
  ++ lib.optionals withIntrospection [
    libgudev
  ];

  propagatedBuildInputs = [
    glib
  ]
  ++ lib.optionals withIntrospection [
    libqrtr-glib
  ];

  mesonFlags = [
    "-Dudevdir=${placeholder "out"}/lib/udev"
    (lib.mesonBool "gtk_doc" withIntrospection)
    (lib.mesonBool "introspection" withIntrospection)
    (lib.mesonBool "man" withMan)
    (lib.mesonBool "qrtr" withIntrospection)
    (lib.mesonBool "udev" withIntrospection)
  ];

  doCheck = true;

  depsBuildBuild = [
    pkg-config
  ];

  meta = {
    description = "Modem protocol helper library";
    homepage = "https://www.freedesktop.org/wiki/Software/libqmi/";
    changelog = "https://gitlab.freedesktop.org/mobile-broadband/libqmi/-/blob/${finalAttrs.version}/NEWS";

    license = with lib.licenses; [
      # Library
      lgpl2Plus
      # Tools
      gpl2Plus
    ];

    platforms = lib.platforms.linux;
    teams = [ lib.teams.freedesktop ];
  };
})
