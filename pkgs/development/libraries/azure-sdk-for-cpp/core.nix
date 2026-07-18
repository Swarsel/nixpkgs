{
  stdenv,
  fetchFromGitHub,
  cmake,
  curl,
  libxml2,
  meta,
  ninja,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "azure-sdk-for-cpp-core";
  version = "1.16.3";

  src = fetchFromGitHub {
    owner = "Azure";
    repo = "azure-sdk-for-cpp";
    tag = "azure-core_${finalAttrs.version}";
    hash = "sha256-1OLyTwjfSunwvDMbMTNw0w8txhJxXthtAVeFf7abrIs=";
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
    curl
    libxml2
  ];

  cmakeFlags = [
    "-DBUILD_SHARED_LIBS=ON"
    "-DBUILD_TRANSPORT_CURL=ON"
    "-DWARNINGS_AS_ERRORS=OFF"
  ];

  env = {
    AZURE_SDK_DISABLE_AUTO_VCPKG = 1;
  };

  # Testing this is moderately involved, see:
  # https://github.com/Azure/azure-sdk-for-cpp/blob/main/CONTRIBUTING.md#testing-the-project
  # Unless issues arise, it does not seem worth the effort.
  doCheck = false;

  postInstall = ''
    moveToOutput "share" "$dev"
    moveToOutput "share/$(basename "$sourceRoot")-cpp/copyright" "$out"
  '';

  sourceRoot = "${finalAttrs.src.name}/sdk/core/azure-core";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "azure-core_(.*)"
    ];
  };

  meta = (
    meta
    // {
      description = "Azure SDK Core Library for C++";
      changelog = "https://github.com/Azure/azure-sdk-for-cpp/blob/main/sdk/core/azure-core/CHANGELOG.md";
    }
  );
})
