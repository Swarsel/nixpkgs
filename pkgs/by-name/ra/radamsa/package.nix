{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitLab,
  bash,
}:

let
  # Fetch explicitly, otherwise build will try to do so
  owl = fetchurl {
    hash = "sha256-/KhdrjaRAQhZjYpKJE33qMJxnngDrEbScHYuzkrvxVw=";
    name = "ol.c.gz";
    url = "https://haltp.org/files/ol-0.2.2.c.gz";
  };
  hex = fetchFromGitLab {
    hash = "sha256-OT04EGun8nKR6D55bMx8xj20dSFwxI7zP/8sdeFZAHQ=";
    owner = "owl-lisp";
    repo = "hex";
    rev = "e95ebd38e4f7ef8e3d4e653f432e43ce0a804ca6";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "radamsa";
  version = "0.7";

  src = fetchFromGitLab {
    owner = "akihe";
    repo = "radamsa";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cwTE+8mZujuVbm8vOpqGWCAYMwrWUXzLP7k3y7UoKtU=";
  };

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "BINDIR="
  ];

  doCheck = true;
  nativeCheckInputs = [ bash ];
  __darwinAllowLocalNetworking = true;

  patchPhase = ''
    substituteInPlace ./tests/bd.sh  \
      --replace-fail "/bin/echo" echo
    substituteInPlace Makefile  \
      --replace-fail "cd lib && git clone https://gitlab.com/owl-lisp/hex.git" ""

    ln -s ${owl} ol.c.gz
    mkdir lib
    ln -s ${hex} lib/hex

    patchShebangs tests
  '';

  meta = {
    description = "General purpose fuzzer";
    longDescription = "Radamsa is a general purpose data fuzzer. It reads data from given sample files, or standard input if none are given, and outputs modified data. It is usually used to generate malformed data for testing programs.";
    homepage = "https://gitlab.com/akihe/radamsa";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "radamsa";
  };
})
