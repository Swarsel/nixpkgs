{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  psutil,
  setuptools,
}:

buildPythonPackage rec {
  pname = "command-runner";
  version = "1.7.5";

  src = fetchFromGitHub {
    owner = "netinvent";
    repo = "command_runner";
    tag = "v${version}";
    hash = "sha256-jGYIz+c6wt137b8kG1QVVAvBAaJQAzNnZyKVeKHIk5c=";
  };

  # Tests are execute ping
  # ping: socket: Operation not permitted
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ psutil ];
  pyproject = true;
  pythonImportsCheck = [ "command_runner" ];

  meta = {
    description = ''
      Platform agnostic command execution, timed background jobs with live
      stdout/stderr output capture, and UAC/sudo elevation
    '';

    homepage = "https://github.com/netinvent/command_runner";
    changelog = "https://github.com/netinvent/command_runner/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
  };
}
