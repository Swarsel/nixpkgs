{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "findnewest";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "0-wiz-0";
    repo = "findnewest";
    rev = "findnewest-${finalAttrs.version}";
    sha256 = "1x1cbn2b27h5r0ah5xc06fkalfdci2ngrgd4wibxjw0h88h0nvgq";
  };

  nativeBuildInputs = [ autoreconfHook ];

  meta = {
    description = "Recursively find newest file in a hierarchy and print its timestamp";
    homepage = "https://github.com/0-wiz-0/findnewest";
    license = lib.licenses.bsd2;
    mainProgram = "fn";
  };
})
