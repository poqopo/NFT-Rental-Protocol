const { ethers, upgrades } = require("hardhat");

const PROXY = "0x935b177AE396eDD723Fee35f5Ccda3F45B88a984";

async function main() {
  const [owner, lender, renter] = await ethers.getSigners();
    
  const Rent = await ethers.getContractFactory("RentERC721");
  // const rent = await upgrades.deployProxy(Rent, [owner.address], {
  //   initializer: "initialize",
  // });
  // await rent.deployed();

  const rent = await Rent.attach("0x0791183290153A0D953712dB28907Ee58A1F0000")
  console.log("Rent contract is : ", rent.address)
  
  const NFT = await ethers.getContractFactory("MyToken721");
  // const nft = await NFT.connect(lender).deploy();
  // await nft.deployed();

  const nft = await NFT.attach("0x35Fe23B624885d621fA9C295Fc0505e584EA961A")
  console.log("NFT contract is : ", nft.address)

  const Token = await ethers.getContractFactory("MyToken20");
  // const token = await Token.connect(renter).deploy();
  // await token.deployed();

  const token = await Token.attach("0x9466a45072E91ff5AbA7e084E5ea74531f09731a")
  console.log("Token contract is : ", token.address)

  console.log("Mint NFTand approve")

  // await nft.connect(lender).safeMint()

  // await rent.connect(lender).NFTlist(nft.address, 0, token.address, 1000, 10, 1)
  // await nft.connect(lender).setApprovalForAll(rent.address, true)

  // console.log("Mint token and approve")
  // // Token mint & approve
  // await token.connect(renter).mint(renter.address, 10000)
  // await token.connect(renter).approve(rent.address, 1e6)

  // await rent.connect(renter).rent(nft.address, 0, 50)

  // console.log("Should have 60 token",await token.balanceOf(rent.address))

  // await rent.connect(lender).withdrawCollateral(nft.address, 0)


}

main();
