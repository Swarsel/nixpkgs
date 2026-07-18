{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  fetchpatch,
  gst_all_1,
  gtk2-x11,
  gtk3-x11,
  libcap,
  libpulseaudio,
  libtool,
  libvorbis,
  pkg-config,
  systemd,
  gtkSupport ? null,
  withAlsa ? stdenv.hostPlatform.isLinux,
  withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libcanberra";
  version = "0.30";

  src = fetchurl {
    url = "http://0pointer.de/lennart/projects/libcanberra/libcanberra-${finalAttrs.version}.tar.xz";
    sha256 = "0wps39h8rx2b00vyvkia5j40fkak3dpipp1kzilqla0cgvk73dn2";
  };

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    ./0001-gtk-Don-t-assume-all-GdkDisplays-are-GdkX11Displays-.patch
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    (fetchpatch {
      extraPrefix = "";
      sha256 = "sha256-pEJy1krciUEg5BFIS8FJ4BubjfS/nt9aqi6BLnS1+4M=";
      url = "https://github.com/macports/macports-ports/raw/5a7965dfea7727d1ceedee46c7b0ccee9cb23468/audio/libcanberra/files/patch-configure.diff";
    })
    (fetchpatch {
      extraPrefix = "";
      sha256 = "sha256-nUjha2pKh5VZl0ZZzcr9NTo1TVuMqF4OcLiztxW+ofQ=";
      url = "https://github.com/macports/macports-ports/raw/5a7965dfea7727d1ceedee46c7b0ccee9cb23468/audio/libcanberra/files/dynamic_lookup-11.patch";
    })
  ];

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libpulseaudio
    libvorbis
    libtool # in buildInputs rather than nativeBuildInputs since libltdl is used (not libtool itself)
  ]
  ++ (with gst_all_1; [
    gstreamer
    gst-plugins-base
  ])
  ++ lib.optional (gtkSupport == "gtk2") gtk2-x11
  ++ lib.optional (gtkSupport == "gtk3") gtk3-x11
  ++ lib.optional stdenv.hostPlatform.isLinux libcap
  ++ lib.optional withSystemd systemd
  ++ lib.optional withAlsa alsa-lib;

  configureFlags = [
    "--disable-oss"
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux "--with-systemdsystemunitdir=${placeholder "out"}/lib/systemd/system";

  postInstall = ''
    for f in $out/lib/*.la; do
      sed 's|-lltdl|-L${libtool.lib}/lib -lltdl|' -i $f
    done
  '';

  enableParallelBuilding = true;

  passthru = lib.optionalAttrs (gtkSupport != null) {
    gtkModule = if gtkSupport == "gtk2" then "/lib/gtk-2.0" else "/lib/gtk-3.0/";
  };

  meta = {
    description = "Implementation of the XDG Sound Theme and Name Specifications";

    longDescription = ''
      libcanberra is an implementation of the XDG Sound Theme and Name
      Specifications, for generating event sounds on free desktops
      such as GNOME.  It comes with several backends (ALSA,
      PulseAudio, OSS, GStreamer, null) and is designed to be
      portable.
    '';

    homepage = "http://0pointer.de/lennart/projects/libcanberra/";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ RossComputerGuy ];
    platforms = lib.platforms.unix;
    mainProgram = "canberra-gtk-play";
  };
})
