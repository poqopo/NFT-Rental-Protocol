const { ethers } = require("hardhat");

const main = async () => {
  const [owner] = await ethers.getSigners();
  const lender = "0xDDFd4B9d00dC3e39bc759243Bb3906540ee6fD3D";
  const renter = "0xB9b3c873971744c97bF368968741255D324f0222";

  const max_rent = 10000;
  const collateral = 1000;
  const rent_block_fee = 100;

  RenterFactory = await ethers.getContractFactory("RentERC721");
  // let rentercontract = await RenterFactory.deploy();
  const rentercontract = await RenterFactory.attach(
    "0x208291a2279882Cb6aC238977735eddd5d6e283C"
  );
  console.log("rentercontract address is:", await rentercontract.address);

  MERC721Factory = await ethers.getContractFactory("MyToken721");
  // let mockERC721 = await MERC721Factory.deploy();
  const mockERC721 = await MERC721Factory.attach(
    "0xbbdc9c1275534c336f34140d8e23db425586f2a9"
  );
  console.log("mockERC721 address is:", await mockERC721.address);

  MERC20Factory = await ethers.getContractFactory("MyToken20");
  // let mockERC20 = await MERC20Factory.deploy();
  const mockERC20 = await MERC20Factory.attach(
    "0xEb934b5164314017C0F138009633a296A24499Bc"
  );
  console.log("mockERC20 address is:", await mockERC20.address);

  // setInterval(async () => {
  //   if ((await mockERC721.ownerOf(5)).toString() !== lender)  {
  //     await rentercontract.cancellist(mockERC721.address, 5);
  //     console.log("Canceled!")
  //   }
  //   else if ((await mockERC721.getApproved(5)).toString() !== rentercontract.address) {
  //     await mockERC721.approve(rentercontract.address, 5);
  //     console.log("Approved!")
  //   }
  //   else {
  //     await rentercontract.listNFT(mockERC721.address, mockERC20.address, 5, max_rent, Math.floor(Math.random() * 100), rent_block_fee);
  //     console.log("Listed!")
  //   }
  // }, "5000")

  // setInterval(async () => {  
  //     await rentercontract.modifylist(mockERC721.address, 5,[0, 1, 2], [Math.floor(Math.random() * 100), Math.floor(Math.random() * 1000), Math.floor(Math.random() * 1000)]);
  //     console.log("Modified!")
    
  // }, "5000")
};

main();
