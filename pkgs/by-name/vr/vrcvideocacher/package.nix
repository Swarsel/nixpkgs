{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  copyDesktopItems,
  deno,
  dotnetCorePackages,
  ffmpeg,
  icoutils,
  makeDesktopItem,
  nix-update-script,
  openxr-loader,
  yt-dlp,
}:
buildDotnetModule (finalAttrs: {
  pname = "vrcvideocacher";
  version = "2026.5.2";

  src = fetchFromGitHub {
    owner = "EllyVR";
    repo = "VRCVideoCacher";
    tag = finalAttrs.version;
    hash = "sha256-rabx93WBYnVPAQHndNkz+lN45S8lWufoMQ6s50gW+rY=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    copyDesktopItems
    icoutils
  ];

  postInstall = ''
    icotool --icon -x $src/VRCVideoCacher/Assets/icon.ico

    for i in 16 32 48 64 128 256; do
      size=''${i}x''${i}
      install -Dm444 *_''${size}x*.png $out/share/icons/hicolor/$size/apps/vrcvideocacher.png
    done
  '';

  __structuredAttrs = true;

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Utility" ];
      comment = finalAttrs.meta.description;
      desktopName = "VRCVideoCacher";
      exec = finalAttrs.meta.mainProgram;
      icon = "vrcvideocacher";
      name = "vrcvideocacher";
    })
  ];

  dotnet-runtime = dotnetCorePackages.runtime_10_0;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  executables = [ "VRCVideoCacher" ];

  makeWrapperArgs = [
    "--add-flags"
    "--global-path"

    "--prefix"
    "LD_LIBRARY_PATH"
    ":"
    (lib.makeLibraryPath [
      openxr-loader
    ])

    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [
      ffmpeg
      yt-dlp
      deno
    ])
  ];

  nugetDeps = ./deps.json;
  projectFile = "VRCVideoCacher/VRCVideoCacher.csproj";
  selfContainedBuild = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cache VRChat videos locally and fix YouTube videos that fail to load";
    homepage = "https://github.com/EllyVR/VRCVideoCacher";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ coolGi ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "VRCVideoCacher";
  };
})
