{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  copyDesktopItems,
  glfw,
  gtk3,
  libxxf86vm,
  llvmPackages,
  makeDesktopItem,
  pkg-config,
  wrapGAppsHook3,
}:

buildGoModule (finalAttrs: {
  pname = "picocrypt";
  version = "1.49";

  src = fetchFromGitHub {
    owner = "Picocrypt";
    repo = "Picocrypt";
    tag = finalAttrs.version;
    hash = "sha256-B10PP/V8xvYbA6rQHWdav/KtQKecNUmwvj9qMYqml8E=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    pkg-config
    wrapGAppsHook3
  ]
  # TODO: Remove once #536365 reaches this branch
  ++ lib.optional stdenv.hostPlatform.isDarwin llvmPackages.lld;

  buildInputs =
    # Depends on a vendored, patched GLFW.
    glfw.buildInputs or [ ]
    ++ glfw.propagatedBuildInputs or [ ]
    ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
      gtk3
      libxxf86vm
    ];

  vendorHash = "sha256-0fEy/YuZa7dENfL3y+NN4SLWYwOLmXqHHJEiU37AkX4=";

  env = {
    CGO_ENABLED = 1;
  }
  // lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    # TODO: Remove once #536365 reaches this branch
    NIX_CFLAGS_LINK = "-fuse-ld=lld";
  };

  postInstall = ''
    mv $out/bin/Picocrypt $out/bin/picocrypt-gui
    install -Dm644 $src/images/key.svg $out/share/icons/hicolor/scalable/apps/picocrypt.svg
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Utility" ];
      comment = finalAttrs.meta.description;
      desktopName = "Picocrypt";
      exec = "picocrypt-gui";
      icon = "picocrypt";
      name = "Picocrypt";
    })
  ];

  ldflags = [
    "-s"
    "-w"
  ];

  sourceRoot = "${finalAttrs.src.name}/src";

  meta = {
    description = "Very small, very simple, yet very secure encryption tool, written in Go";
    homepage = "https://github.com/Picocrypt/Picocrypt";
    changelog = "https://github.com/Picocrypt/Picocrypt/blob/${finalAttrs.version}/Changelog.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ryand56 ];
    mainProgram = "picocrypt-gui";
  };
})
