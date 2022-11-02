const { ethers, upgrades } = require("hardhat");

const PROXY = "0x935b177AE396eDD723Fee35f5Ccda3F45B88a984";

async function main() {
  const [lender, renter] = await ethers.getSigners();
  const Rent = await ethers.getContractFactory("RentERC721");
  const rent = await Rent.attach("0x0791183290153A0D953712dB28907Ee58A1F0000")
  const NFT = await ethers.getContractFactory("MyToken721");
  const Token = await ethers.getContractFactory("MyToken20");
  const token = await Token.attach("0x9466a45072E91ff5AbA7e084E5ea74531f09731a")
  const nft = await NFT.attach("0xb28eB9B9Efa9E500cD7E5C9007560F13424C40bd")


console.log( await rent.connect(lender).viewRentinfo(nft.address, 7))

}

main();
