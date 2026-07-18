{
  lib,
  fetchFromGitHub,
  nix-update-script,
  nixosTests,
  ocamlPackages,
  versionCheckHook,
}:

ocamlPackages.buildDunePackage rec {
  pname = "slipshow";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "panglesd";
    repo = "slipshow";
    tag = "v${version}";
    hash = "sha256-6i7zbfk0uBgwoXlg5fLvC+onZMYKBJwUd74FUakt3jc=";
  };

  postPatch = ''
    substituteInPlace ./src/cli/main.ml \
      --replace-fail '%%VERSION%%' '${version}'
  '';

  nativeBuildInputs = with ocamlPackages; [
    js_of_ocaml
  ];

  buildInputs = with ocamlPackages; [
    base64
    bos
    cmdliner
    dream
    fmt
    fpath
    irmin-watcher
    js_of_ocaml-lwt
    logs
    lwt
    magic-mime
    ppx_blob
    ppx_deriving_yojson
    ppx_sexp_value
    sexplib
  ];

  doCheck = true;
  nativeCheckInputs = [ versionCheckHook ];

  # This check fails with cmdliner ≥ 2.0
  preCheck = ''
    rm -f test/compiler/dimension.t/run.t
  '';

  doInstallCheck = true;

  passthru = {
    tests = { inherit (nixosTests) slipshow; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Engine for displaying slips, the next-gen version of slides";
    homepage = "https://slipshow.readthedocs.io/en/latest/index.html";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.ethancedwards8 ];
    mainProgram = "slipshow";
    downloadPage = "https://github.com/panglesd/slipshow";
    teams = [ lib.teams.ngi ];
  };
}
