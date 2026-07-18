{
  lib,
  fetchFromGitHub,
  _experimental-update-script-combinators,
  buildDotnetModule,
  callPackage,
  dotnetCorePackages,
  ffmpeg,
  gitUpdater,
  glfw,
  gtk3,
  libglvnd,
  libogg,
  libvorbis,
  openal,
  portaudio,
  rtmidi,
  stdenvNoCC,
  wrapGAppsHook3,
}:

let
  csprojName =
    if stdenvNoCC.hostPlatform.isLinux then
      "FamiStudio.Linux"
    else if stdenvNoCC.hostPlatform.isDarwin then
      "FamiStudio.Mac"
    else
      throw "Don't know how to build FamiStudio for ${stdenvNoCC.hostPlatform.system}";
in
buildDotnetModule (finalAttrs: {
  pname = "famistudio";
  version = "4.5.1";

  src = fetchFromGitHub {
    owner = "BleuBleu";
    repo = "FamiStudio";
    tag = finalAttrs.version;
    hash = "sha256-VbE9wdO//rAEtxHtol/4hHd9tw4berdncMjIXZvOIYE=";
  };

  postPatch =
    let
      libname = library: "${library}${stdenvNoCC.hostPlatform.extensions.sharedLibrary}";
      buildNativeWrapper =
        args:
        callPackage ./build-native-wrapper.nix (
          args
          // {
            inherit (finalAttrs) version src;
            sourceRoot = "${finalAttrs.src.name}/ThirdParty/${args.depname}";
          }
        );
      nativeWrapperToReplaceFormat =
        args:
        let
          libPrefix = lib.optionalString stdenvNoCC.hostPlatform.isLinux "lib";
        in
        {
          expectedName = "${libPrefix}${args.depname}";
          ourName = "${libPrefix}${args.depname}";
          package = buildNativeWrapper args;
        };
      librariesToReplace = [
        # Unmodified native libraries that we can fully substitute
        {
          expectedName = "libglfw";
          ourName = "libglfw";
          package = glfw;
        }
        {
          expectedName = "librtmidi";
          ourName = "librtmidi";
          package = rtmidi;
        }
      ]
      ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [
        {
          expectedName = "libopenal32";
          ourName = "libopenal";
          package = openal;
        }
      ]
      ++ lib.optionals stdenvNoCC.hostPlatform.isDarwin [
        {
          expectedName = "libportaudio.2";
          ourName = "libportaudio.2";
          package = portaudio;
        }
      ]
      ++ [
        # Native libraries, with extra code for the C# wrapping
        (nativeWrapperToReplaceFormat { depname = "GifDec"; })
        (nativeWrapperToReplaceFormat { depname = "NesSndEmu"; })
        (nativeWrapperToReplaceFormat {
          depname = "NotSoFatso";

          extraPostPatch = ''
            # C++17 does not allow register storage class specifier
            substituteInPlace build.sh \
              --replace-fail "$CXX" "$CXX -std=c++14"
          '';
        })
        (nativeWrapperToReplaceFormat { depname = "ShineMp3"; })
        (nativeWrapperToReplaceFormat { depname = "Stb"; })
        (nativeWrapperToReplaceFormat {
          buildInputs = [
            libogg
            libvorbis
          ];

          depname = "Vorbis";
        })
      ];
      libraryReplaceArgs = lib.strings.concatMapStringsSep " " (
        library:
        "--replace-fail '${libname library.expectedName}' '${lib.getLib library.package}/lib/${libname library.ourName}'"
      ) librariesToReplace;
    in
    ''
      # Don't use any prebuilt libraries
      rm FamiStudio/*.{dll,dylib,so*}

      # Replace copying of vendored prebuilt native libraries with copying of our native libraries
      substituteInPlace ${finalAttrs.projectFile} ${libraryReplaceArgs}

      # Un-hardcode target platform if set
      sed -i -e '/PlatformTarget/d' ${finalAttrs.projectFile}

      # Don't require a special name to be preserved, our OpenAL isn't 32-bit
      substituteInPlace FamiStudio/Source/AudioStreams/OpenALStream.cs \
        --replace-fail 'libopenal32' 'libopenal'
    '';

  nativeBuildInputs = lib.optionals stdenvNoCC.hostPlatform.isLinux [
    wrapGAppsHook3
  ];

  postInstall = ''
    mkdir -p $out/share/famistudio
    for datdir in Setup/Demo\ {Instruments,Songs}; do
      cp -R "$datdir" $out/share/famistudio/
    done
  '';

  postFixup =
    # Need GSettings schemas
    lib.optionalString stdenvNoCC.hostPlatform.isLinux ''
      makeWrapperArgs+=(
        "''${gappsWrapperArgs[@]}"
      )
    ''
    # FFMpeg looked up from PATH
    + ''
      wrapProgram $out/bin/FamiStudio \
        --prefix PATH : ${lib.makeBinPath [ ffmpeg ]} \
        ''${makeWrapperArgs[@]}
    '';

  dontWrapGApps = true;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  executables = [ "FamiStudio" ];
  nugetDeps = ./deps.json;
  projectFile = "FamiStudio/${csprojName}.csproj";

  runtimeDeps = lib.optionals stdenvNoCC.hostPlatform.isLinux [
    gtk3
    libglvnd
  ];

  passthru.updateScript = _experimental-update-script-combinators.sequence [
    (gitUpdater { }).command
    (finalAttrs.passthru.fetch-deps)
  ];

  meta = {
    description = "NES Music Editor";

    longDescription = ''
      FamiStudio is very simple music editor for the Nintendo Entertainment System
      or Famicom. It is targeted at both chiptune artists and NES homebrewers.
    '';

    homepage = "https://famistudio.org/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      OPNA2608
    ];

    platforms = lib.platforms.unix;
    mainProgram = "FamiStudio";
  };
})
