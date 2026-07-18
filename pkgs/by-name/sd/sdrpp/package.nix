{
  lib,
  stdenv,
  fetchFromGitHub,
  airspy,
  airspyhf,
  boost,
  cmake,
  codec2,
  fftwFloat,
  glew,
  glfw,
  hackrf,
  libad9361,
  libbladeRF,
  libdlcr,
  libiio,
  libusb1,
  libx11,
  limesuite,
  pkg-config,
  portaudio,
  rtaudio,
  rtl-sdr-osmocom,
  sdrplay,
  soapysdr-with-plugins,
  uhd,
  volk,
  zstd,
  # Sources
  airspy_source ? true,
  airspyhf_source ? true,
  # Decoders
  atv_decoder ? true,
  # Sinks
  audio_sink ? true,
  audio_source ? true,
  bladerf_source ? stdenv.hostPlatform.isLinux,
  dab_decoder ? false,
  # Misc
  discord_presence ? true,
  dragonlabs_source ? true,
  falcon9_decoder ? false,
  file_source ? true,
  frequency_manager ? true,
  hackrf_source ? true,
  hermes_source ? true,
  iq_exporter ? true,
  kg_sstv_decoder ? false,
  limesdr_source ? true,
  m17_decoder ? false,
  meteor_demodulator ? true,
  network_sink ? true,
  network_source ? true,
  pager_decoder ? true,
  # needs libperseus-sdr, not yet available in nixpks
  perseus_source ? false,
  plutosdr_source ? stdenv.hostPlatform.isLinux,
  portaudio_sink ? false,
  radio ? true,
  recorder ? true,
  rfspace_source ? true,
  rigctl_client ? true,
  rigctl_server ? true,
  rtl_sdr_source ? true,
  # osmocom better w/ rtlsdr v4
  rtl_tcp_source ? true,
  scanner ? true,
  sdrplay_source ? false,
  sdrpp_server_source ? true,
  soapy_source ? true,
  spectran_http_source ? true,
  spyserver_source ? true,
  usrp_source ? false,
  vor_receiver ? false,
  weather_sat_decoder ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sdrpp";
  version = "${finalAttrs.upstreamVersion}-unstable-2026-03-24";

  src = fetchFromGitHub {
    owner = "AlexandreRouma";
    repo = "SDRPlusPlus";
    rev = "a6df4d58e5f6b3045883a70aeb8fb41fd5dbf1d9";
    hash = "sha256-VzeLGQTnRur5vB+M5TovpLhI2QYKvpZjZjthuGyjcm0=";
  };

  patches = [
    ./0001-Allow-management-of-resources-and-modules-paths.patch
  ];

  postPatch = ''
    substituteInPlace decoder_modules/m17_decoder/src/m17dsp.h \
      --replace-fail "codec2.h" "codec2/codec2.h"

    substituteInPlace core/src/version.h \
      --replace-fail "${finalAttrs.upstreamVersion}" "${finalAttrs.version}"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    glfw
    glew
    fftwFloat
    volk
    zstd
  ]
  ++ lib.optional stdenv.hostPlatform.isLinux libx11
  ++ lib.optional airspy_source airspy
  ++ lib.optional airspyhf_source airspyhf
  ++ lib.optional bladerf_source libbladeRF
  ++ lib.optional dragonlabs_source libdlcr
  ++ lib.optional hackrf_source hackrf
  ++ lib.optional limesdr_source limesuite
  ++ lib.optionals rtl_sdr_source [
    rtl-sdr-osmocom
    libusb1
  ]
  ++ lib.optional sdrplay_source sdrplay
  ++ lib.optional soapy_source soapysdr-with-plugins
  ++ lib.optionals plutosdr_source [
    libiio
    libad9361
  ]
  ++ lib.optionals usrp_source [
    uhd
    boost
  ]
  ++ lib.optional (audio_source || audio_sink) rtaudio
  ++ lib.optional portaudio_sink portaudio
  ++ lib.optional (dab_decoder || m17_decoder) codec2;

  cmakeFlags = [
    # Sources
    (lib.cmakeBool "OPT_BUILD_AIRSPYHF_SOURCE" airspyhf_source)
    (lib.cmakeBool "OPT_BUILD_AIRSPY_SOURCE" airspy_source)
    (lib.cmakeBool "OPT_BUILD_AUDIO_SOURCE" audio_source)
    (lib.cmakeBool "OPT_BUILD_BLADERF_SOURCE" bladerf_source)
    (lib.cmakeBool "OPT_BUILD_DRAGONLABS_SOURCE" dragonlabs_source)
    (lib.cmakeBool "OPT_BUILD_FILE_SOURCE" file_source)
    (lib.cmakeBool "OPT_BUILD_HACKRF_SOURCE" hackrf_source)
    (lib.cmakeBool "OPT_BUILD_HERMES_SOURCE" hermes_source)
    (lib.cmakeBool "OPT_BUILD_LIMESDR_SOURCE" limesdr_source)
    (lib.cmakeBool "OPT_BUILD_NETWORK_SOURCE" network_source)
    (lib.cmakeBool "OPT_BUILD_PERSEUS_SOURCE" perseus_source)
    (lib.cmakeBool "OPT_BUILD_PLUTOSDR_SOURCE" plutosdr_source)
    (lib.cmakeBool "OPT_BUILD_RFSPACE_SOURCE" rfspace_source)
    (lib.cmakeBool "OPT_BUILD_RTL_SDR_SOURCE" rtl_sdr_source)
    (lib.cmakeBool "OPT_BUILD_RTL_TCP_SOURCE" rtl_tcp_source)
    (lib.cmakeBool "OPT_BUILD_SDRPLAY_SOURCE" sdrplay_source)
    (lib.cmakeBool "OPT_BUILD_SDRPP_SERVER_SOURCE" sdrpp_server_source)
    (lib.cmakeBool "OPT_BUILD_SOAPY_SOURCE" soapy_source)
    (lib.cmakeBool "OPT_BUILD_SPECTRAN_HTTP_SOURCE" spectran_http_source)
    (lib.cmakeBool "OPT_BUILD_SPYSERVER_SOURCE" spyserver_source)
    (lib.cmakeBool "OPT_BUILD_USRP_SOURCE" usrp_source)

    # Sinks
    (lib.cmakeBool "OPT_BUILD_AUDIO_SINK" audio_sink)
    (lib.cmakeBool "OPT_BUILD_NETWORK_SINK" network_sink)
    (lib.cmakeBool "OPT_BUILD_NEW_PORTAUDIO_SINK" portaudio_sink)

    # Decoders
    (lib.cmakeBool "OPT_BUILD_ATV_DECODER" atv_decoder)
    (lib.cmakeBool "OPT_BUILD_DAB_DECODER" dab_decoder)
    (lib.cmakeBool "OPT_BUILD_FALCON9_DECODER" falcon9_decoder)
    (lib.cmakeBool "OPT_BUILD_KG_SSTV_DECODER" kg_sstv_decoder)
    (lib.cmakeBool "OPT_BUILD_M17_DECODER" m17_decoder)
    (lib.cmakeBool "OPT_BUILD_METEOR_DEMODULATOR" meteor_demodulator)
    (lib.cmakeBool "OPT_BUILD_PAGER_DECODER" pager_decoder)
    (lib.cmakeBool "OPT_BUILD_RADIO" radio)
    (lib.cmakeBool "OPT_BUILD_VOR_RECEIVER" vor_receiver)
    (lib.cmakeBool "OPT_BUILD_WEATHER_SAT_DECODER" weather_sat_decoder)

    # Misc
    (lib.cmakeBool "OPT_BUILD_DISCORD_PRESENCE" discord_presence)
    (lib.cmakeBool "OPT_BUILD_FREQUENCY_MANAGER" frequency_manager)
    (lib.cmakeBool "OPT_BUILD_IQ_EXPORTER" iq_exporter)
    (lib.cmakeBool "OPT_BUILD_RECORDER" recorder)
    (lib.cmakeBool "OPT_BUILD_RIGCTL_CLIENT" rigctl_client)
    (lib.cmakeBool "OPT_BUILD_RIGCTL_SERVER" rigctl_server)
    (lib.cmakeBool "OPT_BUILD_SCANNER" scanner)
  ];

  env.NIX_CFLAGS_COMPILE = "-fpermissive";
  hardeningDisable = lib.optional stdenv.cc.isClang "format";
  upstreamVersion = "1.3.0";

  meta = {
    description = "Cross-Platform SDR Software";
    homepage = "https://github.com/AlexandreRouma/SDRPlusPlus";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      sikmir
      zaninime
    ];

    mainProgram = "sdrpp";
    # The DAB decoder is broken upstream. See: https://github.com/AlexandreRouma/SDRPlusPlus/issues/1511
    broken = dab_decoder;
  };
})
