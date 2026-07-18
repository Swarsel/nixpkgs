{
  lib,
  stdenv,
  fetchurl,
  nixosTests,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wiki-js";
  version = "2.5.312";

  src = fetchurl {
    url = "https://github.com/Requarks/wiki/releases/download/v${finalAttrs.version}/wiki-js.tar.gz";
    hash = "sha256-J87NrQ+zkUlREe0lGERFFAEW8EFysK5RJhM6OUVI1J0=";
  };

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r . $out

    runHook postInstall
  '';

  dontBuild = true;

  # Unpack the tarball into a subdir. All the contents are copied into `$out`.
  # Unpacking into the parent directory would also copy `env-vars` into `$out`
  # in the `installPhase` which ultimately means that the package retains
  # references to build tools and the tarball.
  preUnpack = ''
    mkdir source
    cd source
  '';

  sourceRoot = ".";

  passthru = {
    tests = { inherit (nixosTests) wiki-js; };
    updateScript = ./update.sh;
  };

  meta = {
    description = "Modern and powerful wiki app built on Node.js";
    homepage = "https://js.wiki/";
    license = lib.licenses.agpl3Only;
    maintainers = [ ];
  };
})
