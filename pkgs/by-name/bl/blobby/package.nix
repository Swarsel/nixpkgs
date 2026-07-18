{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  boost,
  cmake,
  libGL,
  libGLU,
  physfs,
  pkg-config,
  unzip,
  zip,
  zlib,
}:

stdenv.mkDerivation {
  inherit unzip;
  pname = "blobby-volley";
  version = "1.1.1-unstable-2025-07-26";

  src = fetchFromGitHub {
    owner = "danielknobe";
    repo = "blobbyvolley2";
    rev = "9bc797f0fade4766f2d98f8cf4db0a8a7b82a950";
    sha256 = "sha256-0e1YOwHX2x/snkyH1qeQowJr1YGdExstUoCBOhG1kBU=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    zip
  ];

  buildInputs = [
    SDL2
    SDL2_image
    libGLU
    libGL
    physfs
    boost
    zlib
  ];

  postInstall = ''
    cp ../data/Icon.bmp "$out/share/blobby/"
    mv "$out/bin"/blobby{,.bin}
    substituteAll "${./blobby.sh}" "$out/bin/blobby"
    chmod a+x "$out/bin/blobby"
  '';

  meta = {
    description = "Volleyball game";
    homepage = "https://blobbyvolley.de/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ raskin ];
    platforms = lib.platforms.linux;
    mainProgram = "blobby";
    downloadPage = "https://sourceforge.net/projects/blobby/files/Blobby%20Volley%202%20%28Linux%29/";
  };
}
