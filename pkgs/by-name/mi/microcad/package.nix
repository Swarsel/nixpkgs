{
  lib,
  cmake,
  fetchFromCodeberg,
  ninja,
  pkg-config,
  rustPlatform,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "microcad";
  version = "0.5.0";

  src = fetchFromCodeberg {
    owner = "microcad";
    repo = "microcad";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2164ynL01cLv5/D1FkcZpuBXTHPMjbpeaPPEZpmrSso=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [ wayland ];
  cargoHash = "sha256-OwPAl8LirPQEQ8ytx/+9OnrdbUagLA25mGMw1z/L6V0=";
  __structuredAttrs = true;

  cargoBuildFlags = [
    "-p"
    "microcad-viewer"
    "-p"
    "microcad"
    "-p"
    "microcad-lsp"
  ];

  dontUseCmakeConfigure = true;
  dontUseNinjaBuild = true;
  dontUseNinjaCheck = true;
  dontUseNinjaInstall = true;

  meta = {
    description = "Description language for modeling parameterizable geometric objects";
    homepage = "https://microcad.xyz";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ fred441a ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "microcad";
    donationPage = "https://opencollective.com/microcad/donate";
  };
})
