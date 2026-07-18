{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  gfortran,
  matplotlib,
  nix-update-script,
  numpy,
  scipy,
  setuptools,
  sympy,
}:
buildPythonPackage rec {
  pname = "bezier";
  version = "2024.6.20";

  src = fetchFromGitHub {
    owner = "dhermes";
    repo = "bezier";
    tag = version;
    hash = "sha256-TH3x6K5S3uV/K/5e+TXCSiJsyJE0tZ+8ZLc+i/x/fV8=";
  };

  env = {
    BEZIER_IGNORE_VERSION_CHECK = 1;

    BEZIER_INSTALL_PREFIX = stdenv.mkDerivation {
      inherit version src;

      nativeBuildInputs = [
        cmake
        gfortran
      ];

      env = {
        # -fmacro-prefix-map is not a valid option for Fortran.
        # This is true on all platforms, but the flag only seems to be a problem on Darwin.
        NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isDarwin "-Wno-complain-wrong-lang";
        NIX_LDFLAGS = lib.optionalString stdenv.hostPlatform.isLinux "-z,noexecstack";
      };

      name = "bezier-fortran-extension";
      sourceRoot = "${src.name}/src/fortran";
    };

    NIX_CFLAGS_COMPILE = toString [
      "-Wno-error=incompatible-pointer-types"
    ];
  };

  build-system = [ setuptools ];
  dependencies = [ numpy ];

  optional-dependencies = {
    full = [
      matplotlib
      scipy
      sympy
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "bezier" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Helper for Bézier Curves, Triangles, and Higher Order Objects";
    homepage = "https://github.com/dhermes/bezier";
    changelog = "https://bezier.readthedocs.io/en/latest/releases/latest.html";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ WeetHet ];
  };
}
