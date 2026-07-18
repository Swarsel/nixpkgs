{
  lib,
  stdenv,
  fetchFromGitLab,
  python3,
}:

stdenv.mkDerivation {
  pname = "pokemon-colorscripts";
  version = "0-unstable-2024-10-19";

  src = fetchFromGitLab {
    owner = "phoneybadger";
    repo = "pokemon-colorscripts";
    rev = "5802ff67520be2ff6117a0abc78a08501f6252ad";
    hash = "sha256-gKVmpHKt7S2XhSxLDzbIHTjJMoiIk69Fch202FZffqU=";
  };

  postPatch = ''
    patchShebangs --build ./install.sh
    substituteInPlace install.sh --replace-fail "/usr/local" "$out"
  '';

  buildInputs = [
    python3
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    ./install.sh

    runHook postInstall
  '';

  meta = {
    description = "Scripts for Pokémon color manipulation";
    homepage = "https://gitlab.com/phoneybadger/pokemon-colorscripts";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.viitorags ];
    mainProgram = "pokemon-colorscripts";
  };
}
