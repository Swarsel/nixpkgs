{
  lib,
  buildPythonPackage,
  cffi,
  fetchPypi,
  libxcb,
  pytestCheckHook,
  setuptools,
  xeyes,
  xvfb,
}:

buildPythonPackage rec {
  pname = "xcffib";
  version = "1.12.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Q0Ut5QnBJk1bzqS8Alyhv2gnLSQO8m0zQLRuEfY9PUo=";
  };

  postPatch = ''
    # Hardcode cairo library path
    substituteInPlace xcffib/__init__.py \
      --replace-fail "lib = ffi.dlopen(soname)" "lib = ffi.dlopen('${lib.getLib libxcb}/lib/' + soname)"
  '';

  propagatedBuildInputs = [ cffi ];

  nativeCheckInputs = [
    pytestCheckHook
    xeyes
    xvfb
  ];

  preCheck = ''
    # import from $out
    rm -r xcffib
  '';

  # Tests use xvfb
  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];
  propagatedNativeBuildInputs = [ cffi ];
  pyproject = true;
  pythonImportsCheck = [ "xcffib" ];

  meta = {
    description = "Drop in replacement for xpyb, an XCB python binding";
    homepage = "https://github.com/tych0/xcffib";
    changelog = "https://github.com/tych0/xcffib/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ kamilchm ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin ++ lib.platforms.windows;
  };
}
