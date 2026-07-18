{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cffi,
  numpy,
  pytestCheckHook,
  setuptools,
  soundfile,
  unixtools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyflac";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "sonos";
    repo = "pyFLAC";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PA9ARch1MwBhLlTIIM+pXHc10pg0PM/uEHfwQ5e5MNI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    unixtools.procps # for sysctl
  ];

  preCheck = ''
    rm -r pyflac
  '';

  build-system = [ setuptools ];

  dependencies = [
    cffi
    numpy
    soundfile
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyflac" ];

  meta = {
    description = "Wrapper for libFLAC";
    homepage = "https://github.com/sonos/pyFLAC/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ SuperSandro2000 ];
  };
})
