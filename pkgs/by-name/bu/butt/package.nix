{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  curl,
  dbus,
  fdk_aac,
  flac,
  fltk_1_3,
  lame,
  libogg,
  libopus,
  libsamplerate,
  libvorbis,
  openssl,
  pkg-config,
  portaudio,
  portmidi,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "butt";
  version = "1.46.0";

  src = fetchurl {
    url = "https://danielnoethen.de/butt/release/${finalAttrs.version}/butt-${finalAttrs.version}.tar.gz";
    hash = "sha256-3RIC2H5HMn/e5Bl4XCPxxpv+FET9RgV7MxtcOuscXzs=";
  };

  postPatch = ''
    # remove advertising
    substituteInPlace src/FLTK/flgui.cpp \
      --replace-fail 'idata_radio_co_badge, 124, 61, 4,' 'nullptr, 0, 0, 0,'
    substituteInPlace src/FLTK/fl_timer_funcs.cpp \
      --replace-fail 'radio_co_logo, 124, 61, 4,' 'nullptr, 0, 0, 0,' \
      --replace-fail 'live365_logo, 124, 61, 4,' 'nullptr, 0, 0, 0,'
  '';

  nativeBuildInputs = [
    autoPatchelfHook
    pkg-config
  ];

  buildInputs = [
    fltk_1_3
    portaudio
    lame
    libvorbis
    libogg
    flac
    libopus
    libsamplerate
    fdk_aac
    dbus
    openssl
    curl
    portmidi
  ];

  postInstall = ''
    cp -r usr/share $out/
  '';

  runtimeDependencies = [
    fdk_aac
  ];

  meta = {
    description = "Easy to use, multi OS streaming tool";
    homepage = "https://danielnoethen.de/butt/";
    changelog = "https://danielnoethen.de/butt/Changelog.html";
    license = lib.licenses.gpl2;
    platforms = lib.platforms.linux;
    mainProgram = "butt";
  };
})
