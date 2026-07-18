{
  lib,
  fetchFromGitHub,
  babashka-unwrapped,
  gitUpdater,
  makeWrapper,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "bbin";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "babashka";
    repo = "bbin";
    rev = "v${version}";
    sha256 = "sha256-kkW95GKQIoWTlAhZ+MKQMmZ1MfYgYbp6gn9RHSrIpYs=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    install -D bbin $out/bin/bbin
    mkdir -p $out/share
    cp -r docs $out/share/docs
    wrapProgram $out/bin/bbin \
      --prefix PATH : "${
        lib.makeBinPath [
          babashka-unwrapped
          babashka-unwrapped.graalvmDrv
        ]
      }"

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  passthru = {
    updateScript = gitUpdater { rev-prefix = "v"; };
  };

  meta = {
    inherit (babashka-unwrapped.meta) platforms;
    description = "Install any Babashka script or project with one command";
    homepage = "https://github.com/babashka/bbin";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sohalt ];
    mainProgram = "bbin";
  };
}
