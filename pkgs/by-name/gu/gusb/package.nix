{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  gi-docgen,
  glib,
  gobject-introspection,
  hwdata,
  json-glib,
  libusb1,
  meson,
  ninja,
  pkg-config,
  python3,
  replaceVars,
  umockdev,
  vala,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:

let
  pythonEnv = python3.pythonOnBuildForHost.withPackages (
    ps: with ps; [
      setuptools
    ]
  );
in
stdenv.mkDerivation rec {
  pname = "gusb";
  version = "0.4.9";

  src = fetchFromGitHub {
    owner = "hughsie";
    repo = "libgusb";
    tag = version;
    hash = "sha256-piIPNLc3deToyQaajXFvM+CKh9ni8mb0P3kb+2RoJOs=";
  };

  outputs = [
    "bin"
    "out"
    "dev"
  ]
  ++ lib.optionals withIntrospection [ "devdoc" ];

  patches = [
    (replaceVars ./fix-python-path.patch {
      python = "${pythonEnv}/bin/python3";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ]
  ++ lib.optionals withIntrospection [
    gobject-introspection
    gi-docgen
    vala
  ];

  # all required in gusb.pc
  propagatedBuildInputs = [
    glib
    libusb1
    json-glib
  ];

  mesonFlags = [
    (lib.mesonBool "docs" withIntrospection)
    (lib.mesonBool "introspection" withIntrospection)
    (lib.mesonBool "tests" doCheck)
    (lib.mesonBool "vapi" withIntrospection)
    (lib.mesonOption "usb_ids" "${hwdata}/share/hwdata/usb.ids")
  ];

  doCheck = false; # tests try to access USB

  checkInputs = [
    umockdev
  ];

  postFixup = ''
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    moveToOutput "share/doc" "$devdoc"
  '';

  depsBuildBuild = [
    pkg-config
  ];

  meta = {
    description = "GLib libusb wrapper";
    homepage = "https://github.com/hughsie/libgusb";
    license = lib.licenses.lgpl21;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "gusbcmd";
  };
}
