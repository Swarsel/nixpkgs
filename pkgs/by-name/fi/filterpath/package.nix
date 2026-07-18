{
  lib,
  stdenv,
  fetchFromGitHub,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "filterpath";
  version = "1.0.4";

  src = fetchFromGitHub {
    owner = "Sigmanificient";
    repo = "filterpath";
    tag = finalAttrs.version;
    hash = "sha256-FOewYznmWOWH2TyNySVoa+spvH4QlXnjlko+/zFiNik=";
  };

  makeFlags = [
    "CC=cc"
    "PREFIX=${placeholder "out"}/bin"
  ];

  doCheck = true;

  meta = {
    description = "Retrieve a valid path from a messy piped line";
    homepage = "https://github.com/Sigmanificient/filterpath";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      sigmanificient
      eveeifyeve # Darwin
    ];

    platforms = lib.platforms.unix;
    mainProgram = "filterpath";
  };
})
