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
  pname = "azure-sdk-for-cpp-security-keyvault-certificates";
  version = "4.3.0-beta.4";

  src = fetchFromGitHub {
    owner = "Azure";
    repo = "azure-sdk-for-cpp";
    tag = "azure-security-keyvault-certificates_4.3.0-beta.4";
    hash = "sha256-6LvqeSqSz5oDxXoR/vD7Pbxc2ksQflFhIrN7DzmMoaE=";
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

  sourceRoot = "${finalAttrs.src.name}/sdk/keyvault/azure-security-keyvault-certificates";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "azure-security-keyvault-certificates_(.*)"
    ];
  };

  meta = (
    meta
    // {
      description = "Azure Key Vault Certificates client library for C++";
      changelog = "https://github.com/Azure/azure-sdk-for-cpp/blob/main/sdk/keyvault/azure-security-keyvault-certificates/CHANGELOG.md";
    }
  );
})
