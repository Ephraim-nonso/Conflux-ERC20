//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./interfaces/IERC20.sol";
import "./interfaces/IWitnetRandomness.sol";

contract Vault {
    //////STATE VARIABLES/////////
    address owner;

    //////Randomness Sate Variable//////
    uint32 public randomness;
    uint256 public latestRandomizingBlock;
    IWitnetRandomness public witnet;

    //////STRUT/////////
    struct GrantProps {
        address token;
        address receipient;
        uint64 timeline;
        uint256 amount;
    }

    //////MAPPING/////////
    mapping(uint32 => GrantProps) public grantProps;

    //////EVENTS/////////
    event createGrant(
        address token_,
        address receipient,
        uint256 amount,
        uint256 id
    );
    event grantClaimed(address receipient, uint256 amount, uint256 id);
    event grantRemoved(address token, uint256 amount, uint256 id);

    //////MODIFIERS/////////
    modifier Ownable() {
        require(msg.sender == owner);
        _;
    }

    //////CONSTRUCTOR/////////
    constructor(address _witnetRandomness) payable {
        owner = msg.sender;
        assert(address(_witnetRandomness) != address(0));
        witnet = IWitnetRandomness(_witnetRandomness);
        requestRandomNumber();
    }

    //witnetrandom address 0xa784093826e2894ab3db315f4e05f0f26407bbff
    

    //////fUNCTIONS/////////

    /// @notice create Grants for people to come and claim when the deadline is met
    /// @param _token the ERC20 tokens to pay
    /// @param _receipient The beneficiary of the ERC20 tokens
    /// @param _amount the number of tokens to claim
    /// @param timestamp the block.timestamp in which the grant is due for claim
    /// @dev will fail if transferFrom is not successful
    function createGrantFund(
        address _token,
        address _receipient,
        uint256 _amount,
        uint64 timestamp
    ) external payable Ownable {
        require(
            IERC20(_token).transferFrom(msg.sender, address(this), _amount),
            "transfer failed"
        );
        fetchRandomNumber();

        GrantProps storage GF = grantProps[randomness];
        GF.token = _token;
        GF.receipient = _receipient;
        GF.amount = _amount;
        GF.timeline = timestamp;
        requestRandomNumber();

        emit createGrant(_token, _receipient, _amount, randomness);
    }

    /// @notice remove Grants give access to owner to remove grants before the timestamp is met
    /// @param id the id of the grantProperties to remove

    function removeGrant(uint32 id) external Ownable {
        bool notlapse = hasTimelineExpired(id);
        require(!(notlapse), "timeelapse for receipient to withdraw");
        GrantProps storage GF = grantProps[id];
        address token_ = GF.token;
        uint256 amount_ = GF.amount;
        GF.amount = 0;
        bool success = IERC20(token_).transfer(msg.sender, amount_);
        require(success, "transfer failes");
        emit grantRemoved(token_, amount_, id);
    }

    /// @notice claim Grants for receipient to claim when the deadline is met
    /// @param id the unique number of the grant to claim
    /// @dev will fail if transferFrom is not successful
    function claimGrant(uint32 id) external {
        require(hasTimelineExpired(id), "Not yet time to withdraw");
        address receipient_ = grantProps[id].receipient;
        address token_ = grantProps[id].token;
        uint256 amount_ = grantProps[id].amount;
        grantProps[id].amount = 0;
        require(amount_ > 0, "NO fund for this grant");
        require(
            msg.sender == receipient_,
            "you are not the beneficiary to this grant"
        );
        bool success = IERC20(token_).transfer(msg.sender, amount_);
        require(success, "transfer fails");

        emit grantClaimed(msg.sender, amount_, id);
    }

    /////////////VIEW FUNCTIONS/////////////////

    /// @notice This function check if time for particular grants has passed
    /// @param id the unique id of the grant to check
    function hasTimelineExpired(uint32 id) public view returns (bool) {
        GrantProps memory GF = grantProps[id];
        return (GF.timeline <= block.timestamp);
    }

    /// @notice This function returns the owner of this contract;
    /// @return returns the address of the owner.
    function getOwner() external view returns (address) {
        return owner;
    }

    /// @notice This function returns the properties of a grant;
    /// @param id the unique id of the grant to check
    /// @return returns the information of a particular grants.
    function getFundProps(uint32 id)
        external
        view
        returns (GrantProps memory)
    {
        return grantProps[id];
    }

    //////////////INTERNL FUNCTION ///////////////////

    function requestRandomNumber() internal {
        latestRandomizingBlock = block.number;
        uint256 _usedFunds = witnet.randomize{value: msg.value}();
        if (_usedFunds < msg.value) {
            payable(msg.sender).transfer(msg.value - _usedFunds);
        }
    }

    function fetchRandomNumber() internal {
        assert(latestRandomizingBlock > 0);
        randomness =
            1 +
            witnet.random(type(uint32).max, 0, latestRandomizingBlock);
    }
}