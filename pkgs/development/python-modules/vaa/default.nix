{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cerberus,
  django,
  djangorestframework,
  email-validator,
  flit-core,
  marshmallow,
  pyschemes,
  pytestCheckHook,
  wtforms,
}:

buildPythonPackage rec {
  pname = "vaa";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "life4";
    repo = "vaa";
    tag = "v.${version}";
    hash = "sha256-24GTTJSZ55ejyHoWP1/S3DLTKvOolAJr9UhWoOm84CU=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace "requires = [\"flit\"]" "requires = [\"flit_core\"]" \
      --replace "build-backend = \"flit.buildapi\"" "build-backend = \"flit_core.buildapi\""
  '';

  nativeBuildInputs = [ flit-core ];

  nativeCheckInputs = [
    pytestCheckHook
    cerberus
    django
    djangorestframework
    marshmallow
    pyschemes
    wtforms
    email-validator
  ];

  pyproject = true;
  pythonImportsCheck = [ "vaa" ];

  meta = {
    description = "VAlidators Adapter makes validation by any existing validator with the same interface";
    homepage = "https://github.com/life4/vaa";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gador ];
  };
}
