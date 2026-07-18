{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  vulkan-headers,
  vulkan-loader,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "vkdisplayinfo";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "ChristophHaag";
    repo = "vkdisplayinfo";
    rev = finalAttrs.version;
    hash = "sha256-n6U7T5aOYTpgWE2WGPBPHtQKzitf9PxAoXJNWyz4rYw=";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  buildInputs = [
    vulkan-loader
    vulkan-headers
  ];

  postInstall = ''
    install vkdisplayinfo -Dm755 -t $out/bin
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck
    ($out/bin/vkdisplayinfo 2>&1 || true) | grep -q vkdisplayinfo
    runHook postInstallCheck
  '';

  meta = {
    description = "Print displays and modes enumerated with the Vulkan function vkGetPhysicalDeviceDisplayPropertiesKHR";
    homepage = "https://github.com/ChristophHaag/vkdisplayinfo";
    license = lib.licenses.boost;
    maintainers = [ lib.maintainers.LunNova ];
    platforms = lib.platforms.linux;
    mainProgram = "vkdisplayinfo";
  };
})
