{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "vimwiki-markdown";
  version = "0.4.1";

  src = fetchPypi {
    inherit version pname;
    hash = "sha256-hJl0OTE6kHucVGOxgOZBG0noYRfxma3yZSrUWEssLN4=";
  };

  propagatedBuildInputs = with python3Packages; [
    markdown
    pygments
  ];

  format = "setuptools";

  meta = {
    description = "Vimwiki markdown plugin";
    homepage = "https://github.com/WnP/vimwiki_markdown";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ seqizz ];
    mainProgram = "vimwiki_markdown";
  };
}
