{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  ffmpeg,
  graphicsmagick,
  gtest,
  libarchive,
  libconfig,
  onnxruntime,
  openssl,
  pkg-config,
  pugixml,
  stb,
  taglib,
  wt,
  xxhash,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lms";
  version = "3.78.0";

  src = fetchFromGitHub {
    owner = "epoupon";
    repo = "lms";
    rev = "v${finalAttrs.version}";
    hash = "sha256-uOijIipay4ncE8hP6vJG9vOGiD/Ad6WJHEQ7P1HKi/Y=";
  };

  postPatch = ''
    substituteInPlace src/libs/core/include/core/SystemPaths.hpp --replace-fail "/etc" "$out/share/lms"
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    gtest
    boost
    wt
    taglib
    libconfig
    libarchive
    ffmpeg
    zlib
    stb
    openssl
    xxhash
    pugixml
    onnxruntime
  ];

  postInstall = ''
    substituteInPlace $out/share/lms/lms.conf --replace-fail "/usr/bin/ffmpeg" "${lib.getExe ffmpeg}"
    substituteInPlace $out/share/lms/lms.conf --replace-fail "/usr/share/Wt/resources" "${wt}/share/Wt/resources"
    substituteInPlace $out/share/lms/lms.conf --replace-fail "/usr/share/lms" "$out/share/lms"
    substituteInPlace $out/share/lms/default.service --replace-fail "/usr/bin/lms" "$out/bin/lms"
    install -Dm444 $out/share/lms/default.service -T $out/lib/systemd/system/lmsd.service
  '';

  meta = {
    description = "Lightweight Music Server - Access your self-hosted music using a web interface";
    homepage = "https://github.com/epoupon/lms";
    changelog = "https://github.com/epoupon/lms/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ mksafavi ];
    platforms = lib.platforms.linux;
    mainProgram = "lms";
  };
})
