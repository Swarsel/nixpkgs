{
  lib,
  stdenv,
  fetchFromGitHub,
  gmp,
  jpcre2,
  pcre2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rnm";
  version = "4.0.9";

  src = fetchFromGitHub {
    owner = "neurobin";
    repo = "rnm";
    tag = finalAttrs.version;
    hash = "sha256-cMWIxRuL7UCDjGr26+mfEYBPRA/dxEt0Us5qU92TelY=";
  };

  buildInputs = [
    gmp
    jpcre2
    pcre2
  ];

  meta = {
    description = "Bulk rename utility";
    homepage = "https://neurobin.org/projects/softwares/unix/rnm/";
    changelog = "https://github.com/neurobin/rnm/blob/${finalAttrs.version}/ChangeLog";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
    mainProgram = "rnm";
  };
})
