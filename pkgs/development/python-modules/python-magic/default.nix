{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  file,
  pytestCheckHook,
  replaceVars,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-magic";
  version = "0.4.27";

  src = fetchFromGitHub {
    owner = "ahupp";
    repo = "python-magic";
    tag = finalAttrs.version;
    hash = "sha256-fZ+5xJ3P0EYK+6rQ8VzXv2zckKfEH5VUdISIR6ybIfQ=";
  };

  patches = [
    (replaceVars ./libmagic-path.patch {
      libmagic = "${file}/lib/libmagic${stdenv.hostPlatform.extensions.sharedLibrary}";
    })
    (fetchpatch {
      hash = "sha256-67GpjlGiR4/os/iZ69V+ZziVLpjmid+7t+gQ2aQy9I0=";
      name = "update-test-for-upstream-added-gzip-extensions.patch";
      url = "https://github.com/ahupp/python-magic/commit/4ffcd59113fa26d7c2e9d5897b1eef919fd4b457.patch";
    })

    # Upstream patch to amend test suite for-5.45:
    #   https://github.com/ahupp/python-magic/pull/290
    (fetchpatch {
      hash = "sha256-HRsnO9MGfMD9BkJdC4SrEFQ1OZEaXpwakXFLoaCPK94=";
      name = "file-5.45.patch";
      url = "https://github.com/ahupp/python-magic/commit/3d2405ca80cd39b2a91decd26af81dcf181390a4.patch";
    })

    # Fix test failures due to modified output in file 5.47
    ./fix-parquet-test.patch
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    export LC_ALL=en_US.UTF-8
  '';

  postCheck = ''
    unset LC_ALL
  '';

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Python interface to the libmagic file type identification library";
    homepage = "https://github.com/ahupp/python-magic";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
