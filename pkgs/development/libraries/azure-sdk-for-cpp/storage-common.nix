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
  pname = "azure-sdk-for-cpp-storage-common";
  version = "12.12.0";

  src = fetchFromGitHub {
    owner = "Azure";
    repo = "azure-sdk-for-cpp";
    tag = "azure-storage-common_${finalAttrs.version}";
    hash = "sha256-cycBXSvc3G8TdLnI4Ht1lBd9ndPOjxWFQA54a24iUsY=";
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

  sourceRoot = "${finalAttrs.src.name}/sdk/storage/azure-storage-common";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "azure-storage-common_(.*)"
    ];
  };

  meta = (
    meta
    // {
      description = "Azure Storage Common Client Library for C++";
      changelog = "https://github.com/Azure/azure-sdk-for-cpp/blob/main/sdk/storage/azure-storage-common/CHANGELOG.md";
    }
  );
})
