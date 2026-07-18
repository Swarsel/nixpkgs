{
  stdenv,
  fetchFromGitHub,
  cmake,
  core,
  messaging-eventhubs,
  meta,
  ninja,
  nix-update-script,
  storage-blobs,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "azure-sdk-for-cpp-messaging-eventhubs-checkpointstore-blob";
  version = "1.0.0-beta.1";

  src = fetchFromGitHub {
    owner = "Azure";
    repo = "azure-sdk-for-cpp";
    tag = "azure-messaging-eventhubs-checkpointstore-blob_1.0.0-beta.1";
    hash = "sha256-487IwzlxnKd09ztf9NQESbp/kZzsT18JXKgMwsG5W/Y=";
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

  propagatedBuildInputs = [
    core
    messaging-eventhubs
    storage-blobs
  ];

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

  sourceRoot = "${finalAttrs.src.name}/sdk/eventhubs/azure-messaging-eventhubs-checkpointstore-blob";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "azure-messaging-eventhubs-checkpointstore-blob_(.*)"
    ];
  };

  meta = (
    meta
    // {
      description = "Azure Event Hubs Blob Storage Checkpoint Store for C++";
      changelog = "https://github.com/Azure/azure-sdk-for-cpp/blob/main/sdk/eventhubs/azure-messaging-eventhubs-checkpointstore-blob/CHANGELOG.md";
    }
  );
})
