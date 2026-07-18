{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  cyrus_sasl,
  gdk-pixbuf,
  glib,
  gst_all_1,
  libcacard,
  libjpeg,
  libopus,
  libxext,
  libxfixes,
  libxinerama,
  libxrandr,
  libxrender,
  lz4,
  meson,
  ninja,
  openssl,
  orc,
  pixman,
  pkg-config,
  python3,
  spice-protocol,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "spice";
  version = "0.16.0";

  src = fetchurl {
    url = "https://www.spice-space.org/download/releases/spice-server/spice-${finalAttrs.version}.tar.bz2";
    sha256 = "sha256-Cm7JUo8FNxJhu7LUb/Nee1xF/4m7l1qZr5Wl8g/0cX0=";
  };

  patches = [
    ./remove-rt-on-darwin.patch
  ];

  postPatch = ''
    patchShebangs build-aux
  '';

  nativeBuildInputs = [
    glib
    meson
    ninja
    pkg-config
    python3
    python3.pkgs.pyparsing
  ];

  buildInputs = [
    cyrus_sasl
    glib
    gst_all_1.gst-plugins-base
    libxext
    libxfixes
    libxinerama
    libxrandr
    libxrender
    libcacard
    libjpeg
    libopus
    lz4
    openssl
    orc
    pixman
    python3.pkgs.pyparsing
    spice-protocol
    zlib
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    gdk-pixbuf
  ];

  mesonFlags = [
    "-Dgstreamer=1.0"
  ];

  env.NIX_CFLAGS_COMPILE = "-fno-stack-protector";

  postInstall = ''
    ln -s spice-server $out/include/spice
  '';

  meta = {
    description = "Complete open source solution for interaction with virtualized desktop devices";

    longDescription = ''
      The Spice project aims to provide a complete open source solution for interaction
      with virtualized desktop devices.The Spice project deals with both the virtualized
      devices and the front-end. Interaction between front-end and back-end is done using
      VD-Interfaces. The VD-Interfaces (VDI) enable both ends of the solution to be easily
      utilized by a third-party component.
    '';

    homepage = "https://www.spice-space.org/";
    license = lib.licenses.lgpl21;

    maintainers = with lib.maintainers; [
      atemu
    ];

    platforms = with lib.platforms; linux ++ darwin;
  };
})
