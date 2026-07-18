{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  cmake,
  curl,
  fetchpatch,
  file,
  freetype,
  glew,
  imagemagick,
  libGL,
  libogg,
  libxext,
  openal,
  opusfile,
  unzip,
  zip,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "openspades";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "yvt";
    repo = "openspades";
    rev = "v${version}";
    sha256 = "1fvmqbif9fbipd0vphp57pk6blb4yp8xvqlc2ppipk5pjv6a3d2h";
  };

  patches = [
    # https://github.com/yvt/openspades/pull/793 fix Darwin build
    (fetchpatch {
      sha256 = "1i7rcpjzkjhbv5pp6byzrxv7sb1iamqq5k1vyqlvkbr38k2dz0rv";
      url = "https://github.com/yvt/openspades/commit/2d13704fefc475b279337e89057b117f711a35d4.diff";
    })
  ];

  postPatch = ''
    sed -i 's,^wget .*,cp $devPak "$PAK_NAME",' Resources/downloadpak.sh
    patchShebangs Resources

    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.8)" "cmake_minimum_required(VERSION 3.10)" \
      --replace-fail "cmake_policy(SET CMP0054 OLD)" ""
    substituteInPlace Sources/AngelScript/projects/{cmake,cmake_addons}/CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.6)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    imagemagick
    unzip
    zip
    file
  ];

  buildInputs = [
    freetype
    SDL2
    SDL2_image
    libGL
    zlib
    curl
    glew
    opusfile
    openal
    libogg
    libxext
  ];

  cmakeFlags = [
    "-DOPENSPADES_INSTALL_BINARY=bin"
  ];

  env.NIX_CFLAGS_LINK = "-lopenal";

  postInstall = ''
    cp $notoFont $out/share/games/openspades/Resources/
  '';

  devPak = fetchurl {
    sha256 = "1bd2fyn7mlxa3xnsvzj08xjzw02baimqvmnix07blfhb78rdq9q9";
    url = "https://github.com/yvt/openspades-paks/releases/download/r${devPakVersion}/OpenSpadesDevPackage-r${devPakVersion}.zip";
  };

  devPakVersion = "33";

  notoFont = fetchurl {
    sha256 = "0kaz8j85wjjnf18z0lz69xr1z8makg30jn2dzdyicd1asrj0q1jm";
    url = "https://github.com/yvt/openspades/releases/download/v0.1.1b/NotoFonts.pak";
  };

  meta = {
    description = "Compatible client of Ace of Spades 0.75";
    homepage = "https://github.com/yvt/openspades/";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "openspades";

    # never built on aarch64-linux since first introduction in nixpkgs
    broken =
      stdenv.hostPlatform.isDarwin || (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64);
  };
}
