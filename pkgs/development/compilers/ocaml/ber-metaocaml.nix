{
  lib,
  stdenv,
  fetchurl,
  buildEnv,
  libx11,
  ncurses,
  xorgproto,
  useX11 ? stdenv.hostPlatform.isx86,
}:

let
  x11deps = [
    libx11
    xorgproto
  ];
  inherit (lib) optionals;

  baseOcamlBranch = "5.3";
  baseOcamlVersion = "${baseOcamlBranch}.0";
  metaocamlPatch = "153";
in

stdenv.mkDerivation rec {
  pname = "ber-metaocaml";
  version = metaocamlPatch;

  src = fetchurl {
    url = "https://caml.inria.fr/pub/distrib/ocaml-${baseOcamlBranch}/ocaml-${baseOcamlVersion}.tar.gz";
    sha256 = "sha256-IsHdneIb9Dti0ZCQQftfrWSJBSJ79pVQpqa+8x5lTzg=";
  };

  buildInputs = [ ncurses ] ++ optionals useX11 x11deps;
  configureFlags = optionals useX11 [ "--enable-flambda" ];

  postConfigure = ''
    tar -xvzf $metaocaml
    cd ${pname}-${version}
    make patch
    cd ..
  '';

  buildPhase = ''
    make world

    make bootstrap
    make opt.opt
    make -i install
    make installopt
    mkdir -p $out/include
    ln -sv $out/lib/ocaml/caml $out/include/caml
    cd ${pname}-${version}
    make all
  '';

  checkPhase = ''
    cd ${pname}-${version}
    make test
    make test-compile
    make test-native
    cd ..
  '';

  installPhase = ''
    make install
    make install.opt
  '';

  dontStrip = true;

  metaocaml = fetchurl {
    sha256 = "sha256-zN4C+ZKpPyT87U9wba8D475K6NWOotSYdd67D+1LSlI=";
    url = "https://okmij.org/ftp/ML/ber-metaocaml-${metaocamlPatch}.tar.gz";
  };

  prefixKey = "-prefix ";

  x11env = buildEnv {
    name = "x11env";
    paths = x11deps;
  };

  x11inc = "${x11env}/include";
  x11lib = "${x11env}/lib";

  passthru = {
    nativeCompilers = true;
  };

  meta = {
    description = "Multi-Stage Programming extension for OCaml";

    longDescription = ''
      A simple extension of OCaml with the primitive type of code values, and
      three basic multi-stage expression forms: Brackets, Escape, and Run.
    '';

    homepage = "https://okmij.org/ftp/ML/MetaOCaml.html";

    license = with lib.licenses; [
      # compiler
      qpl # library
      lgpl2
    ];

    maintainers = with lib.maintainers; [ thoughtpolice ];
    platforms = with lib.platforms; linux ++ darwin;
    branch = baseOcamlBranch;
    broken = stdenv.hostPlatform.isAarch64 || stdenv.hostPlatform.isMips;
  };
}
