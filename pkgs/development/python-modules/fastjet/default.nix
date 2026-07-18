{
  lib,
  awkward,
  buildPythonPackage,
  fetchPypi,
  numpy,
  pkgs,
  pybind11,
  pytestCheckHook,
  python,
  setuptools,
  setuptools-scm,
  vector,
}:

let
  fastjet =
    (pkgs.fastjet.override {
      inherit python;
      withPython = true;
    }).overrideAttrs
      (prev: {
        postInstall = (prev.postInstall or "") + ''
          mv "$out/${python.sitePackages}/"{fastjet.py,_fastjet_swig.py}
        '';
      });
  fastjet-contrib = pkgs.fastjet-contrib.override {
    inherit fastjet;
  };
in

buildPythonPackage rec {
  pname = "fastjet";
  version = "3.5.1.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-dDvlFBZrTWhpNhngKuAvu9zpbcLWvz7IpRQsmctvaW0=";
    pname = "fastjet";
  };

  # unvendor fastjet/fastjet-contrib
  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail 'cmdclass={"build_ext": FastJetBuild, "install": FastJetInstall},' "" \
      --replace-fail 'str(OUTPUT / "include")' "" \
      --replace-fail 'str(OUTPUT / "lib")' ""
    for file in src/fastjet/*.py; do
      substituteInPlace "$file" \
        --replace-warn "fastjet._swig" "_fastjet_swig"
    done
    sed -i src/fastjet/_pyjet.py -e '1iimport _fastjet_swig'
  '';

  strictDeps = true;

  buildInputs = [
    pybind11
    fastjet-contrib
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    awkward
    fastjet
    numpy
    vector
  ];

  pyproject = true;

  meta = {
    description = "Jet-finding in the Scikit-HEP ecosystem";
    homepage = "https://github.com/scikit-hep/fastjet";
    changelog = "https://github.com/scikit-hep/fastjet/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ veprbl ];
  };
}
