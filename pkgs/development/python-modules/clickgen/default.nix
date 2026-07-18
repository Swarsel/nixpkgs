{
  lib,
  stdenv,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  numpy,
  pillow,
  pytestCheckHook,
  python,
  pyyaml,
  setuptools,
  toml,
}:

buildPythonPackage (finalAttrs: {
  pname = "clickgen";
  version = "2.2.5";

  src = fetchFromGitHub {
    owner = "ful1e5";
    repo = "clickgen";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yFEkE1VyeHBuebpsumc6CTvv2kpAw7XAWlyUlXibqz0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  postInstall = ''
    # Copying scripts directory needed by clickgen script at $out/bin/
    cp -R src/clickgen/scripts $out/${python.sitePackages}/clickgen/scripts
  '';

  build-system = [ setuptools ];

  dependencies = [
    attrs
    numpy
    pillow
    pyyaml
    toml
  ];

  pyproject = true;
  pythonImportsCheck = [ "clickgen" ];

  meta = {
    description = "Hassle-free cursor building toolbox";

    longDescription = ''
      clickgen is API for building X11 and Windows Cursors from
      .png files. clickgen is using anicursorgen and xcursorgen under the hood.
    '';

    homepage = "https://github.com/ful1e5/clickgen";
    license = lib.licenses.mit;
    maintainers = [ ];
    # fails with:
    # ld: unknown option: -zdefs
    broken = stdenv.hostPlatform.isDarwin;
  };
})
