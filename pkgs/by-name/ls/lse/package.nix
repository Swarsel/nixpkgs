{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lse";
  version = "4.14nw";

  src = fetchFromGitHub {
    owner = "diego-treitos";
    repo = "linux-smart-enumeration";
    tag = finalAttrs.version;
    hash = "sha256-qGLmrbyeyhHG6ONs7TJLTm68xpvxB1iAnMUApfTSqEk=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ bash ];

  installPhase = ''
    mkdir -p $out/bin
    cp lse.sh $out/bin/lse.sh
    wrapProgram $out/bin/lse.sh \
      --prefix PATH : ${lib.makeBinPath [ bash ]}
  '';

  meta = {
    description = "Linux enumeration tool with verbosity levels";
    homepage = "https://github.com/diego-treitos/linux-smart-enumeration";
    changelog = "https://github.com/diego-treitos/linux-smart-enumeration/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ fab ];
    platforms = lib.platforms.all;
    mainProgram = "lse.sh";
  };
})
