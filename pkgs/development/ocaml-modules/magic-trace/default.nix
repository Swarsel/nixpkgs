{
  lib,
  fetchFromGitHub,
  angstrom,
  async,
  buildDunePackage,
  camlzip,
  cohttp,
  core,
  fzf,
  ocaml-crunch,
  owee,
  ppx_jane,
  re,
  cohttp_static_handler ? null,
  core_unix ? null,
  shell ? null,
  zstandard ? null,
}:

buildDunePackage (finalAttrs: {
  pname = "magic-trace";
  version = "1.2.4";

  src = fetchFromGitHub {
    owner = "janestreet";
    repo = "magic-trace";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LkhnlOd5rI8cbOYbVqrkRJ2qTcRn3Zzl6GjQEdjBjVA=";
  };

  nativeBuildInputs = [
    ocaml-crunch
  ];

  buildInputs = [
    angstrom
    async
    camlzip
    cohttp
    cohttp_static_handler
    core
    core_unix
    fzf
    owee
    ppx_jane
    re
    shell
    zstandard
  ];

  minimalOCamlVersion = "4.12";

  meta = {
    description = "Collects and displays high-resolution traces of what a process is doing";
    homepage = "https://github.com/janestreet/magic-trace";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.alizter ];
    platforms = lib.platforms.linux;
    mainProgram = "magic-trace";
  };
})
