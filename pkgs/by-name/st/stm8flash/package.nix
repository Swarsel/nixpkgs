{
  lib,
  stdenv,
  fetchFromGitHub,
  libusb1,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "stm8flash";
  version = "2022-03-27";

  src = fetchFromGitHub {
    owner = "vdudouyt";
    repo = "stm8flash";
    rev = "23305ce5adbb509c5cb668df31b0fd6c8759639c";
    sha256 = "sha256-fFoC2EKSmYyW2lqrdAh5A2WEtUMCenKse2ySJdNHu6w=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace 'pkg-config' '$(PKG_CONFIG)'
  '';

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libusb1 ];

  makeFlags = [
    "DESTDIR=${placeholder "out"}"
  ];

  # NOTE: _FORTIFY_SOURCE requires compiling with optimization (-O)
  env.NIX_CFLAGS_COMPILE = "-O";
  enableParallelBuilding = true;

  meta = {
    description = "Tool for flashing STM8 MCUs via ST-LINK (V1 and V2)";
    homepage = "https://github.com/vdudouyt/stm8flash";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ pkharvey ];
    platforms = lib.platforms.all;
    mainProgram = "stm8flash";
  };
}
