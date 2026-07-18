{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cffi,
  cmake,
  mozjpeg,
  nix-update-script,
  pytestCheckHook,
  python3Packages,
  setuptools,
}:
buildPythonPackage rec {
  pname = "mozjpeg_lossless_optimization";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "wanadev";
    repo = "mozjpeg-lossless-optimization";
    # https://github.com/NixOS/nixpkgs/issues/26302
    tag = "v${version}";
    hash = "sha256-0w0e7QbYi3W6MahY8fnI+dYkQHqheOXQn3mJN/UfHlk=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ mozjpeg ];
  propagatedBuildInputs = [ cffi ];
  nativeCheckInputs = [ pytestCheckHook ];

  # https://github.com/NixOS/nixpkgs/issues/255262
  preCheck = ''
    rm -r mozjpeg_lossless_optimization
  '';

  build-system = [ setuptools ];
  # This package needs cmake, but it is not the default builder
  dontUseCmakeConfigure = true;
  pyproject = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Python library to optimize JPEGs losslessly using MozJPEG";
    homepage = "https://github.com/wanadev/mozjpeg-lossless-optimization";
    changelog = "https://github.com/wanadev/mozjpeg-lossless-optimization/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.adfaure ];
  };
}
