{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  bump2version,
  fonttools,
  glyphslib,
  openstep-plist,
  poetry-core,
  pythonRelaxDepsHook,
  ufolib2,
}:

buildPythonPackage rec {
  pname = "bumpfontversion";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "simoncozens";
    repo = "bumpfontversion";
    tag = "v${version}";
    hash = "sha256-qcKZGv/KeeSRBq4SdnuZlurp0CUs40iEQjw9/1LltUg=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'poetry>=' 'poetry-core>=' \
      --replace-fail 'poetry.masonry.api' 'poetry.core.masonry.api'
  '';

  nativeBuildInputs = [ pythonRelaxDepsHook ];
  build-system = [ poetry-core ];

  dependencies = [
    fonttools
    openstep-plist
    ufolib2
    glyphslib
    bump2version
  ];

  pyproject = true;
  pythonRelaxDeps = [ "glyphslib" ];

  meta = {
    description = "Version-bump your font sources";
    homepage = "https://github.com/simoncozens/bumpfontversion";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jopejoe1 ];
    mainProgram = "bumpfontversion";
  };
}
