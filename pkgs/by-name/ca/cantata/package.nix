{
  lib,
  stdenv,
  fetchFromGitHub,
  cdparanoia,
  cmake,
  ffmpeg_6,
  gst_all_1,
  kdePackages,
  lame,
  libcddb,
  libmtp,
  libmusicbrainz,
  libvlc,
  mpg123,
  perl,
  pkg-config,
  qt6,
  speex,
  taglib_1,
  taglib_extras,
  udisks,
  # Cantata doesn't build with cdparanoia enabled so we disable that
  # default for now until I (or someone else) figure it out.
  withCdda ? false,
  withCddb ? false,
  withDevices ? true,
  withDynamic ? true,
  withHttpServer ? true,
  withHttpStream ? true,
  withLame ? false,
  withLibVlc ? true,
  withMtp ? true,
  withMusicbrainz ? false,
  withOnlineServices ? true,
  withReplaygain ? true,
  withStreams ? true,
  withTaglib ? true,
}:

# Inter-dependencies.
assert withCddb -> withCdda && withTaglib;
assert withCdda -> withCddb && withMusicbrainz;
assert withLame -> withCdda && withTaglib;
assert withMtp -> withTaglib;
assert withMusicbrainz -> withCdda && withTaglib;
assert withOnlineServices -> withTaglib;
assert withReplaygain -> withTaglib;
assert withLibVlc -> withHttpStream;

let
  fstat = x: fn: "-DENABLE_${fn}=${if x then "ON" else "OFF"}";

  withUdisks = (withTaglib && withDevices && stdenv.hostPlatform.isLinux);

  gst = with gst_all_1; [
    gstreamer
    gst-libav
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
  ];

  options = [
    {
      enable = withCddb;
      names = [ "CDDB" ];
      pkgs = [ libcddb ];
    }
    {
      enable = withCdda;
      names = [ "CDPARANOIA" ];
      pkgs = [ cdparanoia ];
    }
    {
      enable = withDevices;
      names = [ "DEVICES_SUPPORT" ];
      pkgs = [ ];
    }
    {
      enable = withDynamic;
      names = [ "DYNAMIC" ];
      pkgs = [ ];
    }
    {
      enable = withReplaygain;

      names = [
        "FFMPEG"
        "MPG123"
        "SPEEXDSP"
      ];

      pkgs = [
        ffmpeg_6
        speex
        mpg123
      ];
    }
    {
      enable = true;
      names = [ "HTTPS_SUPPORT" ];
      pkgs = [ ];
    }
    {
      enable = withHttpServer;
      names = [ "HTTP_SERVER" ];
      pkgs = [ ];
    }
    {
      enable = withHttpStream;
      names = [ "HTTP_STREAM_PLAYBACK" ];
      pkgs = [ qt6.qtmultimedia ];
    }
    {
      enable = withLame;
      names = [ "LAME" ];
      pkgs = [ lame ];
    }
    {
      enable = withLibVlc;
      names = [ "LIBVLC" ];
      pkgs = [ libvlc ];
    }
    {
      enable = withMtp;
      names = [ "MTP" ];
      pkgs = [ libmtp ];
    }
    {
      enable = withMusicbrainz;
      names = [ "MUSICBRAINZ" ];
      pkgs = [ libmusicbrainz ];
    }
    {
      enable = withOnlineServices;
      names = [ "ONLINE_SERVICES" ];
      pkgs = [ ];
    }
    {
      enable = withStreams;
      names = [ "STREAMS" ];
      pkgs = [ ];
    }
    {
      enable = withTaglib;

      names = [
        "TAGLIB"
        "TAGLIB_EXTRAS"
      ];

      pkgs = [
        taglib_1
        taglib_extras
      ];
    }
    {
      enable = withUdisks;
      names = [ "UDISKS2" ];
      pkgs = [ udisks ];
    }
  ];

in
stdenv.mkDerivation (finalAttrs: {
  pname = "cantata";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "nullobsi";
    repo = "cantata";
    rev = "v${finalAttrs.version}";
    hash = "sha256-jwIsuNgsd1TFb1Zkyen/AulGQfVY2RWKfAJaWvg4WMI=";
  };

  patches = [
    # Cantata wants to check if perl is in the PATH at runtime, but we
    # patchShebangs the playlists scripts, making that unnecessary (perl will
    # always be available because it's a dependency)
    ./dont-check-for-perl-in-PATH.diff
  ];

  postPatch = ''
    patchShebangs playlists
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.qttools
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtsvg
    qt6.qtwayland
    kdePackages.karchive
    kdePackages.kitemviews
    (perl.withPackages (ppkgs: with ppkgs; [ URI ]))
  ]
  ++ lib.flatten (builtins.catAttrs "pkgs" (builtins.filter (e: e.enable) options));

  cmakeFlags = lib.flatten (map (e: map (f: fstat e.enable f) e.names) options);

  qtWrapperArgs = lib.optionals (withHttpStream && !withLibVlc) [
    "--prefix GST_PLUGIN_PATH : ${lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" gst}"
  ];

  meta = {
    description = "Graphical client for MPD";
    homepage = "https://github.com/nullobsi/cantata";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ peterhoeg ];
    # Technically, Cantata should run on Darwin/Windows so if someone wants to
    # bother figuring that one out, be my guest.
    platforms = lib.platforms.unix;
    badPlatforms = lib.platforms.darwin;
    mainProgram = "cantata";
  };
})
