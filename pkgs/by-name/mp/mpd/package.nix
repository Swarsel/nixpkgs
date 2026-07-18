{
  lib,
  stdenv,
  fetchFromGitHub,
  # Outputs
  alsa-lib,
  # Codecs
  audiofile,
  avahi,
  buildPackages,
  # Archive support
  bzip2,
  # Inputs
  curl,
  dbus,
  # For documentation
  doxygen,
  expat,
  faad2,
  ffmpeg,
  flac,
  fluidsynth,
  fmt,
  game-music-emu,
  glib,
  # For tests
  gtest,
  # Misc
  icu,
  lame,
  libao,
  libcdio,
  libcdio-paranoia,
  libgcrypt,
  # Tag support
  libid3tag,
  libjack2,
  libmad,
  libmikmod,
  libmms,
  # Client support
  libmpdclient,
  libnfs,
  libopus,
  libpulseaudio,
  # Filters
  libsamplerate,
  libshout,
  libupnp,
  liburing,
  libvorbis,
  meson,
  mpg123,
  ninja,
  nixosTests,
  nlohmann_json,
  pcre2,
  pipewire,
  pkg-config,
  python3Packages, # for sphinx-build
  samba,
  soxr,
  sqlite,
  systemd,
  zip,
  zlib,
  zziplib,
  # Features list
  features ? null,
}:

let
  concatAttrVals = nameList: set: lib.concatMap (x: set.${x} or [ ]) nameList;

  featureDependencies = {
    # Output plugins
    alsa = [ alsa-lib ];
    ao = [ libao ];
    # Decoder plugins
    audiofile = [ audiofile ];
    # Archive support
    bzip2 = [ bzip2 ];

    # Input plugins
    cdio_paranoia = [
      libcdio
      libcdio-paranoia
    ];

    curl = [ curl ];
    # Misc
    dbus = [ dbus ];
    expat = [ expat ];
    faad = [ faad2 ];
    ffmpeg = [ ffmpeg ];
    flac = [ flac ];
    fluidsynth = [ fluidsynth ];
    gme = [ game-music-emu ];
    icu = [ icu ];

    # Tag support
    id3tag = [
      libid3tag
      zlib
    ];

    io_uring = [ liburing ];
    jack = [ libjack2 ];
    lame = [ lame ];
    # Client support
    libmpdclient = [ libmpdclient ];
    # Filter plugins
    libsamplerate = [ libsamplerate ];
    mad = [ libmad ];
    mikmod = [ libmikmod ];
    mms = [ libmms ];

    mpg123 = [
      libid3tag
      mpg123
    ];

    nfs = [ libnfs ];
    opus = [ libopus ];
    pcre = [ pcre2 ];
    pipewire = [ pipewire ];
    pulse = [ libpulseaudio ];

    # Commercial services
    qobuz = [
      curl
      libgcrypt
      nlohmann_json
    ];

    shout = [ libshout ];
    smbclient = [ samba ];
    soxr = [ soxr ];
    sqlite = [ sqlite ];
    syslog = [ ];
    systemd = [ systemd ];
    # Storage plugins
    udisks = [ dbus ];
    vorbis = [ libvorbis ];
    # Encoder plugins
    vorbisenc = [ libvorbis ];

    webdav = [
      curl
      expat
    ];

    zeroconf = [
      avahi
      dbus
    ];

    zzip = [ zziplib ];
  };

  nativeFeatureDependencies = {
    documentation = [
      doxygen
      python3Packages.sphinx
    ];
  };

  # Disable platform specific features if needed
  # using libmad to decode mp3 files on darwin is causing a segfault -- there
  # is probably a solution, but I'm disabling it for now
  platformMask =
    lib.optionals stdenv.hostPlatform.isDarwin [
      "mad"
      "pulse"
      "jack"
      "smbclient"
    ]
    ++ lib.optionals (!stdenv.hostPlatform.isLinux) [
      "alsa"
      "pipewire"
      "io_uring"
      "systemd"
      "syslog"
    ];

  knownFeatures =
    builtins.attrNames featureDependencies ++ builtins.attrNames nativeFeatureDependencies;
  platformFeatures = lib.subtractLists platformMask knownFeatures;

  features_ =
    if (features == null) then
      platformFeatures
    else
      let
        unknown = lib.subtractLists knownFeatures features;
      in
      if (unknown != [ ]) then
        throw "Unknown feature(s): ${lib.concatStringsSep " " unknown}"
      else
        let
          unsupported = lib.subtractLists platformFeatures features;
        in
        if (unsupported != [ ]) then
          throw "Feature(s) ${lib.concatStringsSep " " unsupported} are not supported on ${stdenv.hostPlatform.system}"
        else
          features;

