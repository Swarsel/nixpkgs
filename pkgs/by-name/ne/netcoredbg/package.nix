{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  buildDotnetModule,
  clangStdenv,
  cmake,
  dotnetCorePackages,
  netcoredbg,
  testers,
}:
let
  pname = "netcoredbg";
  build = "1062";
  release = "3.1.3";
  version = "${release}-${build}";
  hash = "sha256-Ci4GwHYTCn7BoEG73WsjxyplCCThSF5uVi39lLVZDXY=";

  coreclr-version = "v10.0.1";
  coreclr-src = fetchFromGitHub {
    hash = "sha256-pVcLvew3THRqXgKMVO6jTZyPP06R46KZPMpYdiM3yXU=";
    name = "coreclr";
    owner = "dotnet";
    repo = "runtime";
    rev = coreclr-version;
  };

  dotnet-sdk = dotnetCorePackages.sdk_10_0;

  src = fetchFromGitHub {
    inherit hash;
    owner = "Samsung";
    repo = "netcoredbg";
    rev = version;
    name = pname;
  };

  unmanaged = clangStdenv.mkDerivation {
    inherit pname version;

    nativeBuildInputs = [
      cmake
      dotnet-sdk
    ];

    preConfigure = ''
      export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1

      chmod -R u+w ../coreclr
      cmakeFlagsArray+=(
        "-DCORECLR_DIR=''${NIX_BUILD_TOP}/coreclr/src/coreclr"
        "-DDOTNET_DIR=${dotnet-sdk}/share/dotnet"
        "-DBUILD_MANAGED=0"
      )
    '';

    hardeningDisable = [ "strictoverflow" ];
    sourceRoot = pname;

    srcs = [
      src
      coreclr-src
    ];
  };

  managed = buildDotnetModule {
    inherit
      pname
      version
      src
      dotnet-sdk
      ;

    dotnet-runtime = null;
    # include platform-specific dbgshim binary in nugetDeps
    dotnetFlags = [ "-p:UseDbgShimDependency=true" ];
    executables = [ ];
    nugetDeps = ./deps.json;
    projectFile = "src/managed/ManagedPart.csproj";
    # this passes RID down to dotnet build command
    # and forces dotnet to include binary dependencies in the output (libdbgshim)
    selfContainedBuild = true;
  };
in
stdenv.mkDerivation {
  inherit pname version;
  # managed brings external binaries (libdbgshim.*)
  # include source here so that autoPatchelfHook can do it's job
  src = managed;
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ (lib.getLib stdenv.cc.cc) ];

  installPhase = ''
    mkdir -p $out/share/netcoredbg $out/bin
    cp ${unmanaged}/* $out/share/netcoredbg
    cp ./lib/netcoredbg/* $out/share/netcoredbg
    # darwin won't work unless we link all files
    ln -s $out/share/netcoredbg/* "$out/bin/"
  '';

  passthru = {
    inherit (managed) fetch-deps;

    tests.version = testers.testVersion {
      version = "NET Core debugger ${release}";
      command = "netcoredbg --version";
      package = netcoredbg;
    };
  };

  meta = {
    description = "Managed code debugger with MI interface for CoreCLR";
    homepage = "https://github.com/Samsung/netcoredbg";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      leo60228
      konradmalik
    ];

    platforms = lib.platforms.unix;
    mainProgram = "netcoredbg";
  };
}
