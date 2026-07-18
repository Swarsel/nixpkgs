{
  lib,
  stdenv,
  buildPythonPackage,
  fetchFromGitiles,
  python,
  setuptools,
  six,
}:

buildPythonPackage {
  pname = "gyp";
  version = "unstable-2024-02-07";

  src = fetchFromGitiles {
    url = "https://chromium.googlesource.com/external/gyp";
    rev = "1615ec326858f8c2bd8f30b3a86ea71830409ce4";
    hash = "sha256-E+JF4uJBRka6vtjxyoMGE4IT5kSrl7Vs6WNkMQ+vNgs=";
  };

  patches = lib.optionals stdenv.hostPlatform.isDarwin [
    ./no-darwin-cflags.patch
    ./no-xcode.patch
  ];

  # Make mac_tool.py executable so that patchShebangs hook processes it. This
  # file is copied and run by builds using gyp on macOS
  preFixup = ''
    chmod +x "$out/${python.sitePackages}/gyp/mac_tool.py"
  '';

  build-system = [ setuptools ];
  dependencies = [ six ];
  pyproject = true;

  pythonImportsCheck = [
    "gyp"
    "gyp.generator"
  ];

  meta = {
    description = "Tool to generate native build files";
    homepage = "https://gyp.gsrc.io";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "gyp";
  };
}