in
stdenv.mkDerivation (finalAttrs: {
  pname = "mpd";
  version = "0.24.13";

  src = fetchFromGitHub {
    owner = "MusicPlayerDaemon";
    repo = "MPD";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-ZcSMd+PhO8sWGA96GtwM3ykPS//8SpqDh9lLh3unB8Q=";
  };

  outputs = [
    "out"
    "doc"
  ]
  ++ lib.optional (builtins.elem "documentation" features_) "man";

  postPatch =
    lib.optionalString
      (stdenv.hostPlatform.isDarwin && lib.versionOlder stdenv.hostPlatform.darwinSdkVersion "12.0")
      ''
        substituteInPlace src/output/plugins/OSXOutputPlugin.cxx \
          --replace-fail kAudioObjectPropertyElement{Main,Master} \
          --replace-fail kAudioHardwareServiceDeviceProperty_Virtual{Main,Master}Volume
      ''
    +
      lib.optionalString
        (stdenv.hostPlatform.isDarwin && lib.versionOlder stdenv.hostPlatform.darwinSdkVersion "13.3")
        ''
          sed -i "/subdir('time')/d" test/meson.build
        '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ]
  ++ concatAttrVals features_ nativeFeatureDependencies;

  buildInputs = [
    glib
    fmt
    # According to the configurePhase of meson, gtest is considered a
    # runtime dependency. Quoting:
    #
    #    Run-time dependency GTest found: YES 1.10.0
    gtest
    libupnp
  ]
  ++ concatAttrVals features_ featureDependencies;

  mesonFlags = [
    (lib.mesonBool "test" true)
    (lib.mesonBool "manpages" true)
    (lib.mesonBool "html_manual" true)
  ]
  ++ map (x: lib.mesonEnable x true) features_
  ++ map (x: lib.mesonEnable x false) (lib.subtractLists features_ knownFeatures)
  ++ lib.optional (builtins.elem "zeroconf" features_) (
    lib.mesonOption "zeroconf" (if stdenv.hostPlatform.isDarwin then "bonjour" else "avahi")
  )
  ++ lib.optional (builtins.elem "systemd" features_) (
    lib.mesonOption "systemd_system_unit_dir" "etc/systemd/system"
  )
  ++ lib.optional (builtins.elem "qobuz" features_) (lib.mesonEnable "nlohmann_json" true);

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    CXXFLAGS = toString [
      "-D__ASSERT_MACROS_DEFINE_VERSIONS_WITHOUT_UNDERSCORES=0"
    ];
  };

  doCheck = true;
  # Otherwise, the meson log says:
  #
  #    Program zip found: NO
  nativeCheckInputs = [ zip ];
  depsBuildBuild = [ buildPackages.stdenv.cc ];
  mesonAutoFeatures = "disabled";
  passthru.tests.nixos = nixosTests.mpd;

  meta = {
    description = "Flexible, powerful daemon for playing music";

    longDescription = ''
      Music Player Daemon (MPD) is a flexible, powerful daemon for playing
      music. Through plugins and libraries it can play a variety of sound
      files while being controlled by its network protocol.
    '';

    homepage = "https://www.musicpd.org/";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      tobim
      doronbehar
    ];

    platforms = lib.platforms.unix;
    mainProgram = "mpd";
  };
})
