{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  darwin,
  # TODO: Clean up on `staging`.
  llvmPackages,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyobjc-core";
  version = "11.1";

  src = fetchFromGitHub {
    owner = "ronaldoussoren";
    repo = "pyobjc";
    tag = "v${version}";
    hash = "sha256-2qPGJ/1hXf3k8AqVLr02fVIM9ziVG9NMrm3hN1de1Us=";
  };

  nativeBuildInputs = [
    darwin.DarwinTools # sw_vers

    # TODO: Clean up on `staging`.
    llvmPackages.lld
  ];

  buildInputs = [
    darwin.libffi
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-I${darwin.libffi.dev}/include"
    "-Wno-error=cast-function-type-mismatch"
    "-Wno-error=unused-command-line-argument"
  ];

  # TODO: Clean up on `staging`.
  env.NIX_CFLAGS_LINK = "-fuse-ld=lld";
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "objc" ];
  sourceRoot = "${src.name}/pyobjc-core";

  meta = {
    description = "Python <-> Objective-C bridge";
    homepage = "https://github.com/ronaldoussoren/pyobjc/tree/main/pyobjc-core";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ samuela ];
    platforms = lib.platforms.darwin;
  };
}
