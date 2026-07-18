{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  extlib,
  fuse3,
  gapi-ocaml,
  ocaml,
  ocaml_sqlite3,
  otoml,
  ounit2,
  tiny_httpd,
}:

buildDunePackage (finalAttrs: {
  pname = "google-drive-ocamlfuse";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "astrada";
    repo = "google-drive-ocamlfuse";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nTZdE9F6ufQ/O/Ck6fzoK65uZ0ylMR6HkwKsBNRDjMs=";
  };

  buildInputs = [
    extlib
    fuse3
    gapi-ocaml
    ocaml_sqlite3
    otoml
    tiny_httpd
  ];

  doCheck = lib.versionAtLeast ocaml.version "4.14";
  checkInputs = [ ounit2 ];
  minimalOCamlVersion = "4.13";

  meta = {
    description = "FUSE-based file system backed by Google Drive, written in OCaml";
    homepage = "https://github.com/astrada/google-drive-ocamlfuse/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ obadz ];
    platforms = lib.platforms.linux;
    mainProgram = "google-drive-ocamlfuse";
  };
})
