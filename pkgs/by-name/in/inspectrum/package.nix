{
  lib,
  fetchFromGitHub,
  cmake,
  fftwFloat,
  gnuradioMinimal,
  liquid-dsp,
  pkg-config,
  qt5,
  thrift,
}:

gnuradioMinimal.pkgs.mkDerivation rec {
  pname = "inspectrum";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "miek";
    repo = "inspectrum";
    rev = "v${version}";
    sha256 = "sha256-yY2W2hQpj8TIxiQBSbQHq0J16n74OfIwMDxFt3mLZYc=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.1)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    qt5.wrapQtAppsHook
    pkg-config
  ];

  buildInputs = [
    fftwFloat
    liquid-dsp
    qt5.qtbase
  ]
  ++ lib.optionals (gnuradioMinimal.hasFeature "gr-ctrlport") [
    thrift
    gnuradioMinimal.unwrapped.python.pkgs.thrift
  ];

  meta = {
    description = "Tool for analysing captured signals from sdr receivers";
    homepage = "https://github.com/miek/inspectrum";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ mog ];
    platforms = lib.platforms.linux;
    mainProgram = "inspectrum";
  };
}
