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
        uint256 total_amount;
    }
    struct Lendinfo {
        address lender_address;
        address collateral_token;
        uint256 maxrent_duration;
        uint256 collateral_amount;
        uint256 daily_rent_fee;
    }
    struct NFTinfo {
        Lendinfo lendinfo;
        Rentinfo rentinfo;
    }

    mapping(address => mapping(uint256 => NFTinfo)) private nftinfo;

    address fee_collector;
    uint256 platform_fee;
    uint256 kick_incentive;
    uint256 execution_delay = 2 days;

    uint256 fee_denominator = 1000000;
    bool paused;
    bool stopforupgrade;
    address[] collateral_array;


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
        execution_delay = _kick_incentive;
    }

    function togglepaused() external onlyOwner {
        paused = !paused;
    }

    function togglesstopforupgrade() external onlyOwner {
        stopforupgrade = !stopforupgrade;
    }

    functino set_collateral(address new_collateral) external onlyOwner {
        collateral_array.push(new_collateral);
    }
    

    constructor() {
        fee_collector = msg.sender;
        platform_fee = 1000;
    }

    //NFT 리스팅. 이전에 Approve 필요
    function listNFT(
            address collection_address,
            address _collateral_token,
            uint256 token_id,
            uint256 _maxrent_duration,
            uint256 _collateral_amount,
            uint256 _daily_rent_fee
            ) public notPaused notUpgrade {
        
        require(msg.sender == IERC721(collection_address).ownerOf(token_id), "You are not the owner");
        require(nftinfo[collection_address][token_id].rentinfo.rented_block == 0, "already rented item!");

        nftinfo[collection_address][token_id].lendinfo = Lendinfo ({
            lender_address : msg.sender,
            collateral_token : _collateral_token,
            maxrent_duration : _maxrent_duration,
            collateral_amount : _collateral_amount,
            daily_rent_fee : _daily_rent_fee
        });

        IERC721(collection_address).safeTransferFrom(msg.sender, address(this), token_id);
        emit NFTlisted(collection_address, _collateral_token, token_id, _maxrent_duration, _collateral_amount, _daily_rent_fee);
    }

    function canclelisted(address collection_address, uint256 token_id) public onlyLister(collection_address, token_id) notPaused {
        require(nftinfo[collection_address][token_id].rentinfo.rented_block == 0, "already rented item!");

        delete nftinfo[collection_address][token_id].lendinfo;
        IERC721(collection_address).safeTransferFrom(address(this), msg.sender, token_id);

        emit NFTlistcancled(collection_address, token_id);
    }

    function emergencycancle (address collection_address, uint256 token_id) external onlyOwner {
        require(nftinfo[collection_address][token_id].rentinfo.rented_block == 0, "already rented item!");

        delete nftinfo[collection_address][token_id].lendinfo;
        IERC721(collection_address).safeTransferFrom(address(this), nftinfo[collection_address][token_id].lendinfo.lender_address, token_id);

        emit NFTlistcancled(collection_address, token_id);
    }   

    enum PARAMETER { MAXRENT, PRICE, DAILYFEE }

    function modifylist(address collection_address, uint256 token_id, PARAMETER[] memory _parameter, uint256[] memory _input) public onlyLister(collection_address, token_id) notPaused notUpgrade {
        for (uint256 i = 0; i < _parameter.length; i++) {
            if (_parameter[i] == PARAMETER.MAXRENT) { // 0
                nftinfo[collection_address][token_id].lendinfo.maxrent_duration = _input[i];
            } else if (_parameter[i] == PARAMETER.PRICE) { // 1
                nftinfo[collection_address][token_id].lendinfo.collateral_amount = _input[i];
            } else if (_parameter[i] == PARAMETER.DAILYFEE) { // 2
                nftinfo[collection_address][token_id].lendinfo.daily_rent_fee = _input[i];
            }
        }

        emit NFTlistmodified(collection_address, token_id, _parameter, _input );
    }

    //rent 하기 전 collateral approve 해야함.
    function rent(address collection_address, uint256 token_id, uint256 _rent_duration) public notPaused  notUpgrade {
        require(nftinfo[collection_address][token_id].lendinfo.lender_address != address(0), "Not listed");
        require(_rent_duration > 0, "You should rent more than 1day");
        require(nftinfo[collection_address][token_id].rentinfo.rent_duration == 0, "Already rented");
        require(_rent_duration < nftinfo[collection_address][token_id].lendinfo.maxrent_duration, "too long NFT duration");

        Lendinfo memory lendinfo = nftinfo[collection_address][token_id].lendinfo;
        uint256 total = lendinfo.daily_rent_fee * _rent_duration + lendinfo.collateral_amount;

        nftinfo[collection_address][token_id].rentinfo = Rentinfo ({
            renter_address : msg.sender,
            rent_duration : _rent_duration,
            rented_block : block.number,
            total_amount : total
        });

        IERC20(lendinfo.collateral_token).transferFrom(msg.sender, address(this), total);
        IERC721(collection_address).safeTransferFrom(address(this), msg.sender, token_id);

        emit NFTrented(collection_address, token_id, msg.sender, _rent_duration, block.number, total);
    }

    function returnNFT(address collection_address, uint256 token_id) public notPaused {
        NFTinfo memory nft = nftinfo[collection_address][token_id];
        require(nft.rentinfo.renter_address != address(0), "Not listed");
        require(block.number - nft.rentinfo.rented_block <= nft.rentinfo.rent_duration, "Timeout.");
        require(msg.sender == nft.rentinfo.renter_address, "You are not renter");

        uint256 fee_amount = nft.rentinfo.total_amount - nft.lendinfo.collateral_amount;
        uint256 platformfee = fee_amount * platform_fee / fee_denominator;
        fee_amount = fee_amount - platform_fee; 

        delete nftinfo[collection_address][token_id];

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

        uint256 total = nft.rentinfo.total_amount;
        uint256 platformfee = total * platform_fee / fee_denominator;
        total = total - platform_fee;

        delete nftinfo[collection_address][token_id];

        IERC20(nft.lendinfo.collateral_token).transfer(msg.sender, total);
        IERC20(nft.lendinfo.collateral_token).transfer(fee_collector, platformfee);
        
        emit Colletralwithdrwed(collection_address, token_id, nft.rentinfo.rented_block);
    }

    function kick (address collection_address, uint256 token_id) public notPaused {
        NFTinfo memory nft = nftinfo[collection_address][token_id];
        require(nft.rentinfo.renter_address != address(0), "Not listed");
        require((block.number - nft.rentinfo.rented_block) > (nft.rentinfo.rent_duration + execution_delay) , "You can't kick now.");

        uint256 total = nft.rentinfo.total_amount;
        uint256 platformfee = total * platform_fee / fee_denominator;
        uint256 kickfee = total * kick_incentive / fee_denominator;
        total = total - platform_fee - kickfee;

        delete nftinfo[collection_address][token_id];

        IERC20(nft.lendinfo.collateral_token).transfer(msg.sender, kickfee);
        IERC20(nft.lendinfo.collateral_token).transfer(nft.lendinfo.lender_address, total);
        IERC20(nft.lendinfo.collateral_token).transfer(fee_collector, platformfee);

        emit kicked(collection_address, token_id, nft.rentinfo.renter_address, nft.rentinfo.rented_block, msg.sender, block.number);
    }

    event NFTlisted(address collection_address, address collateral_token, uint256 token_id, uint256 maxrent_duration, uint256 collateral_amount, uint256 daily_rent_fee);
    event NFTlistcancled(address collection_address, uint256 token_id);
    event NFTlistmodified(address collection_address, uint256 token_id, PARAMETER[] parameter, uint256[] input);
    event NFTrented(address collection_address, uint256 token_id, address renter_address, uint256 rent_duration, uint256 rented_block, uint256 total_amount);
    event NFTreturned(address collection_address, uint256 token_id, uint256 rented_block);
    event Colletralwithdrwed(address collection_address, uint256 token_id, uint256 rented_block);
    event kicked(address collection_address,uint256 token_id,address renter_address , uint256 rented_block , address kicker_address, uint256 kick_date);

}
