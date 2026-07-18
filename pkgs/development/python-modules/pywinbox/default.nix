{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  ewmhlib,
  pyobjc-core,
  pyobjc-framework-Cocoa,
  python-xlib,
  setuptools,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "pywinbox";
  version = "0.7";

  src = fetchFromGitHub {
    owner = "Kalmat";
    repo = "PyWinBox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Z/gedrIFNpQvzRWqGxMEl5MoEIo9znZz/FZLMVl0Eb4=";
  };

  # It's called pyobjc-core instead of pyobjc in nixpkgs.
  postPatch = lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace setup.py \
      --replace-fail 'pyobjc' 'pyobjc-core'
  '';

  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    ewmhlib
    python-xlib
    typing-extensions
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    pyobjc-core
    pyobjc-framework-Cocoa
  ];

  pyproject = true;
  # requires x session (use ewmhlib)
  pythonImportsCheck = [ ];

  meta = {
    description = "Cross-Platform and multi-monitor toolkit to handle rectangular areas and windows box";
    homepage = "https://github.com/Kalmat/PyWinBox";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
