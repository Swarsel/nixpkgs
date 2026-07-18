{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pkgs,
  poetry-core,
  pytestCheckHook,
  setuptools,
}:

let
  inherit (pkgs) quickjs srcOnly;
in

buildPythonPackage rec {
  pname = "quickjs";
  version = "1.19.4";

  src = fetchFromGitHub {
    owner = "PetterS";
    repo = "quickjs";
    tag = version;
    hash = "sha256-nLloXJWOuaK/enZfwXJI94IcsAMYrkBtG4i3gmxuhfw=";
  };

  patches = [ ./0001-Update-for-QuickJS-2025-04-26-release.patch ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail poetry>=1.5.0 poetry \
      --replace-fail poetry poetry-core \
      --replace-fail 'version = "0"' 'version = "${version}"'
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    poetry-core
    setuptools
  ];

  # Upstream uses Git submodules; let's de-vendor and use Nix, so that we gain security fixes like
  # https://github.com/NixOS/nixpkgs/pull/407469
  prePatch = ''
    rmdir upstream-quickjs
    ln -s ${srcOnly quickjs} upstream-quickjs
  '';

  pyproject = true;
  pythonImportsCheck = [ "quickjs" ];

  meta = {
    description = "Python wrapper around the quickjs C library";
    homepage = "https://github.com/PetterS/quickjs";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ philiptaron ];
  };
}
