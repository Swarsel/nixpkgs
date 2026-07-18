{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  gnumake,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "makefile2graph";
  version = "2021.11.06";

  src = fetchFromGitHub {
    owner = "lindenb";
    repo = "makefile2graph";
    tag = finalAttrs.version;
    hash = "sha256-4jyftC0eCJ13X/L4uEWhT5FA5/UXUmSHSoba89GSySQ=";
  };

  nativeBuildInputs = [ makeWrapper ];
  makeFlags = [ "prefix=$(out)" ];

  fixupPhase = ''
    substituteInPlace $out/bin/makefile2graph \
      --replace '/bin/sh' ${bash}/bin/bash \
      --replace 'make2graph' "$out/bin/make2graph"
    wrapProgram $out/bin/makefile2graph \
      --set PATH ${lib.makeBinPath [ gnumake ]}
  '';

  meta = {
    description = "Creates a graph of dependencies from GNU-Make; Output is a graphiz-dot file or a Gexf-XML file";
    homepage = "https://github.com/lindenb/makefile2graph";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cmcdragonkai ];
    platforms = lib.platforms.all;
  };
})
