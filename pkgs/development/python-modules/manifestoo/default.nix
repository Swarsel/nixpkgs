{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-vcs,
  manifestoo-core,
  nix-update-script,
  pytestCheckHook,
  textual,
  typer,
}:

buildPythonPackage rec {
  pname = "manifestoo";
  version = "1.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-WDfktW8jxh3blr0BH2p6z/Pl6VkQuLqiC5+akYnhaV4=";
  };

  nativeBuildInputs = [ hatch-vcs ];

  propagatedBuildInputs = [
    manifestoo-core
    textual
    typer
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool to reason about Odoo addons manifests";
    homepage = "https://github.com/acsone/manifestoo";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ yajo ];
  };
}
