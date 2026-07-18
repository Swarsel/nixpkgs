{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "cookies";
  version = "2.2.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-1raYeIyuTPpOYu+GQ6nKMyt5vZbLMUKUuGSujX6z7o4=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-8e3haOnbSXlL/ZY4uv6P4+ABBKrsCjbEpsLHaulbIUk=";
      name = "fix-deprecations.patch";
      url = "https://gitlab.com/sashahart/cookies/-/commit/22543d970568d577effe120c5a34636a38aa397b.patch";
    })
  ];

  nativeBuildInputs = [ pytestCheckHook ];

  disabledTests = [
    # https://gitlab.com/sashahart/cookies/-/issues/6
    "test_encoding_assumptions"
  ];

  format = "setuptools";

  meta = {
    description = "Friendlier RFC 6265-compliant cookie parser/renderer";
    homepage = "https://github.com/sashahart/cookies";
    license = lib.licenses.mit;
  };
}
