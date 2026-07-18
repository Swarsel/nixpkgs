{
  lib,
  stdenv,
  fetchFromGitHub,
  libx11,
  libxext,
  libxi,
  libxinerama,
  libxkbcommon,
  libxtst,
  perl,
  pkg-config,
  xorgproto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xdotool";
  version = "4.20260303.1";

  src = fetchFromGitHub {
    owner = "jordansissel";
    repo = "xdotool";
    rev = "v${finalAttrs.version}";
    hash = "sha256-cgCZuvcxD1qQPpzSmYQZJj9TH8Vq9xTZLU8Rg7sUrvI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    perl
  ];

  buildInputs = [
    libx11
    libxtst
    xorgproto
    libxi
    libxinerama
    libxkbcommon
    libxext
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  preBuild = ''
    mkdir -p $out/lib
  '';

  meta = {
    description = "Fake keyboard/mouse input, window management, and more";
    homepage = "https://www.semicomplete.com/projects/xdotool/";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      nick-linux
    ];

    platforms = with lib.platforms; linux;
    mainProgram = "xdotool";
  };
})
