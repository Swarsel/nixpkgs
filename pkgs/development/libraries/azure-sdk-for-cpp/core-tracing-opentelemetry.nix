{
  stdenv,
  fetchFromGitHub,
  cmake,
  core,
  meta,
  ninja,
  nix-update-script,
  opentelemetry-cpp,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "azure-sdk-for-cpp-core-tracing-opentelemetry";
  version = "1.0.0-beta.4";

  src = fetchFromGitHub {
    owner = "Azure";
    repo = "azure-sdk-for-cpp";
    tag = "azure-core-tracing-opentelemetry_1.0.0-beta.4";
    hash = "sha256-3PqHpoi7zlTUYJ4A4APKp2yPg9nVwgGiyOZ+bng4Crk=";
  };

  outputs = [
    "out"
    "dev"
  ];

  postPatch = ''
    sed -i '/CMAKE_CXX_STANDARD/d' CMakeLists.txt
  '';

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [ opentelemetry-cpp ];
  propagatedBuildInputs = [ core ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DWARNINGS_AS_ERRORS=OFF"
  ];

  env = {
    AZURE_SDK_DISABLE_AUTO_VCPKG = 1;
  };

  # See note in ./core.nix.
  doCheck = false;

  postInstall = ''
    moveToOutput "share" "$dev"
    moveToOutput "share/$(basename "$sourceRoot")-cpp/copyright" "$out"
  '';

  sourceRoot = "${finalAttrs.src.name}/sdk/core/azure-core-tracing-opentelemetry";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "azure-core-tracing-opentelemetry_(.*)"
    ];
  };

  meta = (
    meta
    // {
      description = "Azure SDK Core Tracing Library for C++";
      changelog = "https://github.com/Azure/azure-sdk-for-cpp/blob/main/sdk/core/azure-core-tracing-opentelemetry/CHANGELOG.md";
    }
  );
})
