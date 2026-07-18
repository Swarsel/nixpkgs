{
  lib,
  stdenv,
  fetchFromGitHub,
  gnat13,
  gnat13Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "florist";
  version = "26.1";

  src = fetchFromGitHub {
    owner = "adacore";
    repo = "florist";
    rev = "refs/heads/${finalAttrs.version}";
    hash = "sha256-83bfO7RTVs3b7nEzjxnr2eRXggoMjTLIa9agwYKgP9g=";
  };

  nativeBuildInputs = [
    gnat13
    gnat13Packages.gprbuild
  ];

  configureFlags = [ "--enable-shared" ];

  meta = {
    description = "Posix Ada Bindings";
    homepage = "https://github.com/adacore/florist";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lutzberger ];
    platforms = lib.platforms.linux;
  };
})
