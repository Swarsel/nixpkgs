{
  lib,
  fetchPypi,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "cmake-format";
  version = "0.6.13";

  src = fetchPypi {
    inherit (finalAttrs) version;
    sha256 = "0kmggnfbv6bba75l3zfzqwk0swi90brjka307m2kcz2w35kr8jvn";
    format = "wheel";
    pname = "cmakelang";
  };

  doCheck = false;

  dependencies = with python3Packages; [
    autopep8
    flake8
    jinja2
    pylint
    pyyaml
    six
  ];

  # The source distribution does not build because of missing files.
  format = "wheel";

  meta = {
    description = "Source code formatter for cmake listfiles";
    homepage = "https://github.com/cheshirekow/cmake_format";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ tobim ];
    mainProgram = "cmake-format";
  };
})
