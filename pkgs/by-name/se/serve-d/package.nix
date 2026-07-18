{
  lib,
  fetchFromGitHub,
  buildDubPackage,
  dtools,
}:

buildDubPackage rec {
  pname = "serve-d";
  version = "0.7.6";

  src = fetchFromGitHub {
    owner = "Pure-D";
    repo = "serve-d";
    rev = "v${version}";
    hash = "sha256-h4zsW8phGcI4z0uMCIovM9cJ6hKdk8rLb/Jp4X4dkpk=";
  };

  nativeBuildInputs = [ dtools ];
  doCheck = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 serve-d -t $out/bin
    runHook postInstall
  '';

  dubLock = ./dub-lock.json;

  meta = {
    description = "D LSP server (dlang language server protocol server)";
    homepage = "https://github.com/Pure-D/serve-d";
    changelog = "https://github.com/Pure-D/serve-d/releases/tag/${src.rev}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomasajt ];
    mainProgram = "serve-d";
  };
}
