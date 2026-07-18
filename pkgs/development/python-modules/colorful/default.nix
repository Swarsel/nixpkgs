{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gitUpdater,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "colorful";
  version = "0.5.8";

  src = fetchFromGitHub {
    owner = "timofurrer";
    repo = "colorful";
    tag = "v${version}";
    hash = "sha256-nztVTfBimRDXwPYk3LNMZKa1ItbgqM2ukgZs8hI8TwE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  format = "setuptools";
  pythonImportsCheck = [ "colorful" ];

  passthru.updateScript = gitUpdater {
    # Skip PEP 440 pre-release tags.
    ignoredVersions = "(a|b|rc)[0-9]+$";
    # Drop the "v" tag prefix before version comparison.
    rev-prefix = "v";
  };

  meta = {
    description = "Library for terminal string styling";
    homepage = "https://github.com/timofurrer/colorful";
    changelog = "https://github.com/timofurrer/colorful/releases/tag/${src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      kalbasit
      l33tname
    ];
  };
}
