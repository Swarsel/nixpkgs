{
  stdenv,
  fetchFromGitHub,
  cmake,
  core,
  meta,
  ninja,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "azure-sdk-for-cpp-security-keyvault-secrets";
  version = "4.3.0-beta.4";

  src = fetchFromGitHub {
    owner = "Azure";
    repo = "azure-sdk-for-cpp";
    tag = "azure-security-keyvault-secrets_4.3.0-beta.4";
    hash = "sha256-NSstk0cpgWBOhi50eiFSHDYiJjel2a4l8xxgfIPKSsU=";
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

  sourceRoot = "${finalAttrs.src.name}/sdk/keyvault/azure-security-keyvault-secrets";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "azure-security-keyvault-secrets_(.*)"
    ];
  };

  meta = (
    meta
    // {
      description = "Azure Security Keyvault Secrets Package client library for C++";
      changelog = "https://github.com/Azure/azure-sdk-for-cpp/blob/main/sdk/keyvault/azure-security-keyvault-secrets/CHANGELOG.md";
    }
  );
})
