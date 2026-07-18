{
  lib,
  stdenv,
  fetchurl,
  bubblewrap,
  curl,
  getconf,
  makeWrapper,
  ncurses,
  ocaml,
  unzip,
}:

assert lib.versionAtLeast ocaml.version "4.08.0";

stdenv.mkDerivation (finalAttrs: {
  pname = "opam";
  version = "2.5.1";

  src = fetchurl {
    url = "https://github.com/ocaml/opam/releases/download/${finalAttrs.version}/opam-full-${finalAttrs.version}.tar.gz";
    hash = "sha256-SMW/r19cQEjMX0ACXec4X1utOoJpdWIWzW3S8hUAM+0=";
  };

  outputs = [
    "out"
    "installer"
  ];

  patches = [ ./opam-shebangs.patch ];
  strictDeps = true;

  nativeBuildInputs = [
    makeWrapper
    unzip
    ocaml
    curl
  ];

  buildInputs = [
    ncurses
    getconf
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ bubblewrap ];

  configureFlags = [
    "--with-vendored-deps"
    "--with-mccs"
  ];

  doCheck = false;

  postInstall = ''
    wrapProgram $out/bin/opam \
      --suffix PATH : ${
        lib.makeBinPath (
          [
            curl
            getconf
            unzip
          ]
          ++ lib.optionals stdenv.hostPlatform.isLinux [ bubblewrap ]
        )
      }
    $out/bin/opam-installer --prefix=$installer opam-installer.install
  '';

  setOutputFlags = false;

  meta = {
    description = "Package manager for OCaml";
    homepage = "https://opam.ocaml.org/";
    changelog = "https://github.com/ocaml/opam/raw/${finalAttrs.version}/CHANGES";
    license = lib.licenses.lgpl21Only;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
