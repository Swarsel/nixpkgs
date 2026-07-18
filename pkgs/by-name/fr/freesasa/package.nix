{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fetchpatch,
  json_c,
  libtool,
  libxml2,
  pkg-config,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "freesasa";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "mittinatten";
    repo = "freesasa";
    tag = finalAttrs.version;
    hash = "sha256-OH1/GGFtMBnHuoOu3pdR+ohVO1m0I/jmCZbxPQ0C0jo=";
    fetchSubmodules = true;
  };

  patches = [
    (fetchpatch {
      hash = "sha256-NA4jMue9ATxP+A0tYIptwz0qCXTmAqoMRBsi5d5uv3E=";
      includes = [ "src/Makefile.am" ];
      # https://github.com/mittinatten/freesasa/issues/85
      name = "fix-linker-error.patch";
      url = "https://github.com/mittinatten/freesasa/commit/d5898c13af0f272697726c567a22f1c48af53d62.patch";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    libtool
    pkg-config
  ];

  buildInputs = [
    json_c
    libxml2
  ];

  passthru.tests = {
    version = testers.testVersion { package = finalAttrs.finalPackage; };
  };

  meta = {
    description = "C-library for calculating Solvent Accessible Surface Areas";
    homepage = "https://github.com/mittinatten/freesasa";
    changelog = "https://github.com/mittinatten/freesasa/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
    platforms = lib.platforms.unix;
    mainProgram = "freesasa";
  };
})
