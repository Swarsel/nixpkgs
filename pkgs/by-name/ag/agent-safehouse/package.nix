{
  lib,
  fetchFromGitHub,
  nix-update-script,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "safehouse";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "eugene1g";
    repo = "agent-safehouse";
    rev = "v" + version;
    hash = "sha256-Nm04UnyQ2mVLkIIEspDd2vbdcJxZ17MH07fW6PvokJI=";
  };

  postPatch = "patchShebangs scripts bin";
  strictDeps = true;

  buildPhase = ''
    runHook preBuild
    scripts/generate-dist.sh
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 dist/safehouse.sh $out/bin/safehouse

    runHook postInstall
  '';

  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Sandbox your local AI agents so they can read/write only what they need";
    homepage = "https://github.com/eugene1g/agent-safehouse";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ myzel394 ];
    platforms = lib.platforms.darwin;
    mainProgram = "safehouse";
  };
}
