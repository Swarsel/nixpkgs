{
  lib,
  fetchFromGitHub,
  build-idris-package,
  effects,
  lightyear,
}:
build-idris-package {
  pname = "idrishighlighter";
  version = "2018-02-22";

  src = fetchFromGitHub {
    owner = "david-christiansen";
    repo = "idris-code-highlighter";
    rev = "708a29c7d1433adf7b0f69d1aec50e69b2915bba";
    sha256 = "16ahzf2jzh7wzi4jjq94s5z9nzkgnj2962dy13s1crim53csjgw5";
  };

  idrisDeps = [
    effects
    lightyear
  ];

  ipkgName = "idris-code-highlighter";

  meta = {
    description = "Semantic highlighter for Idris code";
    homepage = "https://github.com/david-christiansen/idris-code-highlighter";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.brainrape ];
  };
}
