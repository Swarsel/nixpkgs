{
  lib,
  fetchFromCodeberg,
  ocaml-crunch,
  ocamlPackages,
  seppo,
}:

let
  mcdb = ocamlPackages.callPackage ./mcdb.nix { inherit seppo; };
in

ocamlPackages.buildDunePackage {
  pname = "seppo";
  version = "0-unstable-2025-08-07";

  src = fetchFromCodeberg {
    owner = "seppo";
    repo = "seppo";
    rev = "d927311cae64883fe2b88f5a1c7e17c8cc525bad";
    hash = "sha256-Lb2w0mRNNamCltAwdxOyAYh02wkN7yKJGBzqBIPKE8k=";
  };

  # Static build fails to find correct static libraries
  postPatch = ''
    sed -i 's/-static/""/' bin/gen_flags.sh
  '';

  nativeBuildInputs = [
    ocaml-crunch
  ];

  buildInputs = with ocamlPackages; [
    mcdb

    camlp-streams
    cohttp-lwt-unix
    crunch
    csexp
    decoders-ezjsonm
    lambdasoup
    lwt_ppx
    mirage-crypto-rng
    ocaml_sqlite3
    optint
    safepass
    timedesc
    tls-lwt
    tyre
    uucp
    uuidm
    uunf
    uutf
    x509
    xmlm
  ];

  # Provide git sha to avoid git dependency
  env.GIT_SHA = seppo.src.rev;

  meta = {
    description = "Personal Social Web";
    homepage = "https://seppo.mro.name";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ infinidoge ];
    mainProgram = "seppo";
  };
}
