{
  lib,
  fetchFromGitHub,
  buildDubPackage,
  dtools,
  libclang,
}:

buildDubPackage (finalAttrs: {
  pname = "dpp";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "atilaneves";
    repo = "dpp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8zcjZ8EV5jdZrRCHkzxu9NeehY2/5AfOSdzreFC9z3c=";
  };

  nativeBuildInputs = [ dtools ];
  buildInputs = [ libclang ];

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/d++ -t $out/d++
    runHook postInstall
  '';

  dubLock = ./dub-lock.json;

  meta = {
    description = "Directly include C headers in D source code";
    homepage = "https://github.com/atilaneves/dpp";
    changelog = "https://github.com/atilaneves/dpp/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.boost;
    maintainers = with lib.maintainers; [ ipsavitsky ];
    mainProgram = "d++";
  };
})
