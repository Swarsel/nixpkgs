{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libx11,
  libxext,
  libxi,
  libxrandr,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xplugd";
  version = "1.4";

  src = fetchFromGitHub {
    owner = "troglobit";
    repo = "xplugd";
    rev = "v${finalAttrs.version}";
    sha256 = "11vjr69prrs4ir9c267zwq4g9liipzrqi0kmw1zg95dbn7r7zmql";
  };

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs = [
    libx11
    libxi
    libxrandr
    libxext
  ];

  meta = {
    description = "UNIX daemon that executes a script on X input and RandR changes";
    homepage = "https://github.com/troglobit/xplugd";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ akho ];
    platforms = lib.platforms.linux;
    mainProgram = "xplugd";
  };
})
