{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "pandoc-imagine";
  version = "0.1.7";

  src = fetchFromGitHub {
    owner = "hertogp";
    repo = "imagine";
    rev = version;
    sha256 = "sha256-IJAXrJakKjROF2xi9dsLvGzyGIyB+GDnx/Z7BRlwSqc=";
  };

  propagatedBuildInputs = with python3Packages; [
    pandocfilters
    six
  ];

  # No tests in archive
  doCheck = false;
  format = "setuptools";

  meta = {
    description = ''
      A pandoc filter that will turn code blocks tagged with certain classes
      into images or ASCII art
    '';

    homepage = src.meta.homepage;
    license = with lib.licenses; [ mit ];
    maintainers = [ ];
    mainProgram = "pandoc-imagine";
  };
}
