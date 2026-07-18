{
  lib,
  fetchFromGitHub,
  gitUpdater,
  melpaBuild,
  prop-menu,
}:

let
  version = "1.1";
in
melpaBuild {
  inherit version;
  pname = "idris2-mode";

  src = fetchFromGitHub {
    owner = "idris-community";
    repo = "idris2-mode";
    tag = version;
    hash = "sha256-rTeVjkAw44Q35vjaERs4uoZRJ6XR3FKplEUCVPHhY7Q=";
  };

  packageRequires = [
    prop-menu
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Emacs mode for editing Idris 2 code";
    homepage = "https://github.com/idris-community/idris2-mode";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ wuyoli ];
  };
}
