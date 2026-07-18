{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "openfx";
  version = "1.4";

  src = fetchFromGitHub {
    owner = "AcademySoftwareFoundation";
    repo = "openfx";
    rev = "OFX_Release_1_4_TAG";
    sha256 = "0k9ggzr6bisn77mipjfvawg3mv4bz50b63v8f7w1jhldi1sfy548";
  };

  outputs = [
    "dev"
    "out"
  ];

  buildPhase = ''
    mkdir $dev
    mkdir $out
  '';

  installPhase = ''
    mkdir -p $dev/include/OpenFX/
    cp -r include/* $dev/include/OpenFX/
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Image processing plug-in standard";
    homepage = "https://openeffects.org/";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.guibou ];
    platforms = lib.platforms.all;
  };
}
