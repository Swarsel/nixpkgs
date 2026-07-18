{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  fileutils, # only for tests
  lwt, # optional lwt support
  ounit2,
}:

buildDunePackage (finalAttrs: {
  pname = "inotify";
  version = "2.6";

  src = fetchFromGitHub {
    owner = "whitequark";
    repo = "ocaml-inotify";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Vg9uVIx6/OMS1WoJIHwZbSt5ZyFy+Xgw5167FJWGslg=";
  };

  buildInputs = [ lwt ];
  doCheck = true;

  checkInputs = [
    ounit2
    fileutils
  ];

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Bindings for Linux’s filesystem monitoring interface, inotify";
    license = lib.licenses.lgpl21;
    maintainers = [ lib.maintainers.vbgl ];
    platforms = lib.platforms.linux;
  };
})
