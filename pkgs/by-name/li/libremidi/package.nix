{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libremidi";
  version = "4.5.0";

  src = fetchFromGitHub {
    owner = "celtera";
    repo = "libremidi";
    rev = "v${finalAttrs.version}";
    hash = "sha256-JwXOIBq+pmPIR4y/Zv5whEyCfpLHmbllzdH2WLZmWLw=";
  };

  # Bug: set this as true breaks obs-studio-plugins.advanced-scene-switcher
  strictDeps = false;

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
  ];

  # PipeWire support currently disabled. Enabling it requires packaging:
  # https://github.com/cameron314/readerwriterqueue
  cmakeFlags = [ "-DLIBREMIDI_NO_PIPEWIRE=ON" ];

  postInstall = ''
    cp -r $src/include $out
  '';

  meta = {
    description = "Modern C++ MIDI real-time & file I/O library";
    homepage = "https://github.com/celtera/libremidi";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
