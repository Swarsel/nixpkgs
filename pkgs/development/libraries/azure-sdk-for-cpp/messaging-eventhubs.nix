{
  stdenv,
  fetchFromGitHub,
  cmake,
  core,
  core-amqp,
  meta,
  ninja,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "azure-sdk-for-cpp-messaging-eventhubs";
  version = "1.0.0-beta.10";

  src = fetchFromGitHub {
    owner = "Azure";
    repo = "azure-sdk-for-cpp";
    tag = "azure-messaging-eventhubs_1.0.0-beta.10";
    hash = "sha256-qGYfvRFnesI+oIp3jCRo53v66aR2qrcummSNpc5sCOw=";
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
    core-amqp
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DWARNINGS_AS_ERRORS=OFF"
  ];

  env = {
    AZURE_SDK_DISABLE_AUTO_VCPKG = 1;
    NIX_CFLAGS_COMPILE = "-Wno-error";
  };

  # See note in ./core.nix.
  doCheck = false;

  postInstall = ''
    moveToOutput "share" "$dev"
    moveToOutput "share/$(basename "$sourceRoot")-cpp/copyright" "$out"
  '';

  sourceRoot = "${finalAttrs.src.name}/sdk/eventhubs/azure-messaging-eventhubs";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "azure-messaging-eventhubs_(.*)"
    ];
  };

  meta = (
    meta
    // {
      description = "Azure Event Hubs Client Package for C++";
      changelog = "https://github.com/Azure/azure-sdk-for-cpp/blob/main/sdk/eventhubs/azure-messaging-eventhubs/CHANGELOG.md";
    }
  );
})
