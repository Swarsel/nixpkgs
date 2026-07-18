{
  fetchFromGitHub,
  cava,
  meson,
  ninja,
  nix-update-script,
}:
cava.overrideAttrs (old: rec {
  pname = "libcava";
  # fork may not be updated when we update upstream
  version = "0.10.7";

  src = fetchFromGitHub {
    owner = "LukashonakV";
    repo = "cava";
    tag = version;
    hash = "sha256-zkyj1vBzHtoypX4Bxdh1Vmwh967DKKxN751v79hzmgQ=";
  };

  nativeBuildInputs = old.nativeBuildInputs ++ [
    meson
    ninja
  ];

  dontVersionCheck = true; # no `bin/cava`
  # Automatically enable all optional dependencies
  # (instead, Nix sets this option to "enabled" which
  # forces all optional dependencies to be required
  # or disabled individually)
  mesonAutoFeatures = "auto";
  passthru.updateScript = nix-update-script { };

  meta = old.meta // {
    description = "Fork of CAVA to build it as a shared library";
    homepage = "https://github.com/LukashonakV/cava";
  };
})
