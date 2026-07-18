{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "git-my";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "davidosomething";
    repo = "git-my";
    rev = finalAttrs.version;
    hash = "sha256-GzBNtsCrs2M0UBc1FVE+4yUNLpjDGUfekc/LIvgvUUo=";
  };

  buildInputs = [ bash ];

  installPhase = ''
    runHook preInstall

    install -Dm 755 -t "$out/bin" -- git-my

    runHook postInstall
  '';

  dontBuild = true;

  meta = {
    description = "List remote branches if they're merged and/or available locally";
    homepage = "https://github.com/davidosomething/git-my";
    license = lib.licenses.free;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "git-my";
  };
})
