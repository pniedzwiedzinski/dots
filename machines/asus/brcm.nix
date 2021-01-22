{ stdenv, fetchurl }:

stdenv.mkDerivation {
  name = "brcmfmac43340";

  src = fetchurl {
    url = "https://android.googlesource.com/platform/hardware/broadcom/wlan/+archive/master/bcmdhd/firmware/bcm43341.tar.gz";
    sha256 = "1vm5yvxznkvsbdvnhm10dci33i0b9flzqalpbgvmzyd95vi7s4bm";
  };

  installPhase = ''
    mkdir -p $out/lib/firmware/brcm

    cp fw_bcm43341.bin $out/lib/firmware/brcm/brcmfmac43340-sdio.bin
    cp fw_bcm43341.bin $out/lib/firmware/brcm/brcmfmac43341-sdio.bin
  '';
}
