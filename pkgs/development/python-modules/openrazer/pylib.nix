{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dbus-python,
  numpy,
  openrazer-daemon,
  setuptools,
}:

let
  common = import ./common.nix { inherit lib fetchFromGitHub; };
in
buildPythonPackage (
  common
  // {
    pname = "openrazer";
    nativeBuildInputs = [ setuptools ];
    # no tests run
    doCheck = false;

    dependencies = [
      dbus-python
      numpy
      openrazer-daemon
    ];

    sourceRoot = "${common.src.name}/pylib";

    meta = common.meta // {
      description = "Entirely open source Python library that allows you to manage your Razer peripherals on GNU/Linux";
    };
  }
)
