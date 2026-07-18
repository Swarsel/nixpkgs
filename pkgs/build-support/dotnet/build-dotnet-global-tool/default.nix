{
  lib,
  buildDotnetModule,
  dotnet-sdk,
  emptyDirectory,
  fetchNupkg,
}:

fnOrAttrs:

buildDotnetModule (
  finalAttrs:
  (
    {
      pname,
      version,
      # The dotnet runtime to use, dotnet tools need a full SDK to function
      dotnet-runtime ? dotnet-sdk,
      # Executables to wrap into `$out/bin`, same as in `buildDotnetModule`, but with
      # a default of `pname` instead of null, to avoid auto-wrapping everything
      executables ? pname,
      # Additional nuget deps needed by the tool package
      nugetDeps ? (_: [ ]),
      # Hash of the nuget package to install, will be given on first build
      # nugetHash uses SRI hash and should be preferred
      nugetHash ? "",
      # Name of the nuget package to install, if different from pname
      nugetName ? pname,
      nugetSha256 ? "",
      ...
    }@args:
    let
      nupkg = fetchNupkg {
        inherit version;
        pname = nugetName;
        hash = nugetHash;
        installable = true;
        sha256 = nugetSha256;
      };
    in
    args
    // {
      inherit
        pname
        version
        dotnet-runtime
        executables
        ;

      src = emptyDirectory;
      buildInputs = [ nupkg ];

      installPhase = ''
        runHook preInstall

        dotnet tool install --tool-path $out/lib/${pname} ${nugetName} --version ${version}

        # remove files that contain nix store paths to temp nuget sources we made
        find $out -name 'project.assets.json' -delete
        find $out -name '.nupkg.metadata' -delete

        runHook postInstall
      '';

      dontBuild = true;
      dotnetGlobalTool = true;
      useDotnetFromEnv = true;

      passthru = {
        nupkg = nupkg;
        updateScript = ./update.sh;
      }
      // args.passthru or { };
    }
  )
    (if lib.isFunction fnOrAttrs then fnOrAttrs finalAttrs else fnOrAttrs)
)
