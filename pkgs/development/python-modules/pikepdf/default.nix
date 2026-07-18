{
  lib,
  stdenv,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  clang-tools,
  cmake,
  deprecated,
  hypothesis,
  jbig2dec,
  lxml,
  mupdf-headless,
  nanobind,
  ninja,
  numpy,
  packaging,
  pillow,
  psutil,
  pytest-xdist,
  pytestCheckHook,
  python-dateutil,
  python-xmp-toolkit,
  qpdf,
  replaceVars,
  scikit-build-core,
  withMupdf ? false,
}:

buildPythonPackage rec {
  pname = "pikepdf";
  version = "10.8.0";

  src = fetchFromGitHub {
    owner = "pikepdf";
    repo = "pikepdf";
    tag = "v${version}";
    hash = "sha256-ih5QC6VVl7dGvamp3FRzahnpEDjdO8gGFNVX19Bu8LE=";

    # The content of .git_archival.txt is substituted upon tarball creation,
    # which creates indeterminism if master no longer points to the tag.
    # See https://github.com/jbarlow83/OCRmyPDF/issues/841
    postFetch = ''
      rm "$out/.git_archival.txt"
    '';
  };

  patches = [
    (replaceVars ./paths.patch {
      jbig2dec = lib.getExe' jbig2dec "jbig2dec";

      mutool =
        if withMupdf then
          lib.getExe' mupdf-headless "mutool"
        else
          # replace with non-existing path. This is okay, as this is only
          # called by Jupyter/iPython
          "mutool";
    })
  ];

  buildInputs = [ qpdf ];

  nativeCheckInputs = [
    attrs
    hypothesis
    numpy
    pytest-xdist
    psutil
    pytestCheckHook
    python-dateutil
    python-xmp-toolkit
  ];

  build-system = [
    cmake
    nanobind
    ninja
    scikit-build-core
  ]
  ++ lib.optionals stdenv.cc.isClang [
    # Pick up the `clang-scan-deps` wrapper for CMake; see:
    #
    # * <https://github.com/NixOS/nixpkgs/issues/452260>
    # * <https://github.com/NixOS/nixpkgs/pull/514323>
    clang-tools
  ];

  dependencies = [
    deprecated
    lxml
    packaging
    pillow
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "pikepdf" ];

  meta = {
    description = "Read and write PDFs with Python, powered by qpdf";
    homepage = "https://github.com/pikepdf/pikepdf";
    changelog = "https://github.com/pikepdf/pikepdf/blob/${src.tag}/docs/releasenotes/version${lib.versions.major version}.md";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
