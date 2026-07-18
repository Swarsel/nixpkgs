{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  dune-configurator,
  ocaml,
  zarith,
  zlib,
  version ? if lib.versionAtLeast ocaml.version "4.13" then "1.21.1" else "1.20.1",
}:

buildDunePackage (finalAttrs: {
  inherit version;
  pname = "cryptokit";

  src = fetchFromGitHub {
    owner = "xavierleroy";
    repo = "cryptokit";
    tag = "release${lib.replaceStrings [ "." ] [ "" ] finalAttrs.version}";

    hash =
      {
        "1.20.1" = "sha256-VFY10jGctQfIUVv7dK06KP8zLZHLXTxvLyTCObS+W+E=";
        "1.21.1" = "sha256-9JU9grZpTTrYYO9gai2UPq119HfenI1JAY+EyoR6x7Q=";
      }
      ."${finalAttrs.version}";
  };

  buildInputs = [ dune-configurator ];

  propagatedBuildInputs = [
    zarith
    zlib
  ];

  doCheck = true;

  # dont do autotools configuration, but do trigger findlib's preConfigure hook
  configurePhase = ''
    runHook preConfigure
    runHook postConfigure
  '';

  meta = {
    description = "Library of cryptographic primitives for OCaml";
    homepage = "http://pauillac.inria.fr/~xleroy/software.html";
    license = lib.licenses.lgpl2Only;
  };
})
