{
  lib,
  stdenv,
  fetchurl,
  ocaml-ng,
}:

let
  ocaml = ocaml-ng.ocamlPackages_4_14_unsafe_string.ocaml;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "statverif";
  version = "1.86pl4";

  src = fetchurl {
    url = "http://prosecco.gforge.inria.fr/personal/bblanche/proverif/proverif${finalAttrs.version}.tar.gz";
    sha256 = "163vdcixs764jj8xa08w80qm4kcijf7xj911yp8jvz6pi1q5g13i";
  };

  strictDeps = true;
  nativeBuildInputs = [ ocaml ];
  buildPhase = "./build";

  installPhase = ''
    mkdir -p $out/bin
    cp ./proverif      $out/bin/statverif
    cp ./proveriftotex $out/bin/statveriftotex
  '';

  patchPhase = "patch -p1 < ${finalAttrs.pf-patch}";

  pf-patch = fetchurl {
    sha256 = "113jjhi1qkcggbsmbw8fa9ln8vs7vy2r288szks7rn0jjn0wxmbw";
    url = "http://markryan.eu/research/statverif/files/proverif-${finalAttrs.version}-statverif-2657ab4.patch";
  };

  meta = {
    description = "Verification of stateful processes (via Proverif)";
    homepage = "https://markryan.eu/research/statverif/";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.thoughtpolice ];
    platforms = lib.platforms.unix;
  };
})
