{
  lib,
  buildDotnetModule,
  buildPythonPackage,
  cffi,
  dotnetCorePackages,
  fetchPypi,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
  setuptools-scm,
  wheel,
}:

let
  pname = "clr-loader";
  version = "0.2.10";
  src = fetchPypi {
    inherit version;
    hash = "sha256-gfEUr7xQBbr8Xv5a8TQdQA4iE34nWwQqiXnz/rn8lEY=";
    pname = "clr_loader";
  };
  # This stops msbuild from picking up $version from the environment
  postPatch = ''
    echo '<Project><PropertyGroup><Version/></PropertyGroup></Project>' > \
      Directory.Build.props

    substituteInPlace example/example.csproj \
      --replace-fail 'net8.0;netstandard2.0' 'net10.0;netstandard2.0'

    substituteInPlace tests/test_common.py \
      --replace-fail 'return build_example(tmp_path_factory, "net8.0")' \
        'return build_example(tmp_path_factory, "net10.0")' \
      --replace-fail 'def test_coreclr_properties(example_netcore: Path):' \
        'def test_coreclr_properties(example_netcore: Path, example_netstandard: Path):'
  '';

  # This buildDotnetModule is used only to get nuget sources, the actual
  # build is done in `buildPythonPackage` below.
  dotnet-build = buildDotnetModule {
    inherit
      pname
      version
      src
      postPatch
      ;

    dotnet-sdk = dotnetCorePackages.sdk_10_0;
    nugetDeps = ./deps.json;

    projectFile = [
      "netfx_loader/ClrLoader.csproj"
      "example/example.csproj"
    ];
  };
in
buildPythonPackage {
  inherit
    pname
    version
    src
    postPatch
    ;

  nativeBuildInputs = [
    setuptools
    setuptools-scm
    wheel
    dotnetCorePackages.sdk_10_0
  ];

  buildInputs = dotnetCorePackages.sdk_10_0.packages ++ dotnet-build.nugetDeps;
  propagatedBuildInputs = [ cffi ];

  # Perform dotnet restore based on the nuget-source
  preConfigure = ''
    dotnet restore "netfx_loader/ClrLoader.csproj" \
      -p:ContinuousIntegrationBuild=true \
      -p:Deterministic=true

    dotnet restore "example/example.csproj" \
      -p:ContinuousIntegrationBuild=true \
      -p:Deterministic=true
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  disabled = pythonAtLeast "3.14";

  disabledTests = [
    # TODO: mono does not work due to https://github.com/NixOS/nixpkgs/issues/7307
    "test_mono"
    "test_mono_debug"
    "test_mono_signal_chaining"
    "test_mono_set_dir"
  ];

  pyproject = true;
  passthru.fetch-deps = dotnet-build.fetch-deps;

  meta = {
    description = "Generic pure Python loader for .NET runtimes";
    homepage = "https://pythonnet.github.io/clr-loader/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mdarocha ];
  };
}
