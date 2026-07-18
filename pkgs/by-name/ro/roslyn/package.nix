{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  mono,
  unzip,
}:

buildDotnetModule rec {
  pname = "roslyn";
  version = "4.14.0";

  src = fetchFromGitHub {
    owner = "dotnet";
    repo = "roslyn";
    tag = "NET-SDK-9.0.304";
    hash = "sha256-mj14bpJks7CcrbcEScPkl3feKUycGLiBYXs908GnGhg=";
  };

  postPatch = ''
    substituteInPlace global.json \
      --replace-fail "patch" "latestFeature"
  '';

  nativeBuildInputs = [ unzip ];

  buildPhase = ''
    runHook preBuild

    dotnet msbuild -v:m -t:pack \
      -p:Configuration=Release \
      -p:RepositoryUrl="${meta.homepage}" \
      -p:RepositoryCommit="v${version}" \
      $dotnetFlags \
      $dotnetProjectFiles

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    pkg="$out/lib/dotnet/microsoft.net.compilers.toolset/${version}"
    mkdir -p "$out/bin" "$pkg"

    unzip -q artifacts/packages/Release/Shipping/Microsoft.Net.Compilers.Toolset.Framework.${version}-dev.nupkg \
      -d "$pkg"
    # nupkg has 0 permissions for a bunch of things
    chmod -R +rw "$pkg"

    makeWrapper ${mono}/bin/mono $out/bin/csc \
      --add-flags "$pkg/tasks/net472/csc.exe"
    makeWrapper ${mono}/bin/mono $out/bin/vbc \
      --add-flags "$pkg/tasks/net472/vbc.exe"

    runHook postInstall
  '';

  dontDotnetFixup = true;

  dotnet-sdk =
    with dotnetCorePackages;
    sdk_9_0
    // {
      inherit
        (combinePackages [
          sdk_9_0
          sdk_8_0
        ])
        packages
        targetPackages
        ;
    };

  dotnetFlags = [
    # this removes the Microsoft.WindowsDesktop.App.Ref dependency
    "-p:EnableWindowsTargeting=false"
  ];

  nugetDeps = ./deps.json;

  projectFile = [
    "src/NuGet/Microsoft.Net.Compilers.Toolset/Framework/Microsoft.Net.Compilers.Toolset.Framework.Package.csproj"
  ];

  meta = {
    description = ".NET C# and Visual Basic compiler";
    homepage = "https://github.com/dotnet/roslyn";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ corngood ];
    mainProgram = "csc";
  };
}
