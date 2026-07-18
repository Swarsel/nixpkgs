{
  lib,
  fetchFromGitHub,
  cmake,
  mkDerivation,
  qmake,
  qtbase,
  zip,
}:

mkDerivation rec {
  pname = "uefitool";
  version = "0.28.0";

  src = fetchFromGitHub {
    owner = "LongSoft";
    repo = "uefitool";
    tag = version;
    hash = "sha256-StqrOMsKst2X2yQQ/Xl7iLAuA4QXEOyj2KtE7ZtoUNg=";
  };

  nativeBuildInputs = [
    qmake
    cmake
    zip
  ];

  buildInputs = [ qtbase ];

  buildPhase = ''
    bash unixbuild.sh
  '';

  installPhase = ''
    mkdir -p "$out"/bin
    cp UEFITool UEFIReplace/UEFIReplace UEFIPatch/UEFIPatch "$out"/bin
  '';

  dontConfigure = true;

  meta = {
    description = "UEFI firmware image viewer and editor";
    homepage = "https://github.com/LongSoft/uefitool";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ athre0z ];
    # uefitool supposedly works on other platforms, but their build script only works on linux in nixpkgs
    platforms = lib.platforms.linux;
    mainProgram = "UEFITool";
  };
}
