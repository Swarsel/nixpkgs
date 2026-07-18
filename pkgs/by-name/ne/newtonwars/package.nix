{
  lib,
  stdenv,
  fetchFromGitHub,
  libGL,
  libGLU,
  libglut,
  makeWrapper,
}:

stdenv.mkDerivation {
  pname = "newtonwars";
  version = "0-unstable-2023-04-08";

  src = fetchFromGitHub {
    owner = "Draradech";
    repo = "NewtonWars";
    rev = "a32ea49f8f1d2bdb8983c28d24735696ac987617";
    hash = "sha256-qkvgQraYR+EXWUQkEvSOcbNFn2oRTjwj5U164tVto8M=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    libglut
    libGL
    libGLU
  ];

  buildPhase = "sh build-linux.sh";

  installPhase = ''
    mkdir -p $out/bin $out/share
    cp nw $out/bin
    cp font24.raw $out/share

    wrapProgram $out/bin/nw \
      --prefix LD_LIBRARY_PATH ":" ${libglut}/lib \
      --prefix LD_LIBRARY_PATH ":" ${libGLU}/lib \
      --prefix LD_LIBRARY_PATH ":" ${libGL}/lib
  '';

  patchPhase = ''
    sed -i "s;font24.raw;$out/share/font24.raw;g" display.c
  '';

  meta = {
    description = "Space battle game with gravity as the main theme";
    homepage = "https://github.com/Draradech/NewtonWars";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pSub ];
    platforms = lib.platforms.linux;
    mainProgram = "nw";
  };
}
