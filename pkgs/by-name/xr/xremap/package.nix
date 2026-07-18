{
  lib,
  fetchFromGitHub,
  pkg-config,
  rustPlatform,
  xremap,
  withVariant ? "wlroots",
}:
let
  variants = {
    cosmic = {
      descriptionSuffix = "Cosmic";
      features = [ "cosmic" ];
      suffix = "-cosmic";
    };

    gnome = {
      descriptionSuffix = "Gnome";
      features = [ "gnome" ];
      suffix = "-gnome";
    };

    hyprland = {
      descriptionSuffix = "Hyprland";
      features = [ "hypr" ];
      suffix = "-hyprland";
    };

    kde = {
      descriptionSuffix = "KDE";
      features = [ "kde" ];
      suffix = "-kde";
    };

    niri = {
      descriptionSuffix = "Niri";
      features = [ "niri" ];
      suffix = "-niri";
    };

    socket = {
      descriptionSuffix = "Socket client";
      features = [ "socket" ];
      suffix = "";
    };

    wlroots = {
      descriptionSuffix = "wlroots";
      features = [ "wlroots" ];
      suffix = "-wlroots";
    };

    x11 = {
      descriptionSuffix = "X11";
      features = [ "x11" ];
    };
  };

  variant = variants.${withVariant} or null;
in
assert (
  lib.assertMsg (variant != null)
    "Unknown variant ${withVariant}: expected one of ${lib.concatStringsSep ", " (lib.attrNames variants)}"
);
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "xremap${variant.suffix or ""}";
  version = "0.15.9";

  src = fetchFromGitHub {
    owner = "xremap";
    repo = "xremap";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BgRp0y5bkmMwRCdIKHrXIbv6Kl7Hn9IphburN7i7sE8=";
  };

  nativeBuildInputs = [ pkg-config ];
  cargoHash = "sha256-sfdUs9WLtwGSZHraDz0YEzGX1o9uQaYi1JiRnUvjyVs=";
  buildFeatures = variant.features;
  buildNoDefaultFeatures = true;
  passthru = lib.mapAttrs (name: lib.const (xremap.override { withVariant = name; })) variants;

  meta = {
    description = "Key remapper for X11 and Wayland (${variant.descriptionSuffix} support)";
    homepage = "https://github.com/xremap/xremap";
    changelog = "https://github.com/xremap/xremap/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.hakan-demirli ];
    platforms = lib.platforms.linux;
    mainProgram = "xremap";
  };
})
