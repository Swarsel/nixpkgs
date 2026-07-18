{
  lib,
  fetchFromGitHub,
  addBinToPathHook,
  cacert,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "gallia";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "Fraunhofer-AISEC";
    repo = "gallia";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vM19d5alD9xhFgR4are0pDhJyNiUY320nJmjEF2BvxM=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.9.11,<0.10.0" "uv_build"
  '';

  env.SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  nativeCheckInputs =
    with python3.pkgs;
    [
      pytestCheckHook
      pytest-asyncio
    ]
    ++ [
      addBinToPathHook
    ];

  build-system = with python3.pkgs; [ uv-build ];

  dependencies = with python3.pkgs; [
    aiosqlite
    argcomplete
    boltons
    construct
    platformdirs
    pydantic
    tabulate
    wcwidth
    zstandard
  ];

  pyproject = true;
  pythonImportsCheck = [ "gallia" ];
  pythonRelaxDeps = [ "pydantic" ];

  meta = {
    description = "Extendable Pentesting Framework for the Automotive Domain";
    homepage = "https://github.com/Fraunhofer-AISEC/gallia";
    changelog = "https://github.com/Fraunhofer-AISEC/gallia/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      fab
      rumpelsepp
    ];

    platforms = lib.platforms.linux;
  };
})
