{
  lib,
  fetchFromGitHub,
  mkDerivation,
  unstableGitUpdater,
}:

mkDerivation {
  pname = "agda-prelude";
  version = "0-unstable-2024-08-22";

  src = fetchFromGitHub {
    owner = "UlfNorell";
    repo = "agda-prelude";
    rev = "4230566d3ae229b6a00258587651ac7bfd38d088";
    hash = "sha256-ab+KojzRbkUTAFNH5OA78s0F5SUuXTbliai6badveg4=";
  };

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Programming library for Agda";
    homepage = "https://github.com/UlfNorell/agda-prelude";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      mudri
      alexarice
      turion
    ];

    platforms = lib.platforms.unix;
  };
}
