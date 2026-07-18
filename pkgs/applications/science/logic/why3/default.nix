{
  lib,
  stdenv,
  fetchurl,
  callPackage,
  coqPackages,
  emacs,
  hevea,
  ocamlPackages,
  rubber,
  wrapGAppsHook3,
  ideSupport ? true,
  version ? "1.8.2",
}:

stdenv.mkDerivation rec {
  inherit version;
  pname = "why3";

  src = fetchurl {
    url = "https://why3.gitlabpages.inria.fr/releases/${pname}-${version}.tar.gz";

    hash =
      {
        "1.6.0" = "sha256-hFvM6kHScaCtcHCc6Vezl9CR7BFbiKPoTEh7kj0ZJxw=";
        "1.7.2" = "sha256-VaSG/FiO2MDdSSFXGJJrIylQx0LPwtT8AF7TpPVZhCQ=";
        "1.8.2" = "sha256-t9ES7dW8zmvM4AI9K8g06yrhocQteupE/6Ek1km1C+o=";
      }
      ."${version}";
  };

  outputs = [
    "out"
    "dev"
  ];

  strictDeps = true;

  nativeBuildInputs =
    lib.optional ideSupport wrapGAppsHook3
    ++ (with ocamlPackages; [
      ocaml
      findlib
      menhir
    ])
    ++ [
      # Coq Support
      coqPackages.coq
    ];

  buildInputs =
    with ocamlPackages;
    [
      ocamlgraph
      zarith
      # Emacs compilation of why3.el
      emacs
      # Documentation
      rubber
      hevea
    ]
    ++
      lib.optional ideSupport
        # GUI
        lablgtk3-sourceview3
    ++ [
      # WebIDE
      js_of_ocaml
      js_of_ocaml-ppx
      # S-expression output for why3pp
      ppx_deriving
      ppx_sexp_conv
    ]
    ++
      # Coq Support
      (with coqPackages; [
        coq
        flocq
      ]);

  propagatedBuildInputs = with ocamlPackages; [
    camlzip
    menhirLib
    (if lib.versionAtLeast version "1.8.0" then zarith else num)
    re
    sexplib
  ];

  configureFlags = [
    "--enable-verbose-make"
    (lib.enableFeature ideSupport "ide")
  ];

  postInstall = ''
    mkdir -p $dev/lib
    mv $out/lib/ocaml $dev/lib/
  '';

  enableParallelBuilding = true;

  installTargets = [
    "install"
    "install-lib"
  ];

  passthru.withProvers = callPackage ./with-provers.nix { };

  meta = {
    description = "Platform for deductive program verification";
    homepage = "https://why3.lri.fr/";
    license = lib.licenses.lgpl21;

    maintainers = with lib.maintainers; [
      thoughtpolice
      vbgl
    ];

    platforms = lib.platforms.unix;
  };
}
