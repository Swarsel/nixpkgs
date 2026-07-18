{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  matplotlib,
  pygments,
  pytestCheckHook,
  rich,
}:

buildPythonPackage (finalAttrs: {
  pname = "catppuccin";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "catppuccin";
    repo = "python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wumJ8kpr+C2pdw8jYf+IqYTdSB6Iy37yZqPKycYmOSs=";
  };

  patches = [
    # https://github.com/catppuccin/python/pull/130
    ./matplotlib-3.11.patch
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  build-system = [ hatchling ];

  optional-dependencies = {
    matplotlib = [ matplotlib ];
    pygments = [ pygments ];
    rich = [ rich ];
  };

  pyproject = true;
  pythonImportsCheck = [ "catppuccin" ];

  meta = {
    description = "Soothing pastel theme for Python";
    homepage = "https://github.com/catppuccin/python";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      fufexan
      tomasajt
    ];
  };
})
