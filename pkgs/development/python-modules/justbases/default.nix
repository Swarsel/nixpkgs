{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hypothesis,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "justbases";
  version = "0.15.2";

  src = fetchFromGitHub {
    owner = "mulkieran";
    repo = "justbases";
    tag = "v${version}";
    hash = "sha256-XraUh3beI2JqKPRHYN5W3Tn3gg0GJCwhnhHIOFdzh6U=";
  };

  nativeCheckInputs = [
    unittestCheckHook
    hypothesis
  ];

  format = "setuptools";

  meta = {
    description = "Conversion of ints and rationals to any base";
    homepage = "https://github.com/mulkieran/justbases";
    changelog = "https://github.com/mulkieran/justbases/blob/v${version}/CHANGES.txt";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ nickcao ];
  };
}
