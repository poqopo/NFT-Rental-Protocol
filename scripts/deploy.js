const { ethers } = require("hardhat");


const main = async () => {
    const [owner] = await ethers.getSigners();
    const lender = "0xDDFd4B9d00dC3e39bc759243Bb3906540ee6fD3D"
    const renter = "0xB9b3c873971744c97bF368968741255D324f0222"

    const max_rent = 10000;
    const collateral = 1000;
    const rent_block_fee = 100;

    RenterFactory = await ethers.getContractFactory("RentERC721");
    // let rentercontract = await RenterFactory.deploy();
    const rentercontract = await RenterFactory.attach("0xd066619E0e68172f403893CeDeb146a7f793a2f8");
    console.log("rentercontract address is:", await rentercontract.address);

    MERC721Factory = await ethers.getContractFactory("MyToken721");
    // let mockERC721 = await MERC721Factory.deploy();
    const mockERC721 = await MERC721Factory.attach("0x080C99eab039139279Fd57fC2057799c21783B91");
    console.log("mockERC721 address is:", await mockERC721.address);

    MERC20Factory = await ethers.getContractFactory("MyToken20");
    // let mockERC20 = await MERC20Factory.deploy();
    const mockERC20 = await MERC20Factory.attach("0xEb934b5164314017C0F138009633a296A24499Bc");
    console.log("mockERC20 address is:", await mockERC20.address);

    /* =============  Now we can start ============ */

    // Mint NFT to lender 
    // await mockERC721.safeMint(lender);

    // Mint token to renter
    // await mockERC20.mint(renter, 1e6)

    /* =============  List and Cancle start ============ */

    // Approve NFT to rentercontract
    // await mockERC721.approve(rentercontract.address, 0)

    // await rentercontract.listNFT(mockERC721.address, mockERC20.address, 0, max_rent, collateral, rent_block_fee)
    // await rentercontract.modifylist(mockERC721.address, 0, [0, 1, 2], [50000, 10000, 100])
    // await rentercontract.cancellisted(mockERC721.address, 0)

    /* =============  List but emergency cancle start ============ */   

    // Approve NFT to rentercontract
    // await mockERC721.approve(rentercontract.address, 0)

    // await rentercontract.listNFT(mockERC721.address, mockERC20.address, 0, max_rent, collateral, rent_block_fee)
    // await rentercontract.emergencycancel(mockERC721.address, 0)


    /* =============  rent and return Start ============ */

    // await mockERC20.approve(rentercontract.address, 1e7)
    // await rentercontract.rent(mockERC721.address, 0, 5000)

    // Approve NFT to rentercontract
    // await mockERC721.approve(rentercontract.address, 0)
    // await rentercontract.returnNFT(mockERC721.address, 0)

    /* =============  rent but withdraw start ============ */


    // Approve NFT to rentercontract (lender)
    // await mockERC721.approve(rentercontract.address, 0)
    // await rentercontract.listNFT(mockERC721.address, mockERC20.address, 0, max_rent, collateral, rent_block_fee)

    // Approve token to rentercontract(Renter)
    // await mockERC20.approve(rentercontract.address, 1e7)
    // await rentercontract.rent(mockERC721.address, 0, 50)

    // await rentercontract.withdrawcollateral(mockERC721.address, 0)


    /* =============  rent but kick start ============ */


    // Approve NFT to rentercontract (lender)
    // await mockERC721.approve(rentercontract.address, 0)
    // await rentercontract.listNFT(mockERC721.address, mockERC20.address, 0, max_rent, collateral, rent_block_fee)

    // Approve token to rentercontract(Renter)
    // await mockERC20.approve(rentercontract.address, 1e7)
    // await rentercontract.rent(mockERC721.address, 0, 50)

    // await rentercontract.kick(mockERC721.address, 0)


    /* ============= set_function  start ============ */


    // await rentercontract.set_fee_colletcor(lender)
    // await rentercontract.set_platform_fee(5000)
    // await rentercontract.set_kick_incentive(3000)
    // await rentercontract.set_execution_delay(2000)
    // await rentercontract.togglepaused()

}


const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};

runMain();