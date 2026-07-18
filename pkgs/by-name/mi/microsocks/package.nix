{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "microsocks";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "rofl0r";
    repo = "microsocks";
    rev = "v${finalAttrs.version}";
    hash = "sha256-5NR2gtm+uMkjmkV/dv3DzSedfNvYpHZgFHVSrybl0Tk=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm 755 microsocks -t $out/bin/

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tiny, portable SOCKS5 server with very moderate resource usage";
    homepage = "https://github.com/rofl0r/microsocks";
    changelog = "https://github.com/rofl0r/microsocks/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ramblurr ];
    mainProgram = "microsocks";
  };
})
