{
  stdenv,
  fetchFromGitHub,
  c-shared-utility,
  cmake,
  core,
  macro-utils-c,
  meta,
  ninja,
  nix-update-script,
  umock-c,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "azure-sdk-for-cpp-core-amqp";
  version = "1.0.0-beta.11";

  src = fetchFromGitHub {
    owner = "Azure";
    repo = "azure-sdk-for-cpp";
    tag = "azure-core-amqp_1.0.0-beta.11";
    hash = "sha256-MQsz5Dmv1BwfUaN1VXMC3hPdMHihlgOBaukp5wgTNJc=";
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
    c-shared-utility
    macro-utils-c
    umock-c
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DDISABLE_RUST_IN_BUILD=ON"
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

  sourceRoot = "${finalAttrs.src.name}/sdk/core/azure-core-amqp";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "azure-core-amqp_(.*)"
    ];
  };

  meta = (
    meta
    // {
      description = "Azure SDK AMQP Library for C++";
      changelog = "https://github.com/Azure/azure-sdk-for-cpp/blob/main/sdk/core/azure-core-amqp/CHANGELOG.md";
    }
  );
})
