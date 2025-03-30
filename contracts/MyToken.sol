// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyTokenWithDynamicFee is ERC20 {
    address public owner;
    uint256 public baseFeePercentage = 10; // Phí ban đầu 0.1% = 10/10000
    uint256 public constant FEE_DENOMINATOR = 10000;
    uint256 public constant MAX_FEE_PERCENTAGE = 1000; // Phí tối đa 10% = 1000/10000
    uint256 public feeChangeRate = 10; // Tăng 0.1% mỗi khoảng thời gian
    uint256 public timeInterval = 1 days; // Khoảng thời gian thay đổi phí (1 ngày)
    uint256 public startTime; // Thời điểm bắt đầu tính phí động

    event FeePercentageUpdated(uint256 newFeePercentage);

    constructor(uint256 initialSupply) ERC20("MyTokenWithDynamicFee", "MTDF") {
        owner = msg.sender;
        startTime = block.timestamp; // Bắt đầu tính thời gian từ khi deploy
        _mint(msg.sender, initialSupply);
    }

    // Hàm tính phí hiện tại dựa trên thời gian
    function getCurrentFeePercentage() public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - startTime;
        uint256 intervalsPassed = timeElapsed / timeInterval;
        uint256 newFee = baseFeePercentage + (intervalsPassed * feeChangeRate);

        // Giới hạn phí tối đa
        if (newFee > MAX_FEE_PERCENTAGE) {
            return MAX_FEE_PERCENTAGE;
        }
        return newFee;
    }

    // Ghi đè hàm transfer để áp dụng phí động
    function transfer(address to, uint256 amount) public override returns (bool) {
        address sender = _msgSender();
        uint256 currentFeePercentage = getCurrentFeePercentage();
        uint256 fee = (amount * currentFeePercentage) / FEE_DENOMINATOR;
        uint256 amountAfterFee = amount - fee;

        _transfer(sender, owner, fee); // Chuyển phí cho owner
        _transfer(sender, to, amountAfterFee); // Chuyển số còn lại cho người nhận
        return true;
    }

    // Ghi đè hàm transferFrom để áp dụng phí động
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        address spender = _msgSender();
        uint256 currentFeePercentage = getCurrentFeePercentage();
        uint256 fee = (amount * currentFeePercentage) / FEE_DENOMINATOR;
        uint256 amountAfterFee = amount - fee;

        _spendAllowance(from, spender, amount); // Kiểm tra allowance
        _transfer(from, owner, fee); // Chuyển phí cho owner
        _transfer(from, to, amountAfterFee); // Chuyển số còn lại cho người nhận
        return true;
    }

    // Hàm cho owner thay đổi các tham số (tùy chọn)
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function setFeeChangeRate(uint256 newRate) external onlyOwner {
        feeChangeRate = newRate;
        emit FeePercentageUpdated(getCurrentFeePercentage());
    }

    function setTimeInterval(uint256 newInterval) external onlyOwner {
        timeInterval = newInterval;
        emit FeePercentageUpdated(getCurrentFeePercentage());
    }
}
