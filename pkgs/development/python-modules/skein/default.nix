{
  lib,
  buildPythonPackage,
  callPackage,
  cryptography,
  fetchPypi,
  grpcio,
  grpcio-tools,
  hadoop,
  pytestCheckHook,
  pythonOlder,
  pyyaml,
  setuptools_80,
  versioneer,
}:

buildPythonPackage rec {
  pname = "skein";
  version = "0.8.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-nXTqsJNX/LwAglPcPZkmdYPfF+vDLN+nNdZaDFTrHzE=";
  };

  postPatch = ''
    substituteInPlace skein/core.py --replace "'yarn'" "'${hadoop}/bin/yarn'" \
      --replace "else 'java'" "else '${hadoop.jdk}/bin/java'"
    # Remove vendorized versioneer
    rm versioneer.py
  ''
  + lib.optionalString (!pythonOlder "3.12") ''
    substituteInPlace skein/utils.py \
      --replace-fail "distutils" "setuptools._distutils"
  '';

  buildInputs = [ grpcio-tools ];

  preBuild = ''
    # Ensure skein.jar exists skips the maven build in setup.py
    mkdir -p skein/java
    ln -s ${skeinJar} skein/java/skein.jar
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools_80
    versioneer
  ];

  dependencies = [
    cryptography
    grpcio
    pyyaml
  ];

  # These tests require connecting to a YARN cluster. They could be done through NixOS tests later.
  disabledTests = [
    "test_ui"
    "test_tornado"
    "test_kv"
    "test_core"
    "test_cli"
  ];

  # Update this hash if bumping versions
  jarHash = "sha256-x2KH6tnoG7sogtjrJvUaxy0PCEA8q/zneuI969oBOKo=";
  pyproject = true;
  pythonImportsCheck = [ "skein" ];
  skeinJar = callPackage ./skeinjar.nix { inherit pname version jarHash; };

  meta = {
    description = "Tool and library for easily deploying applications on Apache YARN";
    homepage = "https://jcristharif.com/skein";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      alexbiehl
      illustris
    ];

    mainProgram = "skein";
  };
}
