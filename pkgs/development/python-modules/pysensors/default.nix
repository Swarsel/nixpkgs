{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  lm_sensors,
  unittestCheckHook,
}:
buildPythonPackage {
  pname = "pysensors";
  version = "2017-07-13";

  # note that https://pypi.org/project/PySensors/ is a different project
  src = fetchFromGitHub {
    owner = "bastienleonard";
    repo = "pysensors";
    rev = "ef46fc8eb181ecb8ad09b3d80bc002d23d9e26b3";
    sha256 = "1xvbxnkz55fk5fpr514263c7s7s9r8hgrw4ybfaj5a0mligmmrfm";
  };

  buildInputs = [ lm_sensors ];
  # Tests are disable because they fail on `aarch64-linux`, probably
  # due to sandboxing
  doCheck = false;
  nativeCheckInputs = [ unittestCheckHook ];
  format = "setuptools";

  unittestFlagsArray = [
    "-s"
    "tests"
  ];

  meta = {
    description = "Easy hardware health monitoring in Python for Linux systems";
    homepage = "https://bastienleonard.github.io/pysensors/";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ guibou ];
    platforms = lib.platforms.linux;
  };
}
