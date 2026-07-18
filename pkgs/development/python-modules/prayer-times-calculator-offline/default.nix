{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "prayer-times-calculator-offline";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "cpfair";
    repo = "prayer-times-calculator-offline";
    tag = "v${version}";
    hash = "sha256-sVEdjtwxwGa354YimeaNqjqZ9yEecNXg8kk6Pafvvd4=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "prayer_times_calculator_offline" ];

  meta = {
    description = "Prayer Times Calculator - Offline";
    homepage = "https://github.com/cpfair/prayer-times-calculator-offline";
    changelog = "https://github.com/cpfair/prayer-times-calculator-offline/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
