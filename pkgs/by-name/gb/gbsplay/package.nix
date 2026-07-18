{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  libpulseaudio,
  nas,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gbsplay";
  version = "0.0.102";

  src = fetchFromGitHub {
    owner = "mmitch";
    repo = "gbsplay";
    tag = finalAttrs.version;
    hash = "sha256-kjIjJVenemlUGptEFQhm3wxhbjlYdqKGDWhGdTtGUI4=";
  };

  nativeBuildInputs = [ installShellFiles ];

  buildInputs = [
    libpulseaudio
    nas
  ];

  configureFlags = [
    "--without-test" # See mmitch/gbsplay#62
    "--without-contrib"
  ];

  postInstall = ''
    installShellCompletion --bash --name gbsplay contrib/gbsplay.bashcompletion
  '';

  meta = {
    description = "Gameboy sound player";
    homepage = "https://github.com/mmitch/gbsplay";
    license = lib.licenses.gpl1Plus;
    maintainers = with lib.maintainers; [ sigmanificient ];
    platforms = lib.platforms.linux;
    mainProgram = "gbsplay";
  };
})
