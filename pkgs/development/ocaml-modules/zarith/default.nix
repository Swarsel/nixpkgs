{
  lib,
  stdenv,
  fetchFromGitHub,
  findlib,
  gmp,
  ocaml,
  pkg-config,
  version ? if lib.versionAtLeast ocaml.version "4.08" then "1.14" else "1.13",
}:

stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "ocaml${ocaml.version}-zarith";

  src = fetchFromGitHub {
    owner = "ocaml";
    repo = "Zarith";
    rev = "release-${version}";

    hash =
      {
        "1.13" = "sha256-CNVKoJeO3fsmWaV/dwnUA8lgI4ZlxR/LKCXpCXUrpSg=";
        "1.14" = "sha256-xUrBDr+M8uW2KOy7DZieO/vDgsSOnyBnpOzQDlXJ0oE=";
      }
      ."${finalAttrs.version}";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    ocaml
    findlib
  ];

  propagatedBuildInputs = [ gmp ];
  configureFlags = [ "-installdir ${placeholder "out"}/lib/ocaml/${ocaml.version}/site-lib" ];
  preInstall = "mkdir -p $out/lib/ocaml/${ocaml.version}/site-lib/stublibs";
  configurePlatforms = [ ];
  dontAddPrefix = true;
  dontAddStaticConfigureFlags = true;

  meta = {
    inherit (ocaml.meta) platforms;
    description = "Fast, arbitrary precision OCaml integers";
    homepage = "https://github.com/ocaml/Zarith";
    changelog = "https://github.com/ocaml/Zarith/raw/${finalAttrs.src.rev}/Changes";
    license = lib.licenses.lgpl2;

    maintainers = with lib.maintainers; [
      thoughtpolice
      vbgl
    ];

    broken = lib.versionOlder ocaml.version "4.04";
  };
})
