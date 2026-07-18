{
  lib,
  fetchFromGitHub,
  amaranth,
  buildPythonPackage,
  pdm-backend,
  unstableGitUpdater,
}:

buildPythonPackage rec {
  pname = "amaranth-boards";
  version = "0-unstable-2025-08-28";

  src = fetchFromGitHub {
    owner = "amaranth-lang";
    repo = "amaranth-boards";
    rev = "7e24efe2f6e95afddd0c1b56f1a9423c48caa472";
    hash = "sha256-NkeSFmbiu5XtUEv/IfaY0P72SVH82HmERfPAHqIY+z8=";
    # these files change depending on git branch status
    postFetch = "rm -f $out/.git_archival.txt $out/.gitattributes";
  };

  preBuild = ''
    export PDM_BUILD_SCM_VERSION="${realVersion}"
  '';

  # no tests
  doCheck = false;
  build-system = [ pdm-backend ];
  dependencies = [ amaranth ];
  pyproject = true;

  # from `pdm show`
  realVersion =
    let
      tag = builtins.elemAt (lib.splitString "-" version) 0;
      rev = lib.substring 0 7 src.rev;
    in
    "${tag}1.dev1+g${rev}";

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Board definitions for Amaranth HDL";
    homepage = "https://github.com/amaranth-lang/amaranth-boards";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      thoughtpolice
      pbsds
    ];
  };
}
