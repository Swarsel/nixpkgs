{
  fetchFromGitHub,
  fetchFromGitLab,
  nativefiledialog-extended,
  zstd,
}:
{
  version = "0.12.2";

  cpmSrcs = [
    (fetchFromGitHub {
      hash = "sha256-mQOJ6jCN+7VopgZ61yzaCnt4R1QLrW7+47xxMhFRHLQ=";
      name = "ImGui";
      owner = "ocornut";
      repo = "imgui";
      rev = "v1.91.9b-docking";
    })
    # Use nixpkgs source but let CPM build with tracy's options (NFD_PORTAL)
    (nativefiledialog-extended.src // { name = "nfd"; })
    (fetchFromGitHub {
      hash = "sha256-EMZVI/uyzwX5637/rdZuMZoql5FTrsx0ESJMdLVDmfk=";
      name = "PPQSort";
      owner = "GabTux";
      repo = "PPQSort";
      rev = "v1.0.5";
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
      hash = "sha256-oKRu3P1inWueEMIpL0uI2ayCMHZ9FIVotil4sqwLqH4=";
      name = "capstone";
      owner = "capstone-engine";
      repo = "capstone";
      rev = "6.0.0-Alpha1";
    })
  ];

  extraBuildInputs = [ zstd ];
  srcHash = "sha256-voHql8ETnrUMef14LYduKI+0LpdnCFsvpt8B6M/ZNmc=";
}
