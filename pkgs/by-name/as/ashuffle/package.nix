{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libmpdclient,
  meson,
  ninja,
  pkg-config,
  yaml-cpp,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ashuffle";
  version = "3.14.10";

  src = fetchFromGitHub {
    owner = "joshkunz";
    repo = "ashuffle";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nvmyup9hW/kI7Wwo5+1/FEoHd4kfMvYbttI8nJkLfVE=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    meson
    ninja
  ];

  buildInputs = [
    libmpdclient
    yaml-cpp
  ];

  mesonFlags = [ "-Dunsupported_use_system_yamlcpp=true" ];

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    NIX_LDFLAGS = "-framework CoreFoundation";
  };

  dontUseCmakeConfigure = true;

  meta = {
    description = "Automatic library-wide shuffle for mpd";
    homepage = "https://github.com/joshkunz/ashuffle";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "ashuffle";
  };
})
