{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  nix-update-script,
  plover,
  setuptools,
  wheel,
}:

buildPythonPackage (finalAttrs: {
  pname = "plover-combo";
  version = "2.0.0-unstable-2025-09-11";

  src = fetchFromGitHub {
    owner = "opensteno";
    repo = "plover_combo";
    rev = "82e4b498bd0d7878af4e60fd26453362f41132a8";
    hash = "sha256-GCRfoYu/LZDIGs/9RXDCcTEke3PHMifBEuDUrGH/Juc=";
  };

  __structuredAttrs = true;

  build-system = [
    plover
    setuptools
    wheel
  ];

  dependency = [
    plover
  ]
  ++ plover.optional-dependencies.gui-qt;

  pyproject = true;

  pythonImportsCheck = [
    "plover_combo"

    # Modules providing Plover entry points
    "plover_combo.combo_ui"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Combo Mode for Plover";
    homepage = "https://github.com/opensteno/plover_combo";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      ShamrockLee
    ];
  };
})
