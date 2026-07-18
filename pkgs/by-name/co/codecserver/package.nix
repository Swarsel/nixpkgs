{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  protobuf_21,
  udev,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "codecserver";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "jketterl";
    repo = "codecserver";
    tag = finalAttrs.version;
    hash = "sha256-JzaVBFl3JsFNDm4gy1qOKA9uAjUjNeMiI39l5gfH0aE=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    udev
  ];

  propagatedBuildInputs = [ protobuf_21 ];

  postFixup = ''
    substituteInPlace "$out"/lib/pkgconfig/codecserver.pc \
      --replace-fail '=''${prefix}//' '=/' \
      --replace-fail '=''${exec_prefix}//' '=/'
  '';

  meta = {
    description = "Modular audio codec server";
    homepage = "https://github.com/jketterl/codecserver";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.unix;
    mainProgram = "codecserver";
  };
})
