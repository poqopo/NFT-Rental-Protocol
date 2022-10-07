const { ethers, upgrades } = require("hardhat");

const PROXY = "0x935b177AE396eDD723Fee35f5Ccda3F45B88a984";

async function main() {
  const [owner, lender, renter] = await ethers.getSigners();
    
  const Rent = await ethers.getContractFactory("RentERC721");
  const rent = await upgrades.deployProxy(Rent, [owner.address], {
    initializer: "initialize",
  });
  await rent.deployed();
  console.log("Rent contract is : ", rent.address)
  
  await rent.initialize(owner.address)
  await rent.setFeecollector(owner.address)
  
  const NFT = await ethers.getContractFactory("MyToken721");
  const nft = await NFT.connect(lender).deploy();
  await nft.deployed();
  console.log("NFT contract is : ", nft.address)

  const Token = await ethers.getContractFactory("MyToken20");
  const token = await Token.connect(renter).deploy();
  await token.deployed();
  console.log("Token contract is : ", token.address)

  console.log("Mint NFTand approve")

  await nft.connect(lender).safeMint()
  await rent.connect(lender).NFTlist(nft.address, 0, token.address, 1000, 10, 1)
  await nft.connect(lender).setApprovalForAll(rent.address, true)

  console.log("Mint token and approve")
  // Token mint & approve
  await token.connect(renter).mint(renter.address, 10000)
  await token.connect(renter).approve(rent.address, 1e6)

  await rent.connect(renter).rent(nft.address, 0, 50)

  console.log("Should have 60 token",await token.balanceOf(rent.address))


}

main();
