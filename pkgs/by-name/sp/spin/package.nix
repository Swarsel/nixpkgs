{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  gcc,
  graphviz,
  makeWrapper,
  swarm,
  tk,
}:

let
  binPath = lib.makeBinPath [
    gcc
    graphviz
    tk
    swarm
  ];
in

stdenv.mkDerivation (finalAttrs: {
  pname = "spin";
  version = "6.5.2";

  src = fetchFromGitHub {
    owner = "nimble-code";
    repo = "Spin";
    rev = "version-${finalAttrs.version}";
    sha256 = "sha256-drvQXfDZCZRycBZt/VNngy8zs4XVJg+d1b4dQXVcyFU=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ bison ];
  makeFlags = [ "DESTDIR=$(out)" ];

  preBuild = ''
    mkdir -p $out/bin
    mkdir -p $out/share/man/man1
  '';

  postInstall = ''
    wrapProgram $out/bin/spin --prefix PATH : ${binPath}

    mkdir -p $out/share/spin
    cp $src/optional_gui/ispin.tcl $out/share/spin
    makeWrapper $out/share/spin/ispin.tcl $out/bin/ispin \
      --prefix PATH : $out/bin:${binPath}
  '';

  enableParallelBuilding = true;
  sourceRoot = "${finalAttrs.src.name}/Src";

  meta = {
    description = "Formal verification tool for distributed software systems";
    homepage = "https://spinroot.com/";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      pSub
      siraben
    ];

    platforms = lib.platforms.unix;
  };
})
