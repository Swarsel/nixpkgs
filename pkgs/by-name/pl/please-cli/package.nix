{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  jq,
  makeBinaryWrapper,
  please-cli,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "please-cli";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "TNG";
    repo = "please-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Kpb36Fm49Cxr3PMlSoUfTNEMNmWFktgEoej1904DmEE=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];

  installPhase = ''
    runHook preInstall
    install -Dm555 please.sh "$out/bin/please"
    wrapProgram $out/bin/please \
      --prefix PATH : ${
        lib.makeBinPath [
          curl
          jq
        ]
      }
    runHook postInstall
  '';

  passthru.tests = testers.testVersion {
    version = "v${finalAttrs.version}";
    package = please-cli;
  };

  meta = {
    description = "AI helper script to create CLI commands based on GPT prompts";
    homepage = "https://github.com/TNG/please-cli";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ _8-bit-fox ];
    platforms = lib.platforms.all;
    mainProgram = "please";
  };
})
