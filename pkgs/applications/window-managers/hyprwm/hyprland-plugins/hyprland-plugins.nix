let
  # shared src for upstream hyprland-plugins repo
  # function generating derivations for all plugins in hyprland-plugins
  hyprland-plugins =
    builtins.mapAttrs
      (
        name: description:
        (
          {
            lib,
            fetchFromGitHub,
            cmake,
            mkHyprlandPlugin,
          }:
          let
            version = "0.55.0";

            hyprland-plugins-src = fetchFromGitHub {
              hash = "sha256-WMUJ7tyw/9QbKUyRzLndEQSqX05fQLmFlRdMAmPD7tI=";
              owner = "hyprwm";
              repo = "hyprland-plugins";
              tag = "v${version}";
            };
          in
          mkHyprlandPlugin {
            inherit version;
            src = "${hyprland-plugins-src}/${name}";
            nativeBuildInputs = [ cmake ];
            pluginName = name;

            meta = {
              description = "Hyprland ${description} plugin";
              homepage = "https://github.com/hyprwm/hyprland-plugins";
              license = lib.licenses.bsd3;
              teams = [ lib.teams.hyprland ];
            };
          }
        )
      )
      {
        borders-plus-plus = "multiple borders";
        csgo-vulkan-fix = "CS:GO/CS2 Vulkan fix";
        hyprbars = "window title";
        hyprfocus = "flashfocus";
      };
in
hyprland-plugins
