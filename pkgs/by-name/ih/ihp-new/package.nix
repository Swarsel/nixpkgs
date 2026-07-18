{
  lib,
  stdenv,
  fetchFromGitHub,
  git,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ihp-new";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "digitallyinduced";
    repo = "ihp";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-DmaIr9kF+TG24wVNPVufxC74TYMCLziLYS9hCZHBDTc=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    install -Dm755 bin/ihp-new -t $out/bin
    wrapProgram $out/bin/ihp-new \
      --suffix PATH ":" "${lib.makeBinPath [ git ]}";
  '';

  dontConfigure = true;
  sourceRoot = "${finalAttrs.src.name}/ProjectGenerator";

  meta = {
    description = "Project generator for the IHP (Integrated Haskell Platform) web framework";
    homepage = "https://ihp.digitallyinduced.com";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.mpscholten ];
    platforms = lib.platforms.unix;
    mainProgram = "ihp-new";
  };
})
