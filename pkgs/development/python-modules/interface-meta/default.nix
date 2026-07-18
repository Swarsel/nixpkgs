{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  poetry-dynamic-versioning,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "interface-meta";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "matthewwardrop";
    repo = "interface_meta";
    rev = "v${version}";
    sha256 = "0rzh11wnab33b11391vc2ynf8ncxn22b12wn46lmgkrc5mqza8hd";
  };

  patches = [ ./0001-fix-version.patch ];
  nativeBuildInputs = [ poetry-core ];
  propagatedBuildInputs = [ poetry-dynamic-versioning ];
  checkInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "interface_meta" ];

  meta = {
    description = "Convenient way to expose an extensible API with enforced method signatures and consistent documentation";
    homepage = "https://github.com/matthewwardrop/interface_meta";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ swflint ];
  };
}
