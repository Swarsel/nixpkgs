{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  mock,
  setuptools,
  wheel,
}:

buildPythonPackage {
  pname = "mock-django";
  version = "0.6.10";

  src = fetchFromGitHub {
    owner = "dcramer";
    repo = "mock-django";
    rev = "1168d3255e0d67fbf74a9c71feaccbdafef59d21";
    hash = "sha256-sjrRxu2754sAaXZRlAfBhdLFHqiRlqPHVPQv4B6oArw=";
  };

  # tests are based on nose, which is not supported anymore
  doCheck = false;

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    django
    mock
  ];

  pyproject = true;

  meta = {
    description = "Simple library for mocking certain Django behavior, such as the ORM";
    homepage = "https://github.com/dcramer/mock-django";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ defelo ];
  };
}
