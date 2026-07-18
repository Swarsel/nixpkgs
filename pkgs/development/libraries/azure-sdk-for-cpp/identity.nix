{
  stdenv,
  fetchFromGitHub,
  cmake,
  core,
  meta,
  ninja,
  nix-update-script,
  openssl,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "azure-sdk-for-cpp-identity";
  version = "1.13.3";

  src = fetchFromGitHub {
    owner = "Azure";
    repo = "azure-sdk-for-cpp";
    tag = "azure-identity_${finalAttrs.version}";
    hash = "sha256-IGhJi8fnNY/NXnZ6ZGclJxG1gEx7BRj9setMaFUJZNQ=";
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

  buildInputs = [ openssl ];
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

  sourceRoot = "${finalAttrs.src.name}/sdk/identity/azure-identity";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "azure-identity_(.*)"
    ];
  };

  meta = (
    meta
    // {
      description = "Azure Identity client library for C++";
      changelog = "https://github.com/Azure/azure-sdk-for-cpp/blob/main/sdk/identity/azure-identity/CHANGELOG.md";
    }
  );
})
