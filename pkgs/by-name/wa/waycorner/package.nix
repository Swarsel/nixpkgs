{
  lib,
  fetchFromGitHub,
  gitUpdater,
  makeWrapper,
  pkg-config,
  rustPlatform,
  wayland,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "waycorner";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "AndreasBackx";
    repo = "waycorner";
    tag = finalAttrs.version;
    hash = "sha256-b8juIhJ3kh+NJc8RUVVoatqjWISSW0ir/vk2Dz/428Y=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  cargoHash = "sha256-sMsqH4+Vhqiu5GKPs9FQMQjjc2H6ZGZosd4Qj3DlBqA=";

  postFixup = ''
    # the program looks for libwayland-client.so at runtime
    wrapProgram $out/bin/waycorner \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ wayland ]}
  '';

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Hot corners for Wayland";
    homepage = "https://github.com/AndreasBackx/waycorner";
    changelog = "https://github.com/AndreasBackx/waycorner/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ NotAShelf ];
    platforms = lib.platforms.linux;
    mainProgram = "waycorner";
  };
})
