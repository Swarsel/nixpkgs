{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pexpect,
  # tests
  pytest-cov-stub,
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "readchar";
  version = "4.2.1";

  # Don't use wheels on PyPI
  src = fetchFromGitHub {
    owner = "magmax";
    repo = "python-${finalAttrs.pname}";
    tag = "v${finalAttrs.version}";
    hash = "sha256-r+dKGv0a7AU+Ef94AGCCJLQolLqTTxaNmqRQYkxk15s=";
  };

  # https://github.com/magmax/python-readchar/pull/129
  patches = [ ./pytest9-compat.patch ];

  postPatch = ''
    # Tags on GitHub still have a postfix (-dev0)
    sed -i 's/\(version = "\)[^"]*\(".*\)/\1${finalAttrs.version}\2/' pyproject.toml
    # run Linux tests on Darwin as well
    # see https://github.com/magmax/python-readchar/pull/99 for why this is not upstreamed
    substituteInPlace tests/linux/conftest.py \
      --replace 'sys.platform.startswith("linux")' 'sys.platform.startswith(("darwin", "linux"))'
  '';

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
    pexpect
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "readchar" ];

  meta = {
    description = "Python library to read characters and key strokes";
    homepage = "https://github.com/magmax/python-readchar";
    changelog = "https://github.com/magmax/python-readchar/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mmahut ];
  };
})
