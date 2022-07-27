// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RentERC721 is Ownable{

    struct Rentinfo {
        address renter_address;
        uint256 rent_duration;
        uint256 rented_block;
        uint256 rentfee_amount;
    }
    struct Lendinfo {
        address lender_address;
        address collateral_token;
        uint256 maxrent_duration;
        uint256 collateral_amount;
        uint256 rent_fee_per_block;
    }
    struct NFTinfo {
        Lendinfo lendinfo;
        Rentinfo rentinfo;
    }

    mapping(address => mapping(uint256 => NFTinfo)) private nftinfo;

    address fee_collector;
    uint256 platform_fee = 10000;
    uint256 kick_incentive = 10000;
    uint256 execution_delay = 2 days;

    uint256 fee_denominator = 1000000;
    bool paused = false;
    bool stopforupgrade = false;

    /* ============ modifier ============*/

    modifier onlyLister(address collection_address, uint256 token_id) {
        require(msg.sender == nftinfo[collection_address][token_id].lendinfo.lender_address, "Only lister can do");
        _;
    }

    modifier notPaused() {
        require(!paused, "system paused");
        _;
    }

    modifier notUpgrade() {
        require(!stopforupgrade, "stop for upgrade");
        _;
    }

    /* ============ set function ============*/

    function set_fee_colletcor (address _fee_collector) external onlyOwner {
        fee_collector = _fee_collector;
    }

    function set_platform_fee (uint256 _platform_fee) external onlyOwner {
        platform_fee = _platform_fee;
    }
    
    function set_kick_incentive (uint256 _kick_incentive) external onlyOwner {
        kick_incentive = _kick_incentive;
    }

    function set_execution_delay (uint256 _execution_delay) external onlyOwner {
        execution_delay = _execution_delay;
    }

    function togglepaused() external onlyOwner {
        paused = !paused;
    }

    function togglesstopforupgrade() external onlyOwner {
        stopforupgrade = !stopforupgrade;
    }
    

    constructor() {
        fee_collector = msg.sender;
    }

    //NFT 리스팅. 이전에 Approve 필요
    function listNFT(
            address collection_address,
            address _collateral_token,
            uint256 token_id,
            uint256 _maxrent_duration,
            uint256 _collateral_amount,
            uint256 _rent_fee_per_block
            ) public notPaused notUpgrade {
        
        require(msg.sender == IERC721(collection_address).ownerOf(token_id), "You are not the owner");
        require(nftinfo[collection_address][token_id].rentinfo.rented_block == 0, "already rented item!");

        nftinfo[collection_address][token_id].lendinfo = Lendinfo ({
            lender_address : msg.sender,
            collateral_token : _collateral_token,
            maxrent_duration : _maxrent_duration,
            collateral_amount : _collateral_amount,
            rent_fee_per_block : _rent_fee_per_block
        });

        IERC721(collection_address).safeTransferFrom(msg.sender, address(this), token_id);
        emit NFTlisted(collection_address, _collateral_token, token_id, _maxrent_duration, _collateral_amount, _rent_fee_per_block);
    }

    function cancellisted(address collection_address, uint256 token_id) public onlyLister(collection_address, token_id) notPaused {
        require(nftinfo[collection_address][token_id].rentinfo.rented_block == 0, "already rented item!");

        delete nftinfo[collection_address][token_id].lendinfo;
        IERC721(collection_address).safeTransferFrom(address(this), msg.sender, token_id);

        emit NFTlistcancelled(collection_address, token_id);
    }

    function emergencycancel (address collection_address, uint256 token_id) external onlyOwner {
        require(nftinfo[collection_address][token_id].rentinfo.rented_block == 0, "already rented item!");

        delete nftinfo[collection_address][token_id].lendinfo;
        IERC721(collection_address).safeTransferFrom(address(this), nftinfo[collection_address][token_id].lendinfo.lender_address, token_id);

        emit NFTlistcancelled(collection_address, token_id);
    }   

    enum PARAMETER { MAXRENT, PRICE, BLOCKFEE }

    function modifylist(address collection_address, uint256 token_id, PARAMETER[] memory _parameter, uint256[] memory _input) public onlyLister(collection_address, token_id) notPaused notUpgrade {
        for (uint256 i = 0; i < _parameter.length; i++) {
            if (_parameter[i] == PARAMETER.MAXRENT) { // 0
                nftinfo[collection_address][token_id].lendinfo.maxrent_duration = _input[i];
            } else if (_parameter[i] == PARAMETER.PRICE) { // 1
                nftinfo[collection_address][token_id].lendinfo.collateral_amount = _input[i];
            } else if (_parameter[i] == PARAMETER.BLOCKFEE) { // 2
                nftinfo[collection_address][token_id].lendinfo.rent_fee_per_block = _input[i];
            }
        }

        emit NFTlistmodified(collection_address, token_id, _parameter, _input );
    }

    //rent 하기 전 collateral approve 해야함.
    function rent(address collection_address, uint256 token_id, uint256 _rent_duration) public notPaused  notUpgrade {
        NFTinfo memory nft = nftinfo[collection_address][token_id];
        require(nft.lendinfo.lender_address != address(0), "Not listed");
        require(_rent_duration > 0, "You should rent more than 1 block");
        require(nft.rentinfo.rent_duration == 0, "Already rented");
        require(_rent_duration < nft.lendinfo.maxrent_duration, "too long NFT duration");

        uint256 rent_fee = nft.lendinfo.rent_fee_per_block * _rent_duration;
        uint256 total = nft.lendinfo.collateral_amount + rent_fee;

        nftinfo[collection_address][token_id].rentinfo = Rentinfo ({
            renter_address : msg.sender,
            rent_duration : _rent_duration,
            rented_block : block.number,
            rentfee_amount : fee
        });

        IERC20(lendinfo.collateral_token).transferFrom(msg.sender, address(this), total);
        IERC721(collection_address).safeTransferFrom(address(this), msg.sender, token_id);

        emit NFTrented(collection_address, token_id, msg.sender, _rent_duration, block.number, total);
    }

    //NFTapprove 필수
    function returnNFT(address collection_address, uint256 token_id) public notPaused {
        NFTinfo memory nft = nftinfo[collection_address][token_id];
        require(nft.rentinfo.renter_address != address(0), "Not listed");
        require(block.number - nft.rentinfo.rented_block <= nft.rentinfo.rent_duration, "Timeout.");
        require(msg.sender == nft.rentinfo.renter_address, "You are not renter");

        uint256 platformfee = nft.rentinfo.rentfee_amount * platform_fee / fee_denominator;
        uint256 fee_amount = nft.rentinfo.rentfee_amount - platformfee; 

        delete nftinfo[collection_address][token_id];

        IERC721(collection_address).safeTransferFrom(msg.sender, nft.lendinfo.lender_address, token_id);

        IERC20(nft.lendinfo.collateral_token).transfer(msg.sender, nft.lendinfo.collateral_amount);
        IERC20(nft.lendinfo.collateral_token).transfer(nft.lendinfo.lender_address, fee_amount);
        IERC20(nft.lendinfo.collateral_token).transfer(fee_collector, platformfee);

        emit NFTreturned(collection_address, token_id, nft.rentinfo.rented_block);
    }

    function withdrawcollateral (address collection_address, uint256 token_id) public notPaused {
        NFTinfo memory nft = nftinfo[collection_address][token_id];
        require(nft.rentinfo.renter_address != address(0), "Not listed");
        require(block.number - nft.rentinfo.rented_block > nft.rentinfo.rent_duration, "Still renting time.");
        require(msg.sender == nft.lendinfo.lender_address, "You are not holder");

        uint256 platformfee = nft.rentinfo.rentfee_amount * platform_fee / fee_denominator;
        uint256 total = nft.lendinfo.collateral_amount + nft.rentinfo.rentfee_amount - platformfee;

        delete nftinfo[collection_address][token_id];

        IERC20(nft.lendinfo.collateral_token).transfer(msg.sender, total);
        IERC20(nft.lendinfo.collateral_token).transfer(fee_collector, platformfee);
        
        emit Colletralwithdrwed(collection_address, token_id, nft.rentinfo.rented_block);
    }

    function kick (address collection_address, uint256 token_id) public notPaused {
        NFTinfo memory nft = nftinfo[collection_address][token_id];
        require(nft.rentinfo.renter_address != address(0), "Not listed");
        require((block.number - nft.rentinfo.rented_block) > (nft.rentinfo.rent_duration + execution_delay) , "You can't kick now.");

        uint256 platformfee = nft.rentinfo.rentfee_amount * platform_fee / fee_denominator;
        uint256 kickfee = nft.rentinfo.rentfee_amount * kick_incentive / fee_denominator;
        uint256 total = nft.lendinfo.collateral_amount + nft.rentinfo.rentfee_amount - platformfee - kickfee;

        delete nftinfo[collection_address][token_id];

        IERC20(nft.lendinfo.collateral_token).transfer(msg.sender, kickfee);
        IERC20(nft.lendinfo.collateral_token).transfer(nft.lendinfo.lender_address, total);
        IERC20(nft.lendinfo.collateral_token).transfer(fee_collector, platformfee);

        emit kicked(collection_address, token_id, nft.rentinfo.renter_address, nft.rentinfo.rented_block, msg.sender, block.number);
    }

    event NFTlisted(address collection_address, address collateral_token, uint256 token_id, uint256 maxrent_duration, uint256 collateral_amount, uint256 rent_fee_per_block);
    event NFTlistcancelled(address collection_address, uint256 token_id);
    event NFTlistmodified(address collection_address, uint256 token_id, PARAMETER[] parameter, uint256[] input);
    event NFTrented(address collection_address, uint256 token_id, address renter_address, uint256 rent_duration, uint256 rented_block, uint256 total_amount);
    event NFTreturned(address collection_address, uint256 token_id, uint256 rented_block);
    event Colletralwithdrwed(address collection_address, uint256 token_id, uint256 rented_block);
    event kicked(address collection_address,uint256 token_id,address renter_address , uint256 rented_block , address kicker_address, uint256 kick_date);

}
