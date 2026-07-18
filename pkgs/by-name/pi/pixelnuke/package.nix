{
  lib,
  stdenv,
  fetchFromGitHub,
  glew,
  glfw,
  libevent,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pixelnuke";
  version = "0-unstable-2019-05-19";

  src = fetchFromGitHub {
    owner = "defnull";
    repo = "pixelflut";
    rev = "3458157a242ba1789de7ce308480f4e1cbacc916";
    sha256 = "03dp0p00chy00njl4w02ahxqiwqpjsrvwg8j4yi4dgckkc3gbh40";
  };

  buildInputs = [
    libevent
    glew
    glfw
  ];

  installPhase = ''
    install -Dm755 ./pixelnuke $out/bin/pixelnuke
  '';

  sourceRoot = "${finalAttrs.src.name}/pixelnuke";

  meta = {
    description = "Multiplayer canvas (C implementation)";
    homepage = "https://cccgoe.de/wiki/Pixelflut";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ mrVanDalo ];
    platforms = lib.platforms.linux;
    mainProgram = "pixelnuke";
  };
})
