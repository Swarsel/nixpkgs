{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ndstool";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "devkitPro";
    repo = "ndstool";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-121xEmbt1WBR1wi4RLw9/iLHqkpyXImXKiCNnLCYnJs=";
  };

  nativeBuildInputs = [
    autoconf
    automake
  ];

  preConfigure = "./autogen.sh";

  meta = {
    description = "Tool to unpack and repack nds rom";
    homepage = "https://github.com/devkitPro/ndstool";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.marius851000 ];
    mainProgram = "ndstool";
  };
})
