{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tinyfetch";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "abrik1";
    repo = "tinyfetch";
    tag = finalAttrs.version;
    hash = "sha256-I0OurcPKKZntZn7Bk9AnWdpSrU9olGp7kghdOajPDeQ=";
  };

  buildPhase = ''
    runHook preBuild
    $CC tinyfetch.c -o tinyfetch
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 tinyfetch -t $out/bin
    runHook postInstall
  '';

  sourceRoot = "${finalAttrs.src.name}/src";

  meta = {
    description = "Simple fetch in C which is tiny and fast";
    homepage = "https://github.com/abrik1/tinyfetch";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pagedMov ];
    platforms = lib.platforms.unix;
    mainProgram = "tinyfetch";
  };
})
