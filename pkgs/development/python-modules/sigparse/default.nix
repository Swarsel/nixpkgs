{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "sigparse";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "Lunarmagpie";
    repo = "sigparse";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VzWDqplYgwrJXXd5IUzEIp0YRuofybqmGrNKPaGqQFM=";
  };

  patches = [
    # pyproject.toml version file is set as 1.0.0
    (fetchpatch {
      hash = "sha256-3EOkdBQDBodMBp4ENdvquJlRvAAywQhdWAX4dWFmhL0=";
      url = "https://github.com/Lunarmagpie/sigparse/pull/14/commits/44780382410bc6913bdd8ff7e92948078adb736c.patch";
    })
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "sigparse" ];

  meta = {
    description = "Backports python 3.10 typing features into 3.7, 3.8, and 3.9";
    homepage = "https://github.com/Lunarmagpie/sigparse";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
