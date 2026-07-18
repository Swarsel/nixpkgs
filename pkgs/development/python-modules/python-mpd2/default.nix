{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  twisted,
  unittestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-mpd2";
  version = "3.1.2";

  src = fetchFromGitHub {
    owner = "Mic92";
    repo = "python-mpd2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3isX3e4Fu1orxuRsC3u8RxoFDQcE4XxQhf8PIHdo/e4=";
  };

  nativeCheckInputs = [ unittestCheckHook ] ++ finalAttrs.passthru.optional-dependencies.twisted;
  build-system = [ setuptools ];

  optional-dependencies = {
    twisted = [ twisted ];
  };

  pyproject = true;

  meta = {
    description = "Python client module for the Music Player Daemon";
    homepage = "https://github.com/Mic92/python-mpd2";
    changelog = "https://github.com/Mic92/python-mpd2/blob/${finalAttrs.src.tag}/doc/changes.rst";
    license = lib.licenses.lgpl3Plus;

    maintainers = with lib.maintainers; [
      mic92
      hexa
    ];
  };
})
