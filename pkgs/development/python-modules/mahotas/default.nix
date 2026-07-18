{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  imread,
  numpy,
  pillow,
  pytestCheckHook,
  pythonAtLeast,
  scipy,
}:

buildPythonPackage rec {
  pname = "mahotas";
  version = "1.4.18";

  src = fetchFromGitHub {
    owner = "luispedro";
    repo = "mahotas";
    tag = "v${version}";
    hash = "sha256-NZOas2fL01QZhi6ebIkW0/jfviwiUl+AqjC7XmC4xH4=";
  };

  propagatedBuildInputs = [
    imread
    numpy
    pillow
    scipy
  ];

  # mahotas/_morph.cpp:864:10: error: no member named 'random_shuffle' in namespace 'std'
  env = lib.optionalAttrs stdenv.cc.isClang { NIX_CFLAGS_COMPILE = "-std=c++14"; };
  nativeCheckInputs = [ pytestCheckHook ];

  # tests must be run in the build directory
  preCheck = ''
    cd build/lib*
  '';

  # re-enable as soon as https://github.com/luispedro/mahotas/issues/97 is fixed
  disabledTests = [
    "test_colors"
    "test_ellipse_axes"
    "test_normalize"
    "test_haralick3d"
  ]
  ++ lib.optionals (pythonAtLeast "3.14") [
    # sys.getrefcount semantics changed in 3.14
    "test_close_holes_simple"
    "test_watershed"
  ];

  format = "setuptools";
  pythonImportsCheck = [ "mahotas" ];

  meta = {
    description = "Computer vision package based on numpy";
    homepage = "https://mahotas.readthedocs.io/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ luispedro ];
    platforms = lib.platforms.unix;

    broken =
      (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64)
      # Failing tests
      || stdenv.hostPlatform.isi686;
  };
}
