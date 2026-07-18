{
  lib,
  stdenv,
  fetchFromGitHub,
  guile,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fetch-scm";
  version = "0.1.6";

  src = fetchFromGitHub {
    owner = "KikyTokamuro";
    repo = "fetch.scm";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-WdYi8EVxQ6xPtld8JyZlUmgpxroevBehtkRANovMh2E=";
  };

  buildInputs = [ guile ];

  installPhase = ''
    runHook preInstall
    install -Dm555 fetch.scm $out/bin/fetch-scm
    runHook postInstall
  '';

  dontBuild = true;

  meta = {
    description = "System information fetcher written in GNU Guile Scheme";
    homepage = "https://github.com/KikyTokamuro/fetch.scm";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ vel ];
    platforms = lib.platforms.all;
    mainProgram = "fetch-scm";
  };
})
