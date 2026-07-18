{
  stdenv,
  fetchFromGitHub,
  cmake,
  core,
  libxml2,
  meta,
  ninja,
  nix-update-script,
  openssl,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "azure-sdk-for-cpp-data-tables";
  version = "1.0.0-beta.6";

  src = fetchFromGitHub {
    owner = "Azure";
    repo = "azure-sdk-for-cpp";
    tag = "azure-data-tables_1.0.0-beta.6";
    hash = "sha256-gfkjoA16UP6ToIueYPfhQFh+LEhlVtvTk3qRJoHR5OY=";
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

  buildInputs = [
    openssl
    libxml2
  ];

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

  sourceRoot = "${finalAttrs.src.name}/sdk/tables/azure-data-tables";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "azure-data-tables_(.*)"
    ];
  };

  meta = (
    meta
    // {
      description = "Azure Tables client library for C++";
      changelog = "https://github.com/Azure/azure-sdk-for-cpp/blob/main/sdk/tables/azure-data-tables/CHANGELOG.md";
    }
  );
})
