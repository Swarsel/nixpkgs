{
  fetchFromGitHub,
  curl,
  html-tidy,
  md4c,
  nativefiledialog-extended,
  nlohmann_json,
  pugixml,
  zstd,
}:
{
  version = "0.13.1";

  cpmSrcs = [
    (fetchFromGitHub {
      hash = "sha256-/jVT7+874LCeSF/pdNVTFoSOfRisSqxCJnt5/SGCXPQ=";
      name = "ImGui";
      owner = "ocornut";
      repo = "imgui";
      rev = "v1.92.5-docking";
    })
    # Use nixpkgs source but let CPM build with tracy's options (NFD_PORTAL)
    (nativefiledialog-extended.src // { name = "nfd"; })
    (fetchFromGitHub {
      hash = "sha256-HgM+p2QGd9C8A8l/VaEB+cLFDrY2HU6mmXyTNh7xd0A=";
      name = "PPQSort";
      owner = "GabTux";
      repo = "PPQSort";
      rev = "v1.0.6";
    })
    # Transitive from PPQSort
    (fetchFromGitHub {
      hash = "sha256-E7WZSYDlss5bidbiWL1uX41Oh6JxBRtfhYsFU19kzIw=";
      name = "PackageProject.cmake";
      owner = "TheLartians";
      repo = "PackageProject.cmake";
      rev = "v1.11.1";
    })
    (fetchFromGitHub {
      hash = "sha256-18PTj4hvBw8RTgzaFGeaDbBfkxmotxSoGtprIjcEuVg=";
      name = "capstone";
      owner = "capstone-engine";
      repo = "capstone";
      rev = "6.0.0-Alpha5";
    })
    (fetchFromGitHub {
      hash = "sha256-dIaNfQ/znpAdg0/vhVNTfoaG7c8eFrdDTI0QDHcghXU=";
      name = "base64";
      owner = "aklomp";
      repo = "base64";
      rev = "v0.5.2";
    })
    (fetchFromGitHub {
      fetchSubmodules = true;
      hash = "sha256-7IylunAkVNceKSXzCkcpp/kAsI3XoqniHe10u3teUVA=";
      name = "usearch";
      owner = "unum-cloud";
      repo = "usearch";
      rev = "v2.21.3";
    })
  ];

  extraBuildInputs = [
    md4c
    pugixml
    curl
    zstd
    nlohmann_json
    html-tidy
  ];

  srcHash = "sha256-D4aQ5kSfWH9qEUaithR0W/E5pN5on0n9YoBHeMggMSE=";
}
