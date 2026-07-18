{
  lib,
  stdenv,
  fetchFromGitHub,
  darwin,
  dune,
  ocamlPackages,
  python3,
  why3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "easycrypt";
  version = "2026.06";

  src = fetchFromGitHub {
    owner = "easycrypt";
    repo = "easycrypt";
    tag = "r${finalAttrs.version}";
    hash = "sha256-+exP4UWfNGZauznLZTA/NkMOHJNstz4oaTqI0bSnkH8=";
  };

  postPatch = ''
    substituteInPlace dune-project --replace-fail '(name easycrypt)' '(name easycrypt)(version ${finalAttrs.version})'
  '';

  strictDeps = true;

  nativeBuildInputs =
    with ocamlPackages;
    [
      dune
      findlib
      menhir
      ocaml
      python3.pkgs.wrapPython
    ]
    ++ lib.optional stdenv.hostPlatform.isDarwin darwin.sigtool;

  buildInputs = with ocamlPackages; [
    batteries
    dune-build-info
    dune-site
    markdown
    pcre2
    why3
    yojson
    zarith
  ];

  propagatedBuildInputs = [ why3.out ];

  installPhase = ''
    runHook preInstall
    dune install --prefix $out easycrypt
    rm $out/bin/ec-runtest
    wrapPythonProgramsIn "$out/lib/easycrypt/commands" "''${pythonPath[*]}"
    runHook postInstall
  '';

  pythonPath = with python3.pkgs; [ pyyaml ];

  meta = {
    description = "Computer-Aided Cryptographic Proofs";
    homepage = "https://easycrypt.info/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];
    platforms = lib.platforms.all;
    mainProgram = "easycrypt";
  };
})
