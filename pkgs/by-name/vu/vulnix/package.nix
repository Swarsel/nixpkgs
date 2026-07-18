{
  lib,
  fetchFromGitHub,
  nix,
  python3Packages,
  ronn,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "vulnix";
  version = "1.12.4";

  src = fetchFromGitHub {
    owner = "nix-community";
    repo = "vulnix";
    tag = finalAttrs.version;
    hash = "sha256-4aaYSOBuZHW/FZ8c+REjwr6X2S4KsP9Czk5jGTQfqDI=";
  };

  outputs = [
    "out"
    "doc"
    "man"
  ];

  nativeBuildInputs = [ ronn ];

  propagatedBuildInputs = [
    nix
  ]
  ++ (with python3Packages; [
    click
    colorama
    pyyaml
    requests
    toml
    zodb
  ]);

  postBuild = "make -C doc";

  nativeCheckInputs = with python3Packages; [
    freezegun
    pytestCheckHook
    pytest-cov-stub
  ];

  postInstall = ''
    install -D -t $doc/share/doc/vulnix README.rst CHANGES.rst
    gzip $doc/share/doc/vulnix/*.rst
    install -D -t $man/share/man/man1 doc/vulnix.1
    install -D -t $man/share/man/man5 doc/vulnix-whitelist.5
  '';

  __darwinAllowLocalNetworking = true;

  build-system = with python3Packages; [
    setuptools
  ];

  dontStrip = true;
  enabledTestPaths = [ "src/vulnix" ];
  pyproject = true;

  meta = {
    description = "NixOS vulnerability scanner";
    homepage = "https://github.com/nix-community/vulnix";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ henrirosten ];
    mainProgram = "vulnix";
  };
})
