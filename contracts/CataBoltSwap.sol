pragma solidity ^0.6.12;

import './Libs.sol';

interface StandardToken {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IOracle {
   function read() external view returns(uint256 bnb_usd); 
}

contract CataBoltSwap{
    using SafeMath for uint256;

    address public token;

    address payable public fundsWallet;
    address public operatorWallet;

    uint256 public minPerUser;
    uint256 public publicMaxPerUser;

    bool public isPublic = false;

    IOracle public oracle;

    uint256 public ETH_USD = 400 ether;
    uint256 oracleBlock;

    mapping (address => uint256) public whitelist;


    uint256[] public percents;
    uint256[] public prices;

    constructor(
    ) public{
        
        minPerUser = 3 * 1e16; // 0.03 BNB
        publicMaxPerUser = 100 ether;

        fundsWallet = 0x6D16CfE28A74F1b400Bc90b808237309C7fAB379;
        operatorWallet = msg.sender;
        token = 0xc003F5193CABE3a6cbB56948dFeaAE2276a6AA5E;
        oracle = IOracle(0x7Db88D733D739d6dF40F3D5a734a108d73AB92c2);

        // default price
        // prices = new uint256[](3);
        // percents = new uint256[](3);

        percents.push(1428);
        prices.push(750000000);

        percents.push(2857);
        prices.push(1500000000);

        percents.push(5714);
        prices.push(3000000000);
    }

    modifier isPoolOpen() {
        StandardToken tokenContract = StandardToken(token);
        uint256 balance = tokenContract.balanceOf(address(this));
        require(balance > amountOut(msg.value), "!balance");
        _;
    }

    /**
     * @dev check swap amount
     */
    modifier checkSwapAmount(){
        require(msg.value >= minPerUser, "< min");
        require(msg.value <= maxPerUser(msg.sender), ">max");
        _;
    }

    /**
     *  check if the sender is admin
     */
    modifier isAdmin(){
        require(msg.sender == operatorWallet, "!admin");
        _;
    }

    modifier updatePrice(){
        _setETHToUsd();
        _;
    }    

    /**
     * @dev fallback function
     */
    receive() external payable{
       swap();
    }

    /**
     * @dev swap function
     */
    function swap() updatePrice checkSwapAmount isPoolOpen public payable{
        fundsWallet.transfer(msg.value);

        StandardToken tokenContract = StandardToken(token);
        uint256 amount = amountOut(msg.value);
        tokenContract.transfer(msg.sender, amount);

        if(!isPublic){
            whitelist[msg.sender] -= convertETHToUsd(msg.value);
        }
    }


    function _setETHToUsd() private returns(uint256 amount) {
        if((block.number - oracleBlock) < 10) return ETH_USD;
        amount = getETHToUsd();
        ETH_USD = amount;
        oracleBlock = block.number;
    }


    function convertETHToUsd(uint256 amtETH) public view returns(uint256 inUsd) {
        return amtETH.mul(ETH_USD).div(1 ether);
    }
    
    function convertUsdToETH(uint256 amtUsd) public view returns(uint256 inETH) {
        return amtUsd.mul(1 ether).div(ETH_USD);
    }

    function maxPerUser(address _user) view public returns(uint256){
        if(isPublic){
            return publicMaxPerUser;
        }
        return convertUsdToETH(whitelist[_user]);
    }

    function amountOut(uint256 _amount) view public returns(uint256){
        //return _amount.mul(tokenPerETH);
        uint256 usdAmount = convertETHToUsd(_amount);
        uint256 tokenAmount = 0;
        for(uint i=0; i<percents.length; i++){
            tokenAmount += percents[i].mul(usdAmount).div(
                10000
            ).mul(1 ether).div(
                prices[i]
            );
        }
        return tokenAmount;
    }

    function getETHToUsd() public view returns(uint256 amount) {
        //return 400 ether;
        return oracle.read();
    }

    /**
     * @dev Allows admin to withdraw remaining tokens
     */
    function adminWithdraw(address _token, uint256 _amount) isAdmin public{
        StandardToken tokenContract = StandardToken(_token);
        tokenContract.transfer(msg.sender, _amount);
    }

    function adminWithdrawBNB(uint256 _amount) isAdmin public{
        msg.sender.transfer(_amount);
    }


    function adminWhitelistUser(address _user, uint256 _amount) isAdmin public{
        whitelist[_user] = _amount;
    }

    function adminSetPrices(uint256[] memory _percents, uint256[] memory _prices) isAdmin public{
        // prices = new uint256[](_percents.length);
        // percents = new uint256[](_percents.length);

        for(uint i=0; i < _percents.length; i++){
            prices[i] = _prices[i];
            percents[i] = _percents[i];
        }
    }

    function setIsPublic(bool _isPublic) isAdmin public {
        isPublic = _isPublic;
    }

    function setToken(address _token) isAdmin public {
        token = _token;
    }

    function setFundsWallet(address payable _fundsWallet) isAdmin public {
        fundsWallet = _fundsWallet;
    }

    function setOperatorWallet(address _operatorWallet) isAdmin public {
        operatorWallet = _operatorWallet;
    }

    function setMinPerUser(uint256 _minPerUser) isAdmin public {
        minPerUser = _minPerUser;
    }

    function setPublicMaxPerUser(uint256 _publicMaxPerUser) isAdmin public {
        publicMaxPerUser = _publicMaxPerUser;
    }

    function setOracle(address _oracle) isAdmin public{
        oracle = IOracle(_oracle);
    }

    function setETH_USD(uint256 _amount) isAdmin public{
        ETH_USD = _amount;
    }
}
