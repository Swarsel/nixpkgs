{
  lib,
  makeWrapper,
  symlinkJoin,
  writeText,
}:

helm:

let
  wrapper =
    {
      extraMakeWrapperArgs ? "",
      plugins ? [ ],
    }:
    let

      initialMakeWrapperArgs = [
      ];

      pluginsDir = symlinkJoin {
        name = "helm-plugins";
        paths = plugins;
      };
    in
    symlinkJoin {
      nativeBuildInputs = [ makeWrapper ];

      # Remove the symlinks created by symlinkJoin which we need to perform
      # extra actions upon
      postBuild = ''
        wrapProgram "$out/bin/helm" \
          "--set" "HELM_PLUGINS" "${pluginsDir}" ${extraMakeWrapperArgs}
      '';

      name = "helm-${lib.getVersion helm}";

      paths = [
        helm
        pluginsDir
      ];

      preferLocalBuild = true;

      passthru = {
        inherit pluginsDir;
        unwrapped = helm;
      };

      meta = helm.meta // {
        # To prevent builds on hydra
        hydraPlatforms = [ ];
        # prefer wrapper over the package
        priority = (helm.meta.priority or lib.meta.defaultPriority) - 1;
      };
    };
in
lib.makeOverridable wrapper
