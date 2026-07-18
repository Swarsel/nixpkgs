{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  cmake,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "portmidi";
  version = "2.0.8";

  src = fetchFromGitHub {
    owner = "portmidi";
    repo = "portmidi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-j5m/ablSzsENVzE1ghvnu+uE4nB0V91SA/mrCx5gCNk=";
  };

  nativeBuildInputs = [
    unzip
    cmake
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
  ];

  cmakeFlags = [
    "-DCMAKE_ARCHIVE_OUTPUT_DIRECTORY=Release"
    "-DCMAKE_LIBRARY_OUTPUT_DIRECTORY=Release"
    "-DCMAKE_RUNTIME_OUTPUT_DIRECTORY=Release"
  ];

  postInstall =
    let
      ext = stdenv.hostPlatform.extensions.sharedLibrary;
    in
    ''
      ln -s libportmidi${ext} "$out/lib/libporttime${ext}"
    '';

  hardeningDisable = [ "format" ];

  meta = {
    description = "Platform independent library for MIDI I/O";
    homepage = "https://github.com/PortMidi/portmidi";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ emilytrau ];
    platforms = lib.platforms.unix;
  };
})
