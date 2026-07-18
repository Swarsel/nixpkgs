{
  lib,
  stdenv,
  fetchFromGitHub,
  buildDunePackage,
  findlib,
  ocaml,
  ocamlbuild,
}:

let
  pname = "cppo";

  meta = {
    description = "C preprocessor for OCaml";

    longDescription = ''
      Cppo is an equivalent of the C preprocessor targeted at the OCaml language and its variants.
    '';

    homepage = "https://github.com/ocaml-community/${pname}";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.vbgl ];
    mainProgram = "cppo";
  };

in

if lib.versionAtLeast ocaml.version "4.02" then

  buildDunePackage rec {
    inherit pname;
    inherit meta;
    version = "1.8.0";

    src = fetchFromGitHub {
      owner = "ocaml-community";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-+HnAGM+GddYJK0RCvKrs+baZS+1o8Yq+/cVa3U3nFWg=";
    };

    doCheck = true;
  }

else

  let
    version = "1.5.0";
  in

  stdenv.mkDerivation {
    inherit pname version;
    inherit meta;

    src = fetchFromGitHub {
      owner = "mjambon";
      repo = pname;
      rev = "v${version}";
      sha256 = "1xqldjz9risndnabvadw41fdbi5sa2hl4fnqls7j9xfbby1izbg8";
    };

    strictDeps = true;

    nativeBuildInputs = [
      ocaml
      findlib
      ocamlbuild
    ];

    makeFlags = [ "PREFIX=$(out)" ];

    preBuild = ''
      mkdir -p $out/bin
    '';

    createFindlibDestdir = true;

  }
