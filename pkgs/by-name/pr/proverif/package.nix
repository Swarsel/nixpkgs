{
  lib,
  stdenv,
  fetchurl,
  graphviz,
  m4,
  makeBinaryWrapper,
  ocamlPackages,
  enable_interact ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "proverif";
  version = "2.05";

  src = fetchurl {
    url = "https://bblanche.gitlabpages.inria.fr/proverif/proverif${finalAttrs.version}.tar.gz";
    hash = "sha256-SHH1PDKrSgRmmgYMSIa6XZCASWlj+5gKmmLSxCnOq8Q=";
  };

  strictDeps = true;

  nativeBuildInputs =
    with ocamlPackages;
    [
      ocaml
      findlib
    ]
    ++ lib.optionals enable_interact [ makeBinaryWrapper ];

  buildInputs = lib.optionals enable_interact [
    ocamlPackages.lablgtk
  ];

  buildPhase = ''
    runHook preBuild
    ${if enable_interact then "./build" else "./build -nointeract"}
    runHook postBuild
  '';

  doCheck = true;
  nativeCheckInputs = [ m4 ];

  checkPhase = ''
    runHook preCheck
    ./test
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -D -t $out/bin proverif proveriftotex
    install -D -t $out/share/emacs/site-lisp/ emacs/proverif.el

    ${lib.optionalString enable_interact ''
      install -D -t $out/bin proverif_interact
      wrapProgram $out/bin/proverif_interact \
        --prefix PATH : ${lib.makeBinPath [ graphviz ]}
    ''}

    runHook postInstall
  '';

  meta = {
    description = "Cryptographic protocol verifier in the formal model";
    homepage = "https://bblanche.gitlabpages.inria.fr/proverif/";
    license = lib.licenses.gpl2;

    maintainers = with lib.maintainers; [
      thoughtpolice
      vbgl
    ];

    platforms = lib.platforms.unix;
  };
})
