{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
}:
buildHomeAssistantComponent rec {
  version = "1.0.8";

  src = fetchFromGitHub {
    inherit owner;
    repo = "climate_group";
    tag = version;
    hash = "sha256-HwMHhrmQ+fbdLHQAM+ka/1oNCIBFaLTqOlPMzCEEeQ0=";
  };

  domain = "climate_group";
  owner = "bjrnptrsn";

  meta = {
    description = "Group multiple climate devices to a single entity";
    homepage = "https://github.com/bjrnptrsn/climate_group";
    changelog = "https://github.com/bjrnptrsn/climate_group/blob/${src.rev}/README.md#changelog";
    license = lib.licenses.mit;
    maintainers = builtins.attrValues { inherit (lib.maintainers) jamiemagee; };
  };
}
