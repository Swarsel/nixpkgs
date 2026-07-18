{ buildRedist }:
buildRedist {
  pname = "nvpl_common";

  outputs = [
    "out"
    "dev"
  ];

  redistName = "nvpl";

  meta = {
    description = "Common part of NVIDIA Performance Libraries";
    homepage = "https://developer.nvidia.com/nvpl";
    changelog = "https://docs.nvidia.com/nvpl/latest/release_notes.html";
  };
}
