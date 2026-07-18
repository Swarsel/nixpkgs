{
  lib,
  fetchFromGitHub,
  build-idris-package,
}:
build-idris-package {
  pname = "canvas";
  version = "2017-11-09";

  src = fetchFromGitHub {
    owner = "JinWuZhao";
    repo = "idriscanvas";
    rev = "2957c78c0721ec3afaee9d64e051a8f8d9b6f426";
    sha256 = "0jirkqciv3j1phpm2v6fmch40b5a01rmqdng16y8mihq1wb70ayy";
  };

  ipkgName = "idriscanvas";

  meta = {
    description = "Idris FFI binding for html5 canvas 2d api";
    homepage = "https://github.com/JinWuZhao/idriscanvas";
    maintainers = [ lib.maintainers.brainrape ];
  };
}
