{
  lib,
  stdenv,
  fetchFromGitHub,
  babashka,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "neil";
  version = "0.3.70";

  src = fetchFromGitHub {
    owner = "babashka";
    repo = "neil";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fuVZrv85PZQBM6mb7EWvvIfY3uoPY3VicY2QE8T9I3U=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -D neil $out/bin/neil
    wrapProgram $out/bin/neil \
      --prefix PATH : "${lib.makeBinPath [ babashka ]}"
  '';

  dontBuild = true;

  meta = {
    description = "CLI to add common aliases and features to deps.edn-based projects";
    homepage = "https://github.com/babashka/neil";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jlesquembre ];
    platforms = babashka.meta.platforms;
    mainProgram = "neil";
  };
})
