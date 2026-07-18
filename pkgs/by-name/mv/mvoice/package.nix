{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  copyDesktopItems,
  curl,
  fltk-minimal,
  fmt,
  gettext,
  gnutls,
  makeDesktopItem,
  msgpack-cxx,
  nlohmann_json,
  opendht,
}:
stdenv.mkDerivation {
  pname = "mvoice";
  version = "0-unstable-2025-09-19";

  src = fetchFromGitHub {
    owner = "n7tae";
    repo = "mvoice";
    rev = "aef3662ee6ef86ecb10a71dd686ca41a067162c0";
    hash = "sha256-FosfD1949shlPXq594gdqodlXM3cGKpFi68tc+/YQ4g=";
  };

  postPatch = ''
    # fix hardcoded paths in Makefile
    substituteInPlace Makefile \
      --replace-fail "g++" "\$(CXX)" \
      --replace-fail "/bin/cp" "cp"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    copyDesktopItems
    fltk-minimal
    gettext
  ];

  buildInputs = [
    alsa-lib
    curl
    fltk-minimal
    fmt
    gnutls
    msgpack-cxx
    nlohmann_json
    opendht
  ];

  makeFlags = [
    "BASEDIR=$(out)"
    "CFGDIR=.config/mvoice"
    "DEBUG=false"
    "USE44100=false"
    "USE_DHT=true"
  ];

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Network"
        "X-Ham Radio"
      ];

      comment = "MVoice by N7TAE - M17 figital voice gateway";
      desktopName = "MVoice";
      exec = "mvoice";
      name = "mvoice";
    })
  ];

  meta = {
    description = "M17 digital voice gateway and module for voice and data modes";
    homepage = "https://github.com/n7tae/mvoice";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.juliabru ];
    platforms = lib.platforms.linux;
  };
}
