{
  lib,
  aiodns,
  aiohttp,
  buildPythonPackage,
  cargo,
  cryptography,
  defusedxml,
  emoji,
  fetchFromCodeberg,
  gnupg,
  pyasn1,
  pyasn1-modules,
  pytestCheckHook,
  replaceVars,
  rustPlatform,
  rustc,
  setuptools,
  setuptools-rust,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "slixmpp";
  version = "1.17.0";

  src = fetchFromCodeberg {
    owner = "poezio";
    repo = "slixmpp";
    tag = "slix-${finalAttrs.version}";
    hash = "sha256-1jCKaUwWuIxTQGA0WkQMpB3xWW8XEAfAlyrqoTFIhVY=";
  };

  patches = [
    (replaceVars ./hardcode-gnupg-path.patch {
      inherit gnupg;
    })
  ];

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    cargo
    rustc
    rustPlatform.cargoSetupHook
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  build-system = [
    setuptools
    setuptools-rust
    setuptools-scm
  ];

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = ./Cargo.lock;
  };

  dependencies = [
    aiodns
    pyasn1
    pyasn1-modules
  ];

  disabledTestPaths = [
    # Exclude integration tests
    "itests/"
    # Exclude live tests
    "tests/live_test.py"
  ];

  optional-dependencies = {
    safer-xml-parsing = [ defusedxml ];
    xep-0363 = [ aiohttp ];
    xep-0444-compliance = [ emoji ];
    xep-0454 = [ cryptography ];
  };

  pyproject = true;
  pythonImportsCheck = [ "slixmpp" ];

  meta = {
    description = "Python library for XMPP";
    homepage = "https://slixmpp.readthedocs.io/";
    changelog = "https://codeberg.org/poezio/slixmpp/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      fab
      haansn08
    ];
  };
})
