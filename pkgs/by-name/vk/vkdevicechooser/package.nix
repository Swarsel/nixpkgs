{
  lib,
  stdenv,
  fetchFromGitHub,
  jq,
  meson,
  ninja,
  vulkan-headers,
  vulkan-utility-libraries,
  writeText,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vkdevicechooser";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "jiriks74";
    repo = "vkdevicechooser";
    rev = finalAttrs.version;
    hash = "sha256-j4hefarOQ3q0sKkB2g/dO2/4bSYzt4oxmCna0nMAjFk=";
  };

  nativeBuildInputs = [
    meson
    ninja
    jq
  ];

  buildInputs = [
    vulkan-headers
    vulkan-utility-libraries
  ];

  # Include absolute paths to layer libraries in their associated
  # layer definition json files.
  preFixup = ''
    for f in "$out"/share/vulkan/explicit_layer.d/*.json "$out"/share/vulkan/implicit_layer.d/*.json; do
      jq <"$f" >tmp.json ".layer.library_path = \"$out/lib/\" + .layer.library_path"
      mv tmp.json "$f"
    done
  '';

  # Help vulkan-loader find the layer
  setupHook = writeText "setup-hook" ''
    addToSearchPath XDG_DATA_DIRS @out@/share
  '';

  meta = {
    description = "Vulkan layer to force a specific device to be used";
    homepage = "https://github.com/aejsmith/vkdevicechooser";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sigmike ];
    platforms = lib.platforms.unix;
  };
})
