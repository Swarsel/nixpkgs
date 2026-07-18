{
  lib,
  stdenv,
  fetchFromGitHub,
  findutils,
  makeWrapper,
  openssh,
  python3,
  rsync,
  which,
}:

stdenv.mkDerivation {
  pname = "bsync";
  version = "0-unstable-2023-12-21";

  src = fetchFromGitHub {
    owner = "dooblem";
    repo = "bsync";
    rev = "25f77730750720ad68b0ab2773e79d9ca98c3647";
    hash = "sha256-k25MjLis0/dp1TTS4aFeJZq/c0T01LmNcWtC+dw/kKY=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ python3 ];

  installPhase = ''
    runHook preInstall
    install -Dm555 bsync -t $out/bin
    runHook postInstall
  '';

  fixupPhase = ''
    runHook preFixup

    patchShebangs $out/bin/bsync
    wrapProgram $out/bin/bsync \
      --prefix PATH ":" ${
        lib.makeLibraryPath [
          openssh
          rsync
          findutils
          which
        ]
      }

    runHook postFixup
  '';

  meta = {
    description = "Bidirectional Synchronization using Rsync";
    homepage = "https://github.com/dooblem/bsync";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dietmarw ];
    platforms = lib.platforms.unix;
    mainProgram = "bsync";
  };
}
