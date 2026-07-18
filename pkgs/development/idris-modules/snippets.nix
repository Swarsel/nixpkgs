{
  lib,
  fetchFromGitHub,
  build-idris-package,
  contrib,
}:
build-idris-package {
  pname = "snippets";
  version = "2018-03-17";

  src = fetchFromGitHub {
    owner = "palladin";
    repo = "idris-snippets";
    rev = "c26d6f5ffc1cc0456279f5ac74fec5af8c09025e";
    sha256 = "1vwyzck6yan3wifsyj02ji9l6x9rs2r02aybm90gl676s2x4mhjn";
  };

  idrisDeps = [ contrib ];
  ipkgName = "idris-snippets";

  meta = {
    description = "Collection of Idris snippets";
    homepage = "https://github.com/palladin/idris-snippets";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.brainrape ];
  };
}
