{
  lib,
  stdenv,
  alsa-lib,
  gst_all_1,
  libpulseaudio,
  # TODO: Clean up on `staging`.
  llvmPackages,
  pkg-config,
  qtModule,
  qtbase,
  qtdeclarative,
  wayland,
}:

qtModule {
  pname = "qtmultimedia";

  outputs = [
    "bin"
    "dev"
    "out"
  ];

  nativeBuildInputs = [
    pkg-config
  ]
  # TODO: Clean up on `staging`.
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    llvmPackages.lld
  ];

  buildInputs =
    with gst_all_1;
    [
      gstreamer
      gst-plugins-base
    ]
    # https://github.com/NixOS/nixpkgs/pull/169336 regarding libpulseaudio
    ++ lib.optionals stdenv.hostPlatform.isLinux [
      libpulseaudio
      alsa-lib
      wayland
    ];

  propagatedBuildInputs = [
    qtbase
    qtdeclarative
  ];

  env = lib.optionalAttrs (stdenv.hostPlatform.isDarwin) {
    # TODO: Clean up on `staging`.
    NIX_CFLAGS_LINK = "-fuse-ld=lld";
    NIX_LDFLAGS = "-lobjc";
  };

  qmakeFlags = [ "GST_VERSION=1.0" ];
}
