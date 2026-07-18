{
  lib,
  fetchFromGitHub,
  buildGoModule,
  makeWrapper,
  stockfish,
}:

buildGoModule (finalAttrs: {
  pname = "uchess";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "tmountain";
    repo = "uchess";
    rev = "v${finalAttrs.version}";
    sha256 = "1njl3f41gshdpj431zkvpv2b7zmh4m2m5q6xsijb0c0058dk46mz";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-4yEE1AsSChayCBxaMXPsbls7xGmFeWRhfOMHyAAReDY=";
  # package does not contain any tests as of v0.2.1
  doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/uchess --suffix PATH : ${stockfish}/bin
  '';

  subPackages = [ "cmd/uchess" ];

  meta = {
    description = "Play chess against UCI engines in your terminal";
    homepage = "https://tmountain.github.io/uchess/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tmountain ];
    mainProgram = "uchess";
  };
})
