{
  buildFHSEnv,
  callPackage,
  makeFontsConf,
  tiling_wm ? false,
}:

let
  mkStudio =
    opts:
    callPackage (import ./common.nix opts) {
      inherit buildFHSEnv;
      inherit tiling_wm;

      fontsConf = makeFontsConf {
        fontDirectories = [ ];
      };
    };
  stableVersion = {
    version = "2025.3.2.6";
    sha256Hash = "sha256-mAJPmDSoE9STOh45u0dIejL4TyR8CIqcGMhiixIFIWc=";
    versionPrefix = "Panda%202";
  };
  canaryVersion = {
    version = "2026.1.2.1";
    sha256Hash = "sha256-UYj+6CSmtxC11HVjPxc+m9r6b5RrXXFOzpDfSkx4mw4=";
    versionPrefix = "canary-Quail%202";
  };
in
{
  canary = mkStudio (
    canaryVersion
    // {
      pname = "android-studio-for-platform-canary";
      channel = "canary";
    }
  );

  # Attributes are named by their corresponding release channels
  stable = mkStudio (
    stableVersion
    // {
      pname = "android-studio-for-platform";
      channel = "stable";
    }
  );
}
