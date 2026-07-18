{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  libjpeg_turbo,
  numpy,
  python,
  replaceVars,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyturbojpeg";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "lilohuang";
    repo = "PyTurboJPEG";
    tag = "v${version}";
    hash = "sha256-rMn5NmiwKhyj4U9kyyRf9ZheVnETpixZoL/AVlBlImQ=";
  };

  patches = [
    (replaceVars ./lib-path.patch {
      libturbojpeg = "${lib.getLib libjpeg_turbo}/lib/libturbojpeg${stdenv.hostPlatform.extensions.sharedLibrary}";
    })
  ];

  # upstream has no tests, but we want to test whether the library is found
  checkPhase = ''
    runHook preCheck

    ${python.interpreter} -c 'from turbojpeg import TurboJPEG; TurboJPEG()'

    runHook postCheck
  '';

  build-system = [ setuptools ];
  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "turbojpeg" ];

  meta = {
    description = "Python wrapper of libjpeg-turbo for decoding and encoding JPEG image";
    homepage = "https://github.com/lilohuang/PyTurboJPEG";
    changelog = "https://github.com/lilohuang/PyTurboJPEG/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
