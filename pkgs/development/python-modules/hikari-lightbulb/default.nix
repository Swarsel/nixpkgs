{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  croniter,
  flit-core,
  hikari,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "hikari-lightbulb";
  version = "3.2.3";

  src = fetchFromGitHub {
    owner = "tandemdude";
    repo = "hikari-lightbulb";
    tag = version;
    hash = "sha256-u8RrvHaawCIwVN9n7m3Ti29tPr66GNkwpKf/oo5eMUQ=";
  };

  build-system = [ flit-core ];

  dependencies = [
    hikari
    typing-extensions
  ];

  optional-dependencies = {
    crontrigger = [ croniter ];
  };

  pyproject = true;
  pythonImportsCheck = [ "lightbulb" ];

  meta = {
    description = "Command handler for Hikari, the Python Discord API wrapper library";

    longDescription = ''
      Lightbulb is designed to be an easy to use command handler library that integrates with the Discord API wrapper library for Python, Hikari.

      This library aims to make it simple for you to make your own Discord bots and provide all the utilities and functions you need to help make this job easier.
    '';

    homepage = "https://hikari-lightbulb.readthedocs.io/en/latest/";
    # https://github.com/tandemdude/hikari-lightbulb/blob/d87df463488d1c1d947144ac0bafa4304e12ddfd/setup.py#L68
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ tomodachi94 ];
    broken = true; # missing linkd and confspec dependencies
  };
}
