{
  lib,
  stdenv,
  fetchFromGitHub,
  camlp-streams,
  findlib,
  libGLU,
  libglut,
  ocaml,
}:

stdenv.mkDerivation rec {
  pname = "ocaml${ocaml.version}-lablgl";
  version = "1.07";

  src = fetchFromGitHub {
    owner = "garrigue";
    repo = "lablgl";
    rev = "v${version}";
    hash = "sha256-GiQKHMn5zHyvDrA2ve12X5YTm3/RZp8tukIqifgVaW4=";
  };

  patches = [ ./META.patch ];
  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
  ];

  buildInputs = [
    libglut
    camlp-streams
  ];

  propagatedBuildInputs = [
    libGLU
  ];

  makeFlags = [
    "BINDIR=${placeholder "out"}/bin/"
    "INSTALLDIR=${placeholder "out"}/lib/ocaml/${ocaml.version}/site-lib/lablgl/"
    "DLLDIR=${placeholder "out"}/lib/ocaml/${ocaml.version}/site-lib/stublibs/"
    "XINCLUDES="
    "TKINCLUDES="
    "TKLIBS="
  ];

  buildFlags = [
    "lib"
    "libopt"
    "glut"
    "glutopt"
  ];

  preConfigure = ''
    mkdir -p $out/bin
    mkdir -p $out/lib/ocaml/${ocaml.version}/site-lib/stublibs
    cp \
      Makefile.config.${if stdenv.hostPlatform.isDarwin then "osx" else "ex"} \
      Makefile.config
  '';

  postInstall = ''
    cp ./META $out/lib/ocaml/${ocaml.version}/site-lib/lablgl
  '';

  meta = {
    description = "OpenGL bindings for ocaml";
    homepage = "http://wwwfun.kurims.kyoto-u.ac.jp/soft/lsl/lablgl.html";
    license = lib.licenses.gpl2;

    maintainers = with lib.maintainers; [
      pSub
      vbgl
    ];

    mainProgram = "lablglut";
    broken = lib.versionOlder ocaml.version "4.06";
  };
}
