const { ethers, upgrades } = require("hardhat");

const PROXY = "0x935b177AE396eDD723Fee35f5Ccda3F45B88a984";

async function main() {
  const [owner, lender, renter] = await ethers.getSigners();

  const Rent = await ethers.getContractFactory("RentERC721");
  const rent = await Rent.attach("0x0791183290153A0D953712dB28907Ee58A1F0000")
  const NFT = await ethers.getContractFactory("MyToken721");
  const nft = await NFT.attach("0x35Fe23B624885d621fA9C295Fc0505e584EA961A")
  const Token = await ethers.getContractFactory("MyToken20");
  const token = await Token.attach("0x9466a45072E91ff5AbA7e084E5ea74531f09731a")


//   setInterval(async () => {
//     if ((await rent.viewRentinfo(nft.address, 0)).lender_address == renter.address)  {
//       await rent.connect(renter).cancelList(nft.address, 0);
//       console.log("Canceled!")
//     }
//     else {
//       await rent.connect(renter).NFTlist(nft.address, 0, owner.address, 100, 10, 100);
//       console.log("Listed!")
//     }
//   }, "5000")

// setInterval(async () => {
//       await rent.connect(lender).modifyList(nft.address, 0, 3, Math.floor(Math.random() * 100));
//       console.log("Modified!!")
//   }, "5000")
    //   await rent.connect(renter).NFTlist(nft.address, 0, owner.address, 6500000, 1000, 100);
    //   console.log("Listed!")




      setInterval(async () => {
    if ((await rent.viewRentinfo(nft.address, 0)).lender_address == '0x0000000000000000000000000000000000000000')  {
        await rent.connect(lender).NFTlist(nft.address, 0, token.address, 1000, 0, 0);
        console.log("Listed!")

    } else if ((await rent.viewRentinfo(nft.address, 0)).renter_address == '0x0000000000000000000000000000000000000000')  {
        await rent.connect(renter).rent(nft.address, 0, 50);
        console.log("Rented!")

    } else {
        await rent.connect(renter).returnNFT(nft.address, 0);
        console.log("Returned!")
    }
  }, "5000")

    //   console.log(await rent.viewRentinfo(nft.address, 0))

    // await rent.connect(owner).kick(nft.address,0)

    //   await rent.connect(renter).modifyList(nft.address, 0, 0, token.address);
    //   console.log("Modified!!")
    // await token.connect(renter).approve(rent.address, 1e8)
    // await token.mint(renter.address, 10)
    // await nft.connect(lender).setApprovalForAll(rent.address, true)

    // await nft.connect(renter).transferFrom(renter.address, lender.address, 0)

}

main();
