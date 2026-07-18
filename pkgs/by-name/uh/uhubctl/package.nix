{
  lib,
  stdenv,
  fetchFromGitHub,
  libusb1,
  pkg-config,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "uhubctl";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "mvp";
    repo = "uhubctl";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-mpeDePHLsa4sGe2+8X9KQ8AYn7wtybDnaZzxnf4oETQ=";
  };

  nativeBuildInputs = [
    which
    pkg-config
  ];

  buildInputs = [ libusb1 ];
  installFlags = [ "prefix=${placeholder "out"}" ];

  meta = {
    description = "Utility to control USB power per-port on smart USB hubs";
    homepage = "https://github.com/mvp/uhubctl";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      prusnak
      carlossless
    ];

    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "uhubctl";
  };
})
