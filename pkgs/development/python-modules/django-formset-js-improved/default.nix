{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  django-jquery-js,
  fetchpatch,
  setuptools,
}:

buildPythonPackage rec {
  pname = "django-formset-js-improved";
  version = "0.5.0.3";

  src = fetchFromGitHub {
    owner = "pretix";
    repo = "django-formset-js";
    tag = version;
    hash = "sha256-bOM24ldXk9WeV0jl6LIJB3BJ5hVWLA1PJTBBnJBoprU=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-eBRP0eqMnH7UM9cToR+diejO6dMDDVt2bbUHLDcaWjk=";
      url = "https://github.com/pretix/django-formset-js/commit/7d8a33190d58ff9d75270264342eba82672d054e.patch";
    })
  ];

  buildInputs = [ django ];
  doCheck = false; # no tests
  build-system = [ setuptools ];
  dependencies = [ django-jquery-js ];
  pyproject = true;
  pythonImportsCheck = [ "djangoformsetjs" ];

  meta = {
    description = "Wrapper for a JavaScript formset helper";
    homepage = "https://github.com/pretix/django-formset-js";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
