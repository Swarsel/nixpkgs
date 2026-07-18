{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  requests,
  setuptools,
  unittestCheckHook,
  webob,
}:

buildPythonPackage rec {
  pname = "hawkauthlib";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "mozilla-services";
    repo = "hawkauthlib";
    tag = "v${version}";
    hash = "sha256-dFBGrk7vdZMNTuWvXXWXA4iF/vmiUnK9ds8edN2Yt10=";
  };

  postPatch = ''
    substituteInPlace hawkauthlib/tests/* \
        --replace-warn 'assertEquals' 'assertEqual'
  '';

  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    requests
    webob
  ];

  pyproject = true;
  pythonImportsCheck = [ "hawkauthlib" ];

  meta = {
    description = "Hawk Access Authentication protocol";
    homepage = "https://github.com/mozilla-services/hawkauthlib";
    license = lib.licenses.mpl20;
    maintainers = [ ];
  };
}
