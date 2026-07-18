{
  lib,
  fetchFromGitHub,
  cairo,
  expat,
  libxcb-keysyms,
  libxkbcommon,
  pkg-config,
  python3,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wmfocus";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "svenstaro";
    repo = "wmfocus";
    tag = "v${finalAttrs.version}";
    hash = "sha256-94MgE2j8HaS8IyzHEDtoqTls2A8xD96v2iAFx9XfMcw=";
  };

  nativeBuildInputs = [
    python3
    pkg-config
  ];

  buildInputs = [
    cairo
    expat
    libxkbcommon
    libxcb-keysyms
  ];

  cargoHash = "sha256-tYzJS/ApjGuvNnGuBEVr54AGcEmDhG9HtirZvtmNslY=";
  # For now, this is the only available featureset. This is also why the file is
  # in the i3 folder, even though it might be useful for more than just i3
  # users.
  buildFeatures = [ "i3" ];

  meta = {
    description = "Visually focus windows by label";
    homepage = "https://github.com/svenstaro/wmfocus";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "wmfocus";
  };
})
