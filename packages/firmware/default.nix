{
  fetchFromGitHub,
  findutils,
  lib,
  pil-squasher,
  stdenv,
}:
stdenv.mkDerivation {
  pname = "spacewar-firmware";
  # No versioned releases, so let's use the commit hash for now.
  version = "ebb4d6a47865e78a9fd6689394221a5bb3d621dd";

  # Source: https://github.com/mainlining/firmware-nothing-spacewar.
  src = fetchFromGitHub {
    owner = "Nonta72";
    repo = "firmware-nothing-spacewar";
    rev = "5398e11062c186a9771f22c54acb225fe9e0a20f";
    hash = "sha256-u67vBXRLcyCg4ucQo5ei8h6I+jvrjoeojTuW4W6eh2Y=";
  };

  meta = {
    description = "Firmware files for Nothing Phone (1)";
    longDescription = ''
      Proprietary firmware files required for Nothing Phone (1) hardware components
      including GPU, DSP, modem, and Bluetooth. Converted from Qualcomm split
      format to monolithic .mbn files for mainline Linux kernel.
    '';
    homepage = "https://github.com/mainlining/firmware-nothing-spacewar";
    license = lib.licenses.unfree;
    maintainers = [];
    platforms = lib.platforms.linux;
  };

  nativeBuildInputs = [pil-squasher findutils];

  buildPhase = ''
    runHook preBuild

    # Squash all .mdt firmware files to .mbn format.
    echo "Squashing firmware files..."
    find . -name "*.mdt" -type f | while read -r mdtfile; do
      echo "Processing: $mdtfile"
      pil-squasher "''${mdtfile%.mdt}.mbn" "$mdtfile"
    done

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Install GPU/DSP/modem firmware to qcom/sm7325/nothing/spacewar/.
    # These are the .mbn files created by pil-squasher from .mdt files.
    mkdir -p "$out/lib/firmware/qcom/sm7325/nothing/spacewar"
    install -Dm644 -t "$out/lib/firmware/qcom/sm7325/nothing/spacewar" \
      a660_zap.mbn \
      adsp.mbn \
      cdsp.mbn \
      modem.mbn \
      wpss.mbn

    # Install JSON config files.
    install -Dm644 -t "$out/lib/firmware/qcom/sm7325/nothing/spacewar" \
      adspr.jsn \
      adsps.jsn \
      adspua.jsn \
      battmgr.jsn \
      cdspr.jsn \
      modemr.jsn

    # Install IPA firmware (renamed to ipa_fws.mbn for kernel compatibility).
    install -Dm644 yupik_ipa_fws.mbn \
      "$out/lib/firmware/qcom/sm7325/nothing/spacewar/ipa_fws.mbn"

    # Install Venus video firmware (renamed to venus.mbn for kernel compatibility).
    install -Dm644 vpu20_1v.mbn \
      "$out/lib/firmware/qcom/sm7325/nothing/spacewar/venus.mbn"

    # Install Bluetooth firmware to qca/.
    #mkdir -p "$out/lib/firmware/qca"
    #install -Dm644 -t "$out/lib/firmware/qca" \
    #  msbtfw11.mbn \
    #  msnv11.bin

    # Install modem_pr directory recursively.
    mkdir -p "$out/lib/firmware/qcom/sm7325/nothing/spacewar"
    cp -r modem_pr "$out/lib/firmware/qcom/sm7325/nothing/spacewar/"

    # Set permissions to 0644 for all modem_pr files.
    find "$out/lib/firmware/qcom/sm7325/nothing/spacewar/modem_pr" -type f -exec chmod 0644 {} \;

    # Install HexagonFS to /usr/share (excluding acdb/ and dsp/ subdirs).
    mkdir -p "$out/usr/share/qcom/sm7325/Nothing/spacewar"

    # Copy only sensors/ and socinfo/ subdirectories (exclude acdb/ and dsp/).
    cp -r hexagonfs/sensors "$out/usr/share/qcom/sm7325/Nothing/spacewar/"
    cp -r hexagonfs/socinfo "$out/usr/share/qcom/sm7325/Nothing/spacewar/"

    # Set permissions to 0644 for HexagonFS files.
    find "$out/usr/share/qcom/sm7325/Nothing/spacewar" -type f -exec chmod 0644 {} \;

    runHook postInstall
  '';
}
