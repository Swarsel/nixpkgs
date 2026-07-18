{
  lib,
  stdenv,
  fetchFromGitHub,
  libacars,
  libcorrect,
  libsForQt5,
  libvorbis,
  makeWrapper,
  qmqtt,
  zeromq,
}:

let
  jfft-src = fetchFromGitHub {
    hash = "sha256-GDagnbbYT6Xn8IQ7YH7giBiNqSYYkyyTqInlvT5TZZA=";
    owner = "jontio";
    repo = "JFFT";
    rev = "4b74486e58e1d266f1cc3c570f3d073d40c353d6";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "jaero";
  version = "1.0.4.14-unstable-2023-11-21";

  src = fetchFromGitHub {
    owner = "jontio";
    repo = "JAERO";
    rev = "1d4e515921244aec1d85a03f5f38b4e7818fdbe6";
    hash = "sha256-/miAV87IyeOid4srLL25Ec+3Up47Aox2TsI3E3UQanw=";
  };

  nativeBuildInputs = with libsForQt5; [
    qmake
    wrapQtAppsHook
    makeWrapper
  ];

  buildInputs = [
    qmqtt
    libacars
    libcorrect
    libvorbis
    zeromq
  ]
  ++ (with libsForQt5; [
    qtbase
    qcustomplot
    qtmultimedia
    qtsvg
  ]);

  preConfigure = ''
    substituteInPlace JAERO.pro \
      --replace-fail "QT       += multimedia core network gui svg sql qmqtt" \
                     "QT       += multimedia core network gui svg sql" \
      --replace-fail "JFFT_PATH = ../../JFFT/" "JFFT_PATH = ${jfft-src}" \
      --replace-fail "INSTALL_PATH = /opt/jaero" "INSTALL_PATH = ${placeholder "out"}" \
      --replace-fail "/usr" "${placeholder "out"}"
      cat >> JAERO.pro <<"EOF"
        LIBS += -L${qmqtt}/lib -lqmqtt
      EOF
  '';

  postInstall = ''
    mkdir -p $out/bin
    mv $out/JAERO $out/bin/JAERO
  '';

  sourceRoot = "${finalAttrs.src.name}/JAERO";

  meta = {
    description = "SatCom ACARS demodulator and decoder for the Aero standard";
    homepage = "https://github.com/jontio/JAERO";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ noderyos ];
    platforms = lib.platforms.linux;
    mainProgram = "JAERO";
  };
})
